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
    cells::Vector{Cell})
    keybindings = c[:OliveCore].client_data[getip(c)][:keybindings]
    km = ToolipsSession.KeyMap()
    bind!(km, "Backspace") do cm2::ComponentModifier
        if cm2[inside]["text"] == ""
            pos = findall(lcell -> lcell.id == cell.id, cells)[1]
            new_cell = Cell(pos, "code", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm, outside)
            ToolipsSession.insert!(cm, "olivemain", pos, build(c, cm, new_cell, cells))
            focus!(cm, "cell$(cell.id)")
        end
    end
    outside = div("cellcontainer$(cell.id)", class = cell)
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = cell.source)
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
    cells::Vector{Cell})
    keybindings = c[:OliveCore].client_data[getip(c)][:keybindings]
    km = ToolipsSession.KeyMap()
    text = replace(cell.source, "\n" => "</br>")
#==    tm = TextModifier(text)
    ToolipsMarkdown.julia_block!(tm)
    ==#
    outside = div("cellcontainer$(cell.id)", class = cell)
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = text)
    on(c, cm, inside, "input") do cm::ComponentModifier
        curr = cm[inside]["text"]
        if curr == "]"
            pos = findall(lcell -> lcell.id == cell.id, cells)[1]
            new_cell = Cell(pos, "pkgrepl", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm, outside)
            ToolipsSession.insert!(cm, "olivemain", pos, build(c, cm, new_cell, cells))
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
    maininputbox = div("maininputbox")
    style!(maininputbox, "width" => 60percent, "padding" => 0px)
    interiorbox = div("cellinterior$(cell.n)")
    inside[:class] = "input_cell"
    # bottom box
    bottombox = div("cellside$(cell.n)")
    cell_drag = topbar_icon("cell$(cell.id)drag", "drag_indicator")
    cell_run = topbar_icon("cell$(cell.id)drag", "play_arrow")
    style!(cell_drag, "color" => "white", "font-size" => 17pt)
    style!(cell_run, "color" => "white", "font-size" => 17pt)
    style!(bottombox, "background-color" => "gray",
    "border-top-right-radius" => 0px, "border-top-left-radius" => 0px,
    "margin-top" => 0px, "width" => 10percent)
     style!(inside,
     "width" => 80percent, "border-bottom-left-radius" => 0px, "min-height" => 50px,
     "position" => "relative", "margin-top" => 0px)
     style!(outside, "transition" => 1seconds)
     push!(maininputbox, inside)
     push!(interiorbox, maininputbox, bottombox)
    number = a("cell", text = "$(cell.n)", class = "cell_number")
    output = divider("cell$(cell.id)" * "out", class = "output_cell", text = cell.outputs)
    push!(bottombox, cell_drag, number, cell_run)
    push!(outside, interiorbox, output)
    on(c, cell_run, "click") do cm2::ComponentModifier
            evaluate(c, cell, cm2)
    end
    bind!(km, keybindings[:evaluate] ...) do cm2::ComponentModifier
        evaluate(c, cell, cm2)
        pos = findall(lcell -> lcell.id == cell.id, cells)[1]
        if pos == length(cells)
            new_cell = Cell(length(cells) + 1, "code", "", id = ToolipsSession.gen_ref())
            push!(cells, new_cell)
            append!(cm2, "olivemain", build(c, cm2, new_cell, cells))
            focus!(cm2, "cell$(new_cell.id)")
            return
        end
        next_cell = cells[pos + 1]
        focus!(cm2, "cell$(next_cell.id)")
    end
    bind!(km, keybindings[:delete] ...) do cm::ComponentModifier
        remove!(cm, "cellcontainer$(cell.id)")
        deleteat!(cells, findall(c -> c.id == cell.id, cells)[1])
    end
    bind!(km, keybindings[:new] ...) do cm::ComponentModifier
        pos = findall(lcell -> lcell.id == cell.id, cells)[1]
        newcell = Cell(pos + 1, "code", "")
        insert!(cells, pos + 1, newcell)
        ToolipsSession.insert!(cm, "olivemain", pos + 1, build(c, cm, newcell, cells))
    end
    bind!(c, cm, inside, km)
    outside
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    cells::Vector{Cell})
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
    execcode::String = replace(rawcode, "<div>" => "\n", "</div>" => "")
    text::String = replace(cell.source, "\n" => "</br>")
    # get project
    selected::String = cm["olivemain"]["selected"]
    proj::Project{<:Any} = c[:OliveCore].open[getip(c)]
    #== evaluate
    SOME NOTES -- `i` below is meant to eventually be passed through `evalin`.
    We need to find a way to make this buffer write anything that comes through
    stdout, that way if something is printed or otherwise it can still be
    displayed instead of entirely relying on returns.
    ==#
    ret::Any = ""
    try
        ret = proj.mod.evalin(Meta.parse(execcode))
    catch e
        ret = e
    end

    # output
    od = OliveDisplay()
    display(od, MIME"olive"(), ret)
    outp::String = String(od.io.data)
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
