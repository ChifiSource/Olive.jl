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

function build(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    cells::Vector{Cell})
    keybindings = c[:OliveCore].client_data[getip(c)][:keybindings]
    km = ToolipsSession.KeyMap()
    text = replace(cell.source, "\n" => "</br>")
#==    tm = TextModifier(text)
    ToolipsMarkdown.julia_block!(tm)
    ==#
    outside = div("cellcontainer$(cell.n)", class = cell)
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = text)
    on(c, cm, inside, "change") do cm::ComponentModifier
        cell.source = cm[inside]["text"]
    end
    maininputbox = div("maininputbox")
    style!(maininputbox, "width" => 60percent, "padding" => 0px)
    interiorbox = div("cellinterior$(cell.n)")
    inside[:class] = "input_cell"
    # bottom box
    bottombox = div("cellside$(cell.n)")
    cell_drag = topbar_icon("cell$(cell.id)drag", "drag_indicator")
    cell_run = topbar_icon("cell$(cell.id)drag", "not_started")
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
        println("hi")
        evaluate(c, cell, cm2)
        new_cell = Cell(length(cells) + 1, "code", "", id = ToolipsSession.gen_ref())
    #==    push!(cells, new_cell)
       set_children!(cm, "olivemain",
       Vector{Servable}([build(c, cm, cel) for cel in cells]))
       focus!(cm, "cell$(new_cell.n)") ==#
    end
    bind!(km, keybindings[:delete] ...) do cm::ComponentModifier
        remove!(cm, "cellcontainer$(cell_selected.n)")
        deleteat!(cells, findall(c -> c.id == selected, cells)[1])
    end
    bind!(km, keybindings[:new] ...) do cm::ComponentModifier
        newcell = Cell(length(cells) + 1, "code", "",
        id = ToolipsSession.gen_ref())
        push!(cells, newcell)
        append!(cm, "olivemain", build(c, cm, newcell, cells))
        println("appended")
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

function build(c::Connection, cm::ComponentModifier, cell::Cell{:setup})
    maincell = section("cell$(cell.id)", align = "center")
    push!(maincell, olive_cover())
    maincell
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:filebrowser})

end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:dirselector})

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
    i = fdio(1)
    try
        ret = proj.mod.evalin(Meta.parse(execcode), i)
    catch e
        ret = e
    end
    # output
    od = OliveDisplay()
    display(od, MIME"olive"(), ret)
    outp::String = String(take!(i)) * String(od.io.data)
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
