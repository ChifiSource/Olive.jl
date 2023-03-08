"""
**Interface**
### build(c::Connection, cell::Cell{<:Any}, args ...; arg ...) -> ::Component{:div}
------------------
The catchall/default `build` function for directory cells. This function is what
creates the gray boxes for files that Olive cannot read inside of directories.
Using this function as a template, you can create your own directory cells.
#### example
```

```
custom directory example
```
# In your Olive root: ('~/olive/src/olive.jl' by default)

```
"""
function build(c::Connection, cell::Cell{<:Any}, args ...; arg ...)
    hiddencell = div("cell$(cell.id)", class = "cell-hidden")
    name = a("cell$(cell.id)label", text = cell.source)
    style!(name, "color" => "black")
    push!(hiddencell, name)
    hiddencell
end

"""
**Interface**
### build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any}, args ...; arg ...) -> ::Component{:div}
------------------
The catchall/default `build` function for session cells. This function is what
creates the gray boxes for cells that Olive cannot create.
Using this function as a template, you can create your own olive cells.
#### example
```

```
custom directory example
```
# In your Olive root: ('~/olive/src/olive.jl' by default)

```
"""
function build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    args ...)
    hiddencell = div("cell$(cell.id)", class = "cell-hidden")
    name = a("cell$(cell.id)label", text = cell.source)
    style!(name, "color" => "black")
    push!(hiddencell, name)
    hiddencell
end

function cell_up!(c::Connection, cm2::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}}, windowname::String)
    pos = findall(lcell -> lcell.id == cell.id, cells)[1]
    if pos != 1
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
    else
        olive_notify!(cm2, "this cell cannot go up any further!", color = "red")
    end
end

function cell_down!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}}, windowname::String)
    pos = findall(lcell -> lcell.id == cell.id, cells)[1]
    if pos != length(cells)
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
    else
        olive_notify!(cm, "this cell cannot go down any further!", color = "red")
    end
end

function cell_delete!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}})
    remove!(cm, "cellcontainer$(cell.id)")
    deleteat!(cells, findfirst(c -> c.id == cell.id, cells))
end

function cell_new!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}}, windowname::String; type::String = "code")
    pos = findall(lcell -> lcell.id == cell.id, cells)[1]
    newcell = Cell(pos, type, "")
    insert!(cells, pos, newcell)
    ToolipsSession.insert!(cm, windowname, pos + 1, build(c, cm, newcell,
    cells, windowname))
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:helprepl},
    cells::Vector{Cell}, windowname::String)
    src = ""
    if contains(cell.source, "#")
        src = split(cell.source, "?")[2]
    end
    cell.source = src
    keybindings = c[:OliveCore].client_data[getip(c)]["keybindings"]
    km = ToolipsSession.KeyMap()
    outside = div("cellcontainer$(cell.id)", class = "cell")
    inner  = div("cellinside$(cell.id)")
    style!(inner, "display" => "flex")
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = cell.source)
    bind!(km, "Backspace") do cm2::ComponentModifier
        if cm2["rawcell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell(pos, "code", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm2, outside)
            built = build(c, cm2, new_cell, cells, windowname)
            ToolipsSession.insert!(cm2, windowname, pos, built)
            focus!(cm2, "cell$(cell.id)")
        end
    end
    bind!(km, keybindings[:evaluate] ...) do cm2::ComponentModifier
        evaltxt =  cm2["rawcell$(cell.id)"]["text"]
        cell.source = "# ?$(evaltxt)"
        rts = c[:OliveCore].open[getip(c)].open[windowname][:mod].evalin(
        Meta.parse("@doc($(evaltxt))"))
        outtmd = tmd("out$(cell.id)", string(rts))
        spoofcon = Toolips.SpoofConnection()
        write!(spoofcon, outtmd)
        cell.outputs = spoofcon.http.text
        set_children!(cm2, "cell$(cell.id)out", [outtmd])
    end
    bind!(km, keybindings[:up] ...) do cm2::ComponentModifier
        cell_up!(c, cm2, cell, cells, windowname)
    end
    bind!(km, keybindings[:down] ...) do cm2::ComponentModifier
        cell_down!(c, cm2, cell, cells, windowname)
    end
    bind!(km, keybindings[:delete] ...) do cm2::ComponentModifier
        cell_delete!(c, cm2, cell, cells)
    end
    bind!(km, keybindings[:new] ...) do cm2::ComponentModifier
        cell_new!(c, cm2, cell, cells, windowname)
    end
    sidebox = div("cellside$(cell.id)")
    style!(sidebox, "display" => "inline-block",
    "background-color" => "orange",
    "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px,
    "overflow" => "hidden")
    pkglabel =  a("$(cell.id)helplabel", text = "help>")
    style!(pkglabel, "font-weight" => "bold", "color" => "black")
    push!(sidebox, pkglabel)
    style!(inside, "width" => 80percent, "border-bottom-left-radius" => 0px,
    "border-top-left-radius" => 0px,
    "min-height" => 50px, "display" => "inline-block",
     "margin-top" => 0px, "font-weight" => "bold",
     "background-color" => "orange", "color" => "black")
     output = div("cell$(cell.id)out", text = cell.outputs)
     push!(inner, sidebox, inside)
    push!(outside, inner, output)
    bind!(c, cm, inside, km)
    outside
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:creator},
    cells::Vector{Cell}, windowname::String)
    olmod = c[:OliveCore].olmod
    signatures = [m.sig.parameters[4] for m in methods(Olive.build,
    [Toolips.AbstractConnection, Toolips.Modifier, IPy.AbstractCell, Vector{Cell}, String])]
     buttonbox = div("cellcontainer$(cell.id)")
     push!(buttonbox, h("spawn$(cell.id)", 3, text = "new cell"))
     for sig in signatures
         if sig == Cell{:creator} || sig == Cell{<:Any}
             continue
         end
         if length(sig.parameters) < 1
             continue
         end
         b = button("$(sig)butt", text = string(sig.parameters[1]))
         on(c, b, "click") do cm2::ComponentModifier
             pos = findfirst(lcell -> lcell.id == cell.id, cells)
             remove!(cm2, buttonbox)
             new_cell = Cell(pos, string(sig.parameters[1]), "")
             deleteat!(cells, pos)
             insert!(cells, pos, new_cell)
             insert!(cm2, windowname, pos, build(c, cm2, new_cell, cells,
              windowname))
         end
         push!(buttonbox, b)
     end
     buttonbox
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:pkgrepl},
    cells::Vector{Cell}, windowname::String)
    cell.source = ""
    keybindings = c[:OliveCore].client_data[getip(c)]["keybindings"]
    km = ToolipsSession.KeyMap()
    outside = div("cellcontainer$(cell.id)", class = "cell")
    output = div("cell$(cell.id)out")
    style!(outside, "display" => "flex")
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = "")
    bind!(km, "Backspace") do cm2::ComponentModifier
        if cm2["rawcell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell(pos, "code", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm2, outside)
            built = build(c, cm2, new_cell, cells, windowname)
            ToolipsSession.insert!(cm2, windowname, pos, built)
            focus!(cm2, "cell$(cell.id)")
        end
    end
    bind!(km, keybindings[:evaluate] ...) do cm2::ComponentModifier
        mod = c[:OliveCore].open[getip(c)].open[windowname][:mod]
        rt = cm2["rawcell$(cell.id)"]["text"]
        commandarg = split(rt, " ")
        if length(commandarg) == 2
            evalstr = "Pkg.$(commandarg[1])(\"$(commandarg[2])\""
            if contains(commandarg[2], "http")
                evalstr = "Pkg.$(commandarg[1])(url = \"$(commandarg[2])\""
            end
            if contains(commandarg[2], "#")
                l = length(commandarg[2])
                revision = commandarg[2][findfirst("#", commandarg[2])[1] + 1:l]
                evalstr = evalstr * ", rev = \"$(revision)\""
            end
            if contains(commandarg[2], "@")
                l = length(commandarg[2])
                version = commandarg[2][findfirst("@", commandarg[2])[1] + 1:l]
                evalstr = evalstr * ", version = \"$(version)\""
            end
            evalstr = evalstr * ")"
            mod.evalin(Meta.parse(evalstr))
            cell.source = cell.source * "\n" * evalstr
            cell.outputs = cell.outputs * "\n" * evalstr
            set_text!(cm2, output, cell.outputs)
        else
            olive_notify!(cm2, "Pkg: invalid usage '$(commandarg[1])'", color = "blue")
        end
    end
    bind!(km, keybindings[:up] ...) do cm2::ComponentModifier
        cell_up!(c, cm2, cell, cells, windowname)
    end
    bind!(km, keybindings[:down] ...) do cm2::ComponentModifier
        cell_down!(c, cm2, cell, cells, windowname)
    end
    bind!(km, keybindings[:delete] ...) do cm2::ComponentModifier
        cell_delete!(c, cm2, cell, cells)
    end
    bind!(km, keybindings[:new] ...) do cm2::ComponentModifier
        cell_new!(c, cm2, cell, cells, windowname)
    end
    sidebox = div("cellside$(cell.id)")
    style!(sidebox, "display" => "inline-block",
    "background-color" => "blue",
    "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px,
    "overflow" => "hidden")
    pkglabel =  a("$(cell.id)pkglabel", text = "pkg>")
    style!(pkglabel, "font-weight" => "bold", "color" => "white")
    push!(sidebox, pkglabel)
    style!(inside, "width" => 80percent, "border-bottom-left-radius" => 0px,
    "border-top-left-radius" => 0px,
    "min-height" => 50px, "display" => "inline-block",
     "margin-top" => 0px, "font-weight" => "bold",
     "background-color" => "blue", "color" => "white")
    push!(outside, sidebox, inside, output)
    bind!(c, cm, inside, km)
    outside
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:shell},
    cells::Vector{Cell})
    keybindings = c[:OliveCore].client_data[getip(c)]["keybindings"]

end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    cells::Vector{Cell}, windowname::String)
    keybindings = c[:OliveCore].client_data[getip(c)]["keybindings"]
    km = ToolipsSession.KeyMap()
    io = IOBuffer()
    highlight(io, MIME("text/html"), cell.source, Lexers.JuliaLexer)
    outside = div("cellcontainer$(cell.id)", class = "cell")
    inside = ToolipsDefaults.textdiv("cell$(cell.id)",
    text = replace(cell.source, "\n" => "</br>"), "class" => "input_cell")
    style!(inside,
    "width" => 90percent, "border-bottom-left-radius" => 0px, "min-height" => 50px,
    "position" => "relative", "margin-top" => 0px, "display" => "inline-block",
    "border-top-left-radius" => 0px, "color" => "white", "caret-color" => "gray")
    inputbox = div("cellinput$(cell.id)")
    style!(inputbox, "padding" => 0px, "width" => 90percent,
    "overflow" => "hidden", "border-top-left-radius" => 0px, "border-bottom-left-radius" => 0px)
    highlight_box = div("cellhighlight$(cell.id)",
    text = String(take!(io)))
    style!(highlight_box, "position" => "absolute",
    "background" => "transparent", "z-index" => "5", "padding" => 0px,
    "font-size" => 16pt, "pointer-events" => "none", "width" => 80percent,
    "margin-left" => 20px, "width" => 90percent)
    push!(inputbox, highlight_box, inside)
    style!(outside, "transition" => 1seconds)
    on(c, cm, inside, "input", ["rawcell$(cell.id)", "cell$(cell.id)"]) do cm::ComponentModifier
        curr = cm["cell$(cell.id)"]["text"]
        currraw = cm["rawcell$(cell.id)"]["text"]
        if currraw == "]"
            pos = findall(lcell -> lcell.id == cell.id, cells)[1]
            new_cell = Cell(pos, "pkgrepl", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm, outside)
            ToolipsSession.insert!(cm, windowname, pos, build(c, cm, new_cell,
             cells, windowname))
            focus!(cm, "cell$(cell.id)")
        elseif currraw == ";"
            olive_notify!(cm, "bash cells not yet available!", color = "red")
        elseif currraw == "\\"
            olive_notify!(cm, "olive cells not yet available!", color = "red")
        elseif currraw == "?"
            pos = findall(lcell -> lcell.id == cell.id, cells)[1]
            new_cell = Cell(pos, "helprepl", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm, outside)
            ToolipsSession.insert!(cm, windowname, pos, build(c, cm, new_cell,
             cells, windowname))
            focus!(cm, "cell$(cell.id)")
        end
        io = IOBuffer()
        highlight(io, MIME("text/html"), curr, Lexers.JuliaLexer)
        set_text!(cm, highlight_box, String(take!(io)))
        cell.source = curr
    end
    interiorbox = div("cellinterior$(cell.id)")
    style!(interiorbox, "display" => "flex")
    sidebox = div("cellside$(cell.id)")
    style!(sidebox, "display" => "inline-block", "background-color" => "pink",
    "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px,
    "overflow" => "hidden")
    push!(interiorbox, sidebox, inputbox)
    cell_drag = topbar_icon("cell$(cell.id)drag", "drag_indicator")
    cell_run = topbar_icon("cell$(cell.id)drag", "play_arrow")
    push!(sidebox, cell_drag, br(), cell_run)
    style!(cell_drag, "color" => "white", "font-size" => 17pt)
    style!(cell_run, "color" => "white", "font-size" => 17pt)
    output = divider("cell$(cell.id)out", class = "output_cell", text = cell.outputs)
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
            evaluate(c, cell, cm3, windowname)
            pos = findall(lcell -> lcell.id == cell.id, cells)[1]
            pos = findall(lcell -> lcell.id == cell.id, cells)[1]
            if pos == length(cells)
                new_cell = Cell(length(cells) + 1, "code", "", id = ToolipsSession.gen_ref())
                push!(cells, new_cell)
                append!(cm3, windowname, build(c, cm3, new_cell, cells, windowname))
                focus!(cm3, "cell$(new_cell.id)")
                set_children!(cm3, sidebox, [cell_drag, br(), cell_run])
                return
            end
            next_cell = cells[pos + 1]
            focus!(cm3, "cell$(next_cell.id)")
            set_children!(cm3, sidebox, [cell_drag, br(), cell_run])
        end
    end
    bind!(km, keybindings[:up] ...) do cm2::ComponentModifier
        cell_up!(c, cm2, cell, cells, windowname)
    end
    bind!(km, keybindings[:down] ...) do cm2::ComponentModifier
        cell_down!(c, cm2, cell, cells, windowname)
    end
    bind!(km, keybindings[:delete] ...) do cm2::ComponentModifier
        cell_delete!(c, cm2, cell, cells)
    end
    bind!(km, keybindings[:new] ...) do cm2::ComponentModifier
        cell_new!(c, cm2, cell, cells, windowname)
    end
    bind!(c, cm, inside, km)
    outside
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    cells::Vector{Cell}, windowname::String)
    keybindings = c[:OliveCore].client_data[getip(c)]["keybindings"]
    km = ToolipsSession.KeyMap()
    tlcell = div("cellcontainer$(cell.id)", class = "cell")
    style!(tlcell, "border-width" => 2px, "border-style" => "solid",
    "min-height" => 2percent)
    innercell = tmd("cell$(cell.id)", cell.source)
    style!(innercell, "min-hight" => 2percent)
    on(c, cm, tlcell, "dblclick") do cm::ComponentModifier
        set_text!(cm, innercell, replace(cell.source, "\n" => "</br>"))
        cm["olivemain"] = "cell" => string(cell.n)
        cm[innercell] = "contenteditable" => "true"
    end
    bind!(km, keybindings[:evaluate] ...) do cm2::ComponentModifier
        cell.source = cm2[innercell]["text"]
        evaluate(c, cell, cm2, windowname)
    end
    bind!(km, keybindings[:up] ...) do cm2::ComponentModifier
        cell_up!(c, cm2, cell, cells, windowname)
    end
    bind!(km, keybindings[:down] ...) do cm2::ComponentModifier
        cell_down!(c, cm2, cell, cells, windowname)
    end
    bind!(km, keybindings[:delete] ...) do cm2::ComponentModifier
        cell_delete!(c, cm2, cell, cells)
    end
    bind!(km, keybindings[:new] ...) do cm2::ComponentModifier
        cell_new!(c, cm2, cell, cells, windowname, type = "markdown")
    end
    bind!(c, cm, tlcell, km)
    tlcell[:children] = [innercell]
    tlcell
end


function build(c::Connection, cell::Cell{:ipynb},
    d::Directory{<:Any}; explorer::Bool = false)
    filecell = div("cell$(cell.id)", class = "cell-ipynb")
    on(c, filecell, "dblclick") do cm::ComponentModifier
        evaluate(c, cell, cm)
    end
    fname = a("$(cell.source)", text = cell.source)
    style!(fname, "color" => "white", "font-size" => 15pt)
    push!(filecell, fname)
    filecell
end

function dir_returner(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any};
    explorer::Bool = false)
    returner = div("cell$(cell.id)", class = "cell-jl")
    style!(returner, "background-color" => "red")
    name = a("cell$(cell.id)label", text = "...")
    style!(name, "color" => "white")
    push!(returner, name)
    on(c, returner, "dblclick") do cm2::ComponentModifier
        newcells = directory_cells(d.uri)
        n_dir::String = d.uri
        built = [build(c, cel, d, explorer = explorer) for cel in newcells]
        if typeof(d) == Directory{:subdir}
            n_dir = d.access["toplevel"]
            if n_dir != d.uri
                newd = Directory(n_dir, "root" => "rw",
                "toplevel" => d.access["toplevel"], dirtype = "subdir")
                insert!(built, 1, dir_returner(c, cell, newd))
            end
        end
        becell = replace(n_dir, "/" => "|")
        nbcell = replace(d.uri, "/" => "|")
        cm2["$(becell)cells"] = "sel" => nbcell
        set_children!(cm2, "$(becell)cells",
        Vector{Servable}(built))
    end
    returner::Component{:div}
end

function build(c::Connection, cell::Cell{:dir}, d::Directory{<:Any};
    explorer::Bool = false)
    filecell = div("cell$(cell.id)", class = "cell-ipynb")
    style!(filecell, "background-color" => "#FFFF88")
    on(c, filecell, "dblclick") do cm::ComponentModifier
        returner = dir_returner(c, cell, d, explorer = explorer)
        nuri::String = "$(d.uri)/$(cell.source)"
        newcells = directory_cells(nuri)
        becell = replace(d.uri, "/" => "|")
        nbecell = replace(nuri, "/" => "|")
        cm["$(becell)cells"] = "sel" => nbecell
        toplevel = d.uri
        if typeof(d) == Directory{:subdir}
            toplevel = d.access["toplevel"]
        end
        nd = Directory(d.uri * "/" * cell.source * "/", "root" => "rw",
        "toplevel" => toplevel, dirtype = "subdir")
        set_children!(cm, "$(becell)cells",
        Vector{Servable}(vcat([returner],
        [build(c, cel, nd, explorer = explorer) for cel in newcells])))
    end
    fname = a("$(cell.source)", text = cell.source)
    style!(fname, "color" => "gray", "font-size" => 15pt)
    push!(filecell, fname)
    filecell
end

function build(c::Connection, cell::Cell{:jl},
    d::Directory{<:Any}; explorer::Bool = false)
    hiddencell = div("cell$(cell.id)", class = "cell-jl")
    style!(hiddencell, "cursor" => "pointer")
    if explorer
        on(c, hiddencell, "dblclick") do cm::ComponentModifier
            cs::Vector{Cell{<:Any}} = IPy.read_jl(cell.outputs)
            add_to_session(c, cs, cm, cell.source, cell.outputs)
        end
    else
        on(c, hiddencell, "dblclick") do cm::ComponentModifier
            cs::Vector{Cell{<:Any}} = IPy.read_jl(cell.outputs)
            load_session(c, cs, cm, cell.source, cell.outputs, d)
        end
    end
    name = a("cell$(cell.id)label", text = cell.source)
    style!(name, "color" => "white")
    push!(hiddencell, name)
    hiddencell
end

function build(c::Connection, cell::Cell{:toml},
    d::Directory; explorer::Bool = false)
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

function evaluate(c::Connection, cell::Cell{:code}, cm::ComponentModifier,
    window::String)
    # get code
    rawcode::String = cm["cell$(cell.id)"]["text"]
    execcode::String = *("begin\n", rawcode, "\nend\n")
    # get project
    selected::String = cm["olivemain"]["selected"]
    proj::Project{<:Any} = c[:OliveCore].open[getip(c)]
    ret::Any = ""
    p = Pipe()
    err = Pipe()
   redirect_stdio(stdout = p, stderr = err) do
        try
            ret = proj.open[window][:mod].evalin(Meta.parse(execcode))
        catch e
            ret = e
        end
    end
    close(err)
    close(Base.pipe_writer(p))
    standard_out = read(p, String)
    close(p)
    # output
    outp::String = ""
    od = OliveDisplay()
    if typeof(ret) <: Exception
        Base.showerror(od.io, ret)
        outp = replace(String(od.io.data), "\n" => "</br>")
    elseif ~(isnothing(ret)) && length(standard_out) > 0
        display(od, MIME"olive"(), ret)
        outp = standard_out * "</br>" * String(od.io.data)
    elseif ~(isnothing(ret)) && length(standard_out) == 0
        display(od, MIME"olive"(), ret)
        outp = String(od.io.data)

    else
        outp = standard_out
    end
    set_text!(cm, "cell$(cell.id)out", outp)
    cell.outputs = outp
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

function evaluate(c::Connection, cell::Cell{:markdown}, cm::ComponentModifier,
    window::String)
    activemd = cm["cell$(cell.id)"]["text"]
    cell.source = activemd
    newtmd = tmd("cell$(cell.id)tmd", activemd)
    set_text!(cm, "cell$(cell.id)", newtmd[:text])
    cm["cell$(cell.id)"] = "contenteditable" => "false"
end

function evaluate(c::Connection, cell::Cell{:ipynb}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_ipynb(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function directory_cells(dir::String = pwd(), access::Pair{String, String} ...)
    files = readdir(dir)
    return([build_file_cell(e, path, dir) for (e, path) in enumerate(files)]::AbstractVector)
end

function build_file_cell(e::Int64, path::String, dir::String)
    if ~(isdir(dir * "/" * path))
        splitdir::Vector{SubString} = split(path, "/")
        fname::String = string(splitdir[length(splitdir)])
        fsplit = split(fname, ".")
        fending::String = ""
        if length(fsplit) > 1
            fending = string(fsplit[2])
        end
        Cell(e, fending, fname, dir * "/" * path)
    else
        Cell(e, "dir", path, dir)
    end
end
