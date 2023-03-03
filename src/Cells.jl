"""
**Interface**
### build(c::Connection, dir::Directory{<:Any}) -> ::Component{:div}
------------------
The catchall/default `build` function. If you want to add a custom directory,
create an OliveaExtension and
#### example
```

```
custom directory example
```
# In your Olive root: ('~/olive/src/olive.jl' by default)

```
"""
function build(c::Connection, cell::Cell{<:Any},
    args ...)
    hiddencell = div("cell$(cell.id)", class = "cell-hidden")
    name = a("cell$(cell.id)label", text = cell.source)
    style!(name, "color" => "black")
    push!(hiddencell, name)
    hiddencell
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    args ...)
    hiddencell = div("cell$(cell.id)", class = "cell-hidden")
    name = a("cell$(cell.id)label", text = cell.source)
    style!(name, "color" => "black")
    push!(hiddencell, name)
    hiddencell
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:pkgrepl},
    cells::Vector{Cell}, window::String)
    keybindings = c[:OliveCore].client_data[getip(c)][:keybindings]
    km = ToolipsSession.KeyMap()
    outside = div("cellcontainer$(cell.id)", class = cell)
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = cell.source)
    bind!(km, "Backspace") do cm2::ComponentModifier
        if cm2[inside]["text"] == ""
            pos = findall(lcell -> lcell.id == cell.id, cells)[1]
            new_cell = Cell(pos, "code", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm2, outside)
            ToolipsSession.insert!(cm2, window, pos, build(c, cm2, new_cell,
            cells, window))
            focus!(cm2, "cell$(cell.id)")
        end
    end
    style!(inside, "width" => 80percent, "border-bottom-left-radius" => 0px,
    "min-height" => 50px,
     "position" => "relative", "margin-top" => 0px,
     "background-color" => "blue", "color" => "white")
    push!(outside, inside)
    bind!(c, cm, inside, km)
    outside
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:shell},
    cells::Vector{Cell})
    keybindings = c[:OliveCore].client_data[getip(c)][:keybindings]

end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    cells::Vector{Cell}, windowname::String)
    keybindings = c[:OliveCore].client_data[getip(c)][:keybindings]
    km = ToolipsSession.KeyMap()
    text = replace(cell.source, "\n" => "</br>")
#==    tm = TextModifier(text)
    ToolipsMarkdown.julia_block!(tm)
    ==#
    outside = div("cellcontainer$(cell.id)", class = "cell")
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = text,
    "class" => "input_cell")
    style!(inside,
    "width" => 80percent, "border-bottom-left-radius" => 0px, "min-height" => 50px,
    "position" => "relative", "margin-top" => 0px, "display" => "inline-block",
    "border-top-left-radius" => 0px)
    style!(outside, "transition" => 1seconds)
    on(c, cm, inside, "input") do cm::ComponentModifier
        curr = cm[inside]["text"]
        if curr == "]"
            pos = findall(lcell -> lcell.id == cell.id, cells)[1]
            new_cell = Cell(pos, "pkgrepl", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm, outside)
            ToolipsSession.insert!(cm, windowname, pos, build(c, cm, new_cell,
             cells, windowname))
            focus!(cm, "cell$(cell.id)")
        elseif curr == ";"
            alert!(cm, "bashcell")
        elseif curr == "\\"
            alert!(cm, "olivecell")
        end
        #== TODO
        Syntax highlighting here.
        ==#
        cell.source = cm[inside]["text"]
    end
    interiorbox = div("cellinterior$(cell.id)")
    style!(interiorbox, "display" => "flex")
    sidebox = div("cellside$(cell.id)")
    style!(sidebox, "display" => "inline-block", "background-color" => "pink",
    "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px)
    push!(interiorbox, sidebox, inside)
    cell_drag = topbar_icon("cell$(cell.id)drag", "drag_indicator")
    cell_run = topbar_icon("cell$(cell.id)drag", "play_arrow")
    push!(sidebox, cell_drag, br(), cell_run)
    style!(cell_drag, "color" => "white", "font-size" => 17pt)
    style!(cell_run, "color" => "white", "font-size" => 17pt)
    output = divider("cell$(cell.id)" * "out", class = "output_cell", text = cell.outputs)
    push!(outside, interiorbox, output)
    on(c, cell_run, "click") do cm2::ComponentModifier
            evaluate(c, cell, cm2)
    end
    bind!(km, keybindings[:evaluate] ...) do cm2::ComponentModifier
        icon = olive_loadicon()
        icon.name = "load$(cell.id)"
        icon["width"] = "20"
        remove!(cm2, cell_run)
        set_children!(cm2, "cellside$(cell.id)", [icon])
        script!(c, cm2, "$(cell.id)eval") do cm3::ComponentModifier
            evaluate(c, cell, cm3)
            pos = findall(lcell -> lcell.id == cell.id, cells)[1]
            if pos == length(cells)
                new_cell = Cell(length(cells) + 1, "code", "", id = ToolipsSession.gen_ref())
                push!(cells, new_cell)
                append!(cm3, windowname, build(c, cm3, new_cell, cells, windowname))
                focus!(cm3, "cell$(new_cell.id)")
                set_children!(cm3, "cellside$(cell.id)", [cell_drag, br(), cell_run])
                bind!(c, cm3, km)
                return
            end
            next_cell = cells[pos + 1]
            focus!(cm3, "cell$(next_cell.id)")
            set_children!(cm3, sidebox, [cell_drag, br(), cell_run])
        end
    end
    bind!(km, keybindings[:up] ...) do cm2::ComponentModifier
        pos = findall(lcell -> lcell.id == cell.id, cells)[1]
        switchcell = cells[pos - 1]
        cells[pos - 1] = cell
        cells[pos] = switchcell
        remove!(cm2, "cellcontainer$(switchcell.id)")
        remove!(cm2, "cellcontainer$(cell.id)")
        ToolipsSession.insert!(cm2, windowname, pos, build(c, cm2, switchcell, cells,
        windowname))
        ToolipsSession.insert!(cm2, windowname, pos - 1, build(c, cm2, cell, cells,
        windowname))
        focus!(cm2, "cell$(cell.id)")
    end
    bind!(km, keybindings[:down] ...) do cm::ComponentModifier
        pos = findall(lcell -> lcell.id == cell.id, cells)[1]
        switchcell = cells[pos + 1]
        cells[pos + 1] = cell
        cells[pos] = switchcell
        remove!(cm, "cellcontainer$(switchcell.id)")
        remove!(cm, "cellcontainer$(cell.id)")
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, switchcell, cells,
        windowname))
        ToolipsSession.insert!(cm, windowname, pos + 1, build(c, cm, cell, cells,
        windowname))
        focus!(cm, "cell$(cell.id)")
    end
    bind!(km, keybindings[:delete] ...) do cm::ComponentModifier
        remove!(cm, "cellcontainer$(cell.id)")
        deleteat!(cells, findfirst(c -> c.id == cell.id, cells))
    end
    bind!(km, keybindings[:new] ...) do cm::ComponentModifier
        pos = findall(lcell -> lcell.id == cell.id, cells)[1]
        newcell = Cell(pos, "code", "")
        insert!(cells, pos, newcell)
        ToolipsSession.insert!(cm, windowname, pos + 1, build(c, cm, newcell,
        cells, windowname))
    end
    bind!(c, cm, inside, km)
    outside
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    cells::Vector{Cell}, windowname::String)
    tlcell = div("cell$(cell.id)", class = "cell")
    innercell = tmd("cell$(cell.id)tmd", cell.source)
    on(c, cm, tlcell, "dblclick") do cm::ComponentModifier
        set_text!(cm, tlcell, replace(cell.source, "\n" => "</br>"))
        cm["olivemain"] = "cell" => string(cell.n)
        cm[tlcell] = "contenteditable" => "true"
    end
    tlcell[:children] = [innercell]
    tlcell
end


function build(c::Connection, cell::Cell{:ipynb},
    d::Directory{<:Any})
    filecell = div("cell$(cell.id)", class = "cell-ipynb")
    on(c, filecell, "dblclick") do cm::ComponentModifier
        evaluate(c, cell, cm)
    end
    fname = a("$(cell.source)", text = cell.source)
    style!(fname, "color" => "white", "font-size" => 15pt)
    push!(filecell, fname)
    filecell
end

function build(c::Connection, cell::Cell{:dir}, d::Directory{<:Any})
    filecell = div("cell$(cell.id)", class = "cell-ipynb")
    style!(filecell, "background-color" => "#FFFF88")
    on(c, filecell, "dblclick") do cm::ComponentModifier
        returner = div("cell$(cell.id)", class = "cell-jl")
        style!(returner, "background-color" => "red")
        name = a("cell$(cell.id)label", text = d.uri)
        style!(name, "color" => "white")
        push!(returner, name)
        on(c, returner, "dblclick") do cm2::ComponentModifier
            newcells = directory_cells(d.uri)
            set_children!(cm2, "$(d.uri)cells",
            Vector{Servable}([build(c, cel, d) for cel in newcells]))
        end
        newcells = directory_cells(d.uri * "/" * cell.source)
        set_children!(cm, "$(d.uri)cells",
        vcat([returner], [build(c, cel, d) for cel in newcells]))
    end
    fname = a("$(cell.source)", text = cell.source)
    style!(fname, "color" => "gray", "font-size" => 15pt)
    push!(filecell, fname)
    filecell
end

function build(c::Connection, cell::Cell{:jl},
    d::Directory{<:Any})
    hiddencell = div("cell$(cell.id)", class = "cell-jl")
    style!(hiddencell, "cursor" => "pointer")
    on(c, hiddencell, "dblclick") do cm::ComponentModifier
        evaluate(c, cell, cm)
    end
    name = a("cell$(cell.id)label", text = cell.source)
    style!(name, "color" => "white")
    push!(hiddencell, name)
    hiddencell
end

function build(c::Connection, cell::Cell{:toml},
    d::Directory)
    hiddencell = div("cell$(cell.id)", class = "cell-toml")
    name = a("cell$(cell.id)label", text = cell.source)
    on(c, hiddencell, "dblclick") do cm::ComponentModifier
        evaluate(c, cell, cm)
    end
    style!(name, "color" => "white")
    push!(hiddencell, name)
    hiddencell
end

function build(c::Connection, cell::Cell{:setup})
    maincell = section("cell$(cell.id)", align = "center")
    push!(maincell, olive_cover())
    push!(maincell, h("setupheading", 1, text = "welcome !"))
    push!(maincell, p("setuptext", text = """Olive requires a home directory
    in order to store your configuration, please select a home directory
    in the cell below. Olive will create a `/olive` directory in the chosen
    directory."""))
    maincell
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:filebrowser})

end

function build_returner(c::Connection, path::String)
    returner_div = div("returner")
    style!(returner_div, "background-color" => "red", "cursor" => "pointer")
    push!(returner_div, a("returnerbutt", text = "..."))
    on(c, returner_div, "click") do cm::ComponentModifier
        paths = split(path, "/")
        path = join(paths[1:length(paths) - 1], "/")
        set_text!(cm, "selector", path)
        set_children!(cm, "filebox", Vector{Servable}(vcat(
        build_returner(c, path),
        [build_comp(c, path, f) for f in readdir(path)]))::Vector{Servable})
    end
    returner_div
end

function build_comp(c::Connection, path::String, dir::String)
    if isdir(path * "/" * dir)
        maincomp = div("$dir")
        style!(maincomp, "background-color" => "lightblue", "cursor" => "pointer")
        push!(maincomp, a("$dir-a", text = dir))
        on(c, maincomp, "click") do cm::ComponentModifier
            path = path * "/" * dir
            set_text!(cm, "selector", path)
            children = Vector{Servable}([build_comp(c, path, f) for f in readdir(path)])::Vector{Servable}
            set_children!(cm, "filebox", vcat(Vector{Servable}([build_returner(c, path)]), children))
        end
        return(maincomp)::Component{:div}
    end
    maincomp = div("$dir")
    push!(maincomp, a("$dir-a", text = dir))
    maincomp::Component{:div}
end

function build(c::Connection, cell::Cell{:dirselect})
    selector_indicator = h("selector", 4, text = cell.source)
    path = cell.source
    filebox = section("filebox")
    style!(filebox, "height" => 40percent, "overflow-y" => "scroll")
    filebox[:children] = vcat(Vector{Servable}([build_returner(c, path)]),
    Vector{Servable}([build_comp(c, path, f) for f in readdir(path)]))
    cellover = div("dirselectover")
    push!(cellover, selector_indicator, filebox)
    cellover
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:tutorial})

end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:option})

end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:defaults})

end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:tomlcategory},
    cells::Vector{Cell})
   catheading = h("cell$(cell.id)heading", 2, text = cell.source, contenteditable = true)
    contents = section("cell$(cell.id)")
    push!(contents, catheading)
    v = string(cell.outputs)
    equals = a("equals", text = " = ")
    style!(equals, "color" => "gray")
    for (k, v) in cell.outputs
        key_div = div("keydiv")
        push!(key_div,
        a("$(cell.n)$k", text = string(k), contenteditable = true), equals,
        a("$(cell.n)$k$v", text = string(v), contenteditable = true))
        push!(contents, key_div)
    end
    contents
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:tomlval},
    cells::Vector{Cell})
        key_div = div("cell$(cell.id)")
        k = cell.source
        v = string(cell.outputs)
        equals = a("equals", text = " = ")
        style!(equals, "color" => "gray")
        push!(key_div,
        a("$(cell.n)$k", text = string(k), contenteditable = true), equals,
        a("$(cell.n)$k$v", text = string(v), contenteditable = true))
        key_div
end

function evaluate(c::Connection, cell::Cell{<:Any}, cm::ComponentModifier)

end

function evaluate(c::Connection, cell::Cell{:code}, cm::ComponentModifier)
    # get code
    rawcode::String = cm["rawcell$(cell.id)"]["text"]
    execcode::String = *("begin\n", replace(rawcode, "<div>" => "\n",
    "</div>" => ""), "end\n")
    text::String = replace(cell.source, "\n" => "</br>")
    # get project
    selected::String = cm["olivemain"]["selected"]
    proj::Project{<:Any} = c[:OliveCore].open[getip(c)]
    #== evaluate

    ==#
    ret::Any = ""
    p = Pipe()
    redirect_stdout(p) do
        try
            ret = proj.mod.evalin(Meta.parse(execcode))
        catch e
            ret = e
        end
    end
    close(Base.pipe_writer(p))
    standard_out = read(p, String)
    # output
    outp::String = ""
    od = OliveDisplay()
    display(od, MIME"olive"(), ret)
    if ~(isnothing(ret)) && length(standard_out) > 0
        outp = standard_out * "</br>" * String(od.io.data)
    elseif ~(isnothing(ret)) && length(standard_out) == 0
        outp = String(od.io.data)
    else
        outp = standard_out
    end
    set_text!(cm, "cell$(cell.id)out", outp)
    # mutate cell
    cell.outputs = outp
    cell.source = text
end

function evaluate(c::Connection, cell::Cell{:toml}, cm::ComponentModifier)
    toml_cats = TOML.parse(read(cell.outputs, String))
    cs::Vector{Cell{<:Any}} = [begin if typeof(keycategory[2]) <: AbstractDict
        Cell(e, "tomlcategory", keycategory[1], keycategory[2], id = ToolipsSession.gen_ref())
    else
        Cell(e, "tomlval", keycategory[1], keycategory[2], id = ToolipsSession.gen_ref())
    end
    end for (e, keycategory) in enumerate(toml_cats)]
    Olive.load_session(c, cs, cm, cell.source, cell.outputs)
end

function evaluate(c::Connection, cell::Cell{:markdown}, cm::ComponentModifier)
    activemd = replace(cm["cell$(cell.id)"]["text"], "<div>" => "\n")
    cell.source = activemd
    newtmd = tmd("cell$(cell.id)tmd", activemd)
    set_children!(cm, "cell$(cell.id)", [newtmd])
    cm["cell$(cell.id)"] = "contenteditable" => "false"
end

function evaluate(c::Connection, cell::Cell{:ipynb}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_ipynb(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function evaluate(c::Connection, cell::Cell{:jl}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_jl(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function directory_cells(dir::String = pwd(), access::Pair{String, String} ...)
    files = readdir(dir)
    return([build_file_cell(e, path, dir) for (e, path) in enumerate(files)]::AbstractVector)
end

function build_file_cell(e::Int64, path::String, dir::String)
    if ~(isdir(path))
        splitdir::Vector{SubString} = split(path, "/")
        fname::String = string(splitdir[length(splitdir)])
        fsplit = split(fname, ".")
        fending::String = ""
        if length(fsplit) > 1
            fending = string(fsplit[2])
        end
        Cell(e, fending, fname, dir * "/" * path)
    else
        Cell(e, "dir", path, path)
    end
end
