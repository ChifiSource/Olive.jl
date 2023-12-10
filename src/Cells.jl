"""
# welcome to Cells.jl
This file creates the basis for Olive.jl cells then builds olive cell types
 on  top of it. 
- Cell controls
- Directory cells
- Session cells (markdown, code, TODO, NOTE, creator)
- REPL Cells (pkgrepl, helprepl, shellrepl, oliverepl)
- Environment cells (module cells, include cells)
- Filebrowsing
"""
#==|||==#
function cell_up!(c::Connection, cm2::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any})
    cells = proj[:cells]
    windowname::String = proj.id
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    if pos != 1
        switchcell = cells[pos - 1]
        remove!(cm2, "cellcontainer$(switchcell.id)")
        remove!(cm2, "cellcontainer$(cell.id)")
        ToolipsSession.insert!(cm2, windowname, pos - 1, build(c, cm2, switchcell, proj))
        ToolipsSession.insert!(cm2, windowname, pos - 1, build(c, cm2, cell, proj))
        focus!(cm2, "cell$(cell.id)")
        cells[pos] = switchcell
        cells[pos - 1] = cell
    else
        olive_notify!(cm2, "this cell cannot go up any further!", color = "red")
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_down!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any})
    cells = proj[:cells]
    windowname::String = proj.id
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    if pos != length(cells)
        switchcell = cells[pos + 1]
        remove!(cm, "cellcontainer$(switchcell.id)")
        remove!(cm, "cellcontainer$(cell.id)")
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, switchcell, proj))
        ToolipsSession.insert!(cm, windowname, pos + 1, build(c, cm, cell, proj))
        focus!(cm, "cell$(cell.id)")
        cells[pos] = switchcell
        cells[pos + 1] = cell
    else
        olive_notify!(cm, "this cell cannot go down any further!", color = "red")
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_delete!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}})
    if length(cells) == 1
        olive_notify!(cm, "you cannot the last cell in the project", color = "red")
        return
    end
    pos = findfirst(c -> c.id == cell.id, cells)
    remove!(cm, "cellcontainer$(cell.id)")
    deleteat!(cells, pos)
    if pos == 1
        focus!(cm, "cell$(cells[pos + 1].id)")
    else
        focus!(cm, "cell$(cells[pos - 1].id)")
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_new!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any}; type::String = "creator")
    windowname::String = proj.id
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    newcell = Cell(pos, type, "")
    insert!(cells, pos + 1, newcell)
    ToolipsSession.insert!(cm, windowname, pos + 1, build(c, cm, newcell,
    proj))
    focus!(cm, "cell$(newcell.id)")
    cm["cell$(newcell.id)"] = "contenteditable" => "true"
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function focus_up!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any}, 
    proj::Project{<:Any})
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    i = findfirst(cel::Cell{<:Any} -> cel.id == cell.id, cells)
    if i == 1 || isnothing(i)
        return
    end
    focus!(cm, "cell$(cells[i - 1].id)")
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function focus_down!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any})
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    i = findfirst(cel::Cell{<:Any} -> cel.id == cell.id, cells)
    if i == length(cells) || isnothing(i)
        return
    end
    focus!(cm, "cell$(cells[i + 1].id)")
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function bind!(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any})

end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
### Olive Cells
```
build_base_cell(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any};
explorer::Bool = false)
```
------------------
This is a callable build function that can be used to create a base file cell.
#### example
```

```
"""
function build_base_cell(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any})
    hiddencell = div("cell$(cell.id)")
    hiddencell["class"] = "file-cell"
    name = a("cell$(cell.id)label", text = cell.source, contenteditable = true)
    on(c, name, "dblclick", ["none"]) do cm
        km = ToolipsSession.KeyMap()
        bind!(km, "Enter", [name.name]) do cm2
            fname = replace(cm2[name]["text"], "\n" => "")
            ps = split(cell.outputs, "/")
            nps = ps[1:length(ps) - 1]
            push!(nps, SubString(fname))
            joined = join(nps, "/")
            cp(cell.outputs, joined)
            rm(cell.outputs)
            cell.outputs = joined
            cell.source = fname
            olive_notify!(cm2, "file renamed", color = "green")
            cm2[name] = "contenteditable" => "false"
            set_text!(cm2, name, fname)
        end
        bind!(c, cm, name, km)
        cm[name] = "contenteditable" => "true"
        set_text!(cm, name, "")
        focus!(cm, name)
    end
    outputfmt = "b"
    fs = filesize(cell.outputs)
    if fs > Int64(1e+9)
        outputfmt = "gb"
        fs = round(fs / Int64(1e+9))
    elseif fs > 1000000
        outputfmt = "mb"
        fs = round(fs / 1000000)
    elseif fs > 1000
        outputfmt = "kb"
        fs = round(fs / 1000)
    end
    on(c, hiddencell, "dblclick", ["none"]) do cm::ComponentModifier
        cs::Vector{Cell{<:Any}} = olive_read(cell)
        add_to_session(c, cs, cm, cell.source, cell.outputs)
    end
    finfo = a("cell$(cell.id)info", text =  string(fs) * outputfmt)
    style!(finfo, "color" => "white", "float" => "right", "font-weight" => "bold")
    delbutton = topbar_icon("$(cell.id)expand", "cancel")
    copyb = topbar_icon("copb$(cell.id)", "copy")
    on(c, delbutton, "click", ["none"]) do cm::ComponentModifier
        rm(cell.outputs)
        olive_notify!(cm, "file deleted", color = "red")
        remove!(cm, hiddencell)
    end
    on(c, copyb, "click", ["none"]) do cm::ComponentModifier
        copy_file!(c, cm, d, cell.outputs)
    end
    movbutton = topbar_icon("$(cell.id)move", "drive_file_move")
    on(c, movbutton, "click") do cm::ComponentModifier
        switch_work_dir!(c, cm, d.uri)
        namebox = ToolipsDefaults.textdiv("new_namebox", text = cell.source)
        style!(namebox, "width" => 25percent)
        savebutton = button("confirm_new", text = "confirm")
        cancelbutton = button("cancel_new", text = "cancel")
        on(c, savebutton, "click") do cm2::ComponentModifier
            finalname = cm2[namebox]["text"]
            path = cm2["selector"]["text"]
            try
                mv(cell.outputs, path * "/" * finalname, force = true)
            catch e
                println(e)
                olive_notify!(cm2, "failed to move $finalname", color = "red")
            end
            set_children!(cm2, "fileeditbox", [namebox, cancelbutton, savebutton])
            style!(cm2, "fileeditbox", "opacity" => 0percent, "height" => 0percent)
        end
        on(c, cancelbutton, "click") do cm2::ComponentModifier
            set_children!(cm2, "fileeditbox", Vector{Servable}())
            style!(cm2, "fileeditbox", "opacity" => 100percent, "height" => 6percent)
        end
        set_children!(cm, "fileeditbox", [namebox, cancelbutton, savebutton])
        style!(cm, "fileeditbox", "opacity" => 100percent, "height" => 6percent)
    end
    style!(delbutton, "color" => "white", "font-size" => 17pt)
    style!(movbutton, "color" => "white", "font-size" => 17pt)
    style!(copyb, "color" => "white", "font-size" => 17pt)
    style!(name, "color" => "white", "font-weight" => "bold",
    "font-size" => 14pt, "margin-left" => 5px)
    push!(hiddencell, delbutton, movbutton, copyb, name, finfo)
    hiddencell
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
### Olive Cells
````
build(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any}) -> ::Component{:div}
````
------------------
The catchall/default `build` function for directory cells. This function is what
creates the gray boxes for files that Olive cannot read inside of directories.
Using this function as a template, you can create your own directory cells.
Write a new method for this function in order to build cells for a new
file type. Note that you might also want to extend `olive_save` in order
to save your new file type. Bind `dblclick` and use the `load_session` or
`add_to_session` methods, dependent on `explorer`... Which should also be `false`
by default. `directory_cells` will put the file path into `cell.outputs` and
the file name into `cell.source`.
#### example
```
```
Here are some other **important** functions to look at for creating file cells:
- `build_base_cell`
- `evaluate`
- `olive_save`
- `olive_read`
"""
function build(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any};
    explorer::Bool = false)
    hiddencell = build_base_cell(c, cell, d)
    style!(hiddencell, "background-color" => "white")
    name = a("cell$(cell.id)label", text = cell.source)
    style!(name, "color" => "black")
    push!(hiddencell, name)
    hiddencell
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_read(cell::Cell{<:Any})
    src = read(cell.outputs, String)
    [begin 
        Cell(e, "txt", string(cellsource)) 
    end for (e, cellsource) in enumerate(split(src, "\n\n"))]
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_read(cell::Cell{:jl})
    IPyCells.read_jl(cell.outputs)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_read(cell::Cell{:ipynb})
    IPyCells.read_ipynb(cell.outputs)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_read(cell::Cell{:toml})
    read_toml(cell.outputs)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
"""
mutable struct ProjectExport{T <: Any} end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
### Olive Cells
```
olive_save(cells::Vector{Cell}, p::Project{<:Any}, ProjectExport{<:Any}) -> ::Nothing
````
------------------
Saves the project to the `path` inside of its data. This function can be extended to export to 
multiple new formats by providing a new `ProjectExport`
#### example
```
cells = IPyCells.read_jl("myfolder/myjl.jl")
filecell = Cell(1, "jl", "myjl.jl", "myfolder/myjl.jl")
olive_save(cells, filecell) # saves `cells` to "myfolder/myjl.jl"
```
"""
function olive_save(cells::Vector{<:IPyCells.AbstractCell}, p::Project{<:Any}, 
    pe::ProjectExport{<:Any})
    open(p.data[:path], "w") do io
        [write(io, string(cell.source) * "\n") for cell in p.data[:cells]]
    end
    nothing
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_save(cells::Vector{<:IPyCells.AbstractCell}, p::Project{<:Any}, 
    pe::ProjectExport{:jl})
    IPyCells.save(cells, p.data[:path])
    nothing
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_save(cells::Vector{<:IPyCells.AbstractCell}, p::Project{<:Any}, 
    pe::ProjectExport{:ipynb})
    IPyCells.save_ipynb(cells, p.data[:path])
    nothing
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_save(cells::Vector{<:IPyCells.AbstractCell}, p::Project{<:Any}, 
    pe::ProjectExport{:toml})
    joinedstr = join([toml_string(cell) for cell in cells])
    ret = ""
    try
        ret = TOML.parse(joinedstr * "\n")
    catch e
        return "TOML parse error: $(e)"
    end
    open(p[:path], "w") do io
        TOML.print(io, ret)
    end
    nothing
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function directory_cells(dir::String = pwd(), access::Pair{String, String} ...; pwd::Bool = false)
    files = readdir(dir)
    return(filter!(e -> ~(isnothing(e)), [build_file_cell(e, path, dir, pwd = pwd) for (e, path) in enumerate(files)]::AbstractVector))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build_file_cell(e::Int64, path::String, dir::String; pwd::Bool = false)
    fpath = dir * "/" * path
    if ~(isdir(fpath))
        if isfile(fpath)
            splitdir::Vector{SubString} = split(path, "/")
            fname::String = string(splitdir[length(splitdir)])
            fsplit = split(fname, ".")
            fending::String = ""
            if length(fsplit) > 1
                fending = string(fsplit[2])
            end
            Cell(e, fending, fname, replace(dir * "/" * path, "\\" => "/"))
        else
            return
        end
    else
        if pwd
            Cell(e, "switchdir", path, dir)
        else
            Cell(e, "dir", path, dir)
        end
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cell::Cell{:dir}, d::Directory{<:Any}; bind::Bool = true)
    container = div("cellcontainer$(cell.id)")
    style!(container, "border-radius" => 0px)
    filecell = build_base_cell(c, cell, d)
    filecell[:ex] = "0"
    childbox = div("child$(cell.id)")
    style!(container, "padding" => 0px, "margin-bottom" => 0px, "overflow" => "visible", "border-radius" => 0px)
    style!(childbox, "opacity" => 0percent, "margin-left" => 7px, "border-left-width" => 1px, 
    "border-bottom-width" => 1px, "border-radius" => 0px,
    "border-color" => "darkblue", "height" => 0percent, 
    "border-width" => 0px, "transition" => "600ms", "padding" => 0px, "overflow" => "visible")
    style!(filecell, "background-color" => "#18191A")
    if bind
        on(c, filecell, "click", [filecell.name]) do cm::ComponentModifier
            childs = Vector{Servable}([begin
            build(c, mcell, d)
            end
            for mcell in directory_cells(cell.outputs * "/" * cell.source)])
            if cm[filecell]["ex"] == "0"
                adjust = 40 * length(childs)
                if adjust == 0
                    adjust = 40
                end
                adjust += 60
                style!(cm, childbox, "height" => "$(adjust)px", "opacity" => 100percent)
                set_children!(cm, childbox, childs)
                cm[filecell] = "ex" => "1"
                return
            end
            style!(cm, childbox, "opacity" => 0percent, "height" => 0percent)
            cm[filecell] = "ex" => "0"
        end
    end
    push!(container, filecell, childbox)
    container
end

function build(c::Connection, cell::Cell{:switchdir}, d::Directory{<:Any}, bind::Bool = true)
    filecell = build_base_cell(c, cell, d)
    style!(filecell, "background-color" => "#18191A")
    if bind
        on(c, filecell, "click", ["none"]) do cm::ComponentModifier
            switch_work_dir!(c, cm, cell.outputs * "/" * cell.source)
        end
    end
    filecell
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cell::Cell{:ipynb},
    d::Directory{<:Any})
    filecell = build_base_cell(c, cell, d)
    style!(filecell, "background-color" => "#FD5800")
    filecell
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#

#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cell::Cell{:jl},
    d::Directory{<:Any})
    hiddencell = build_base_cell(c, cell, d)
    style!(hiddencell, "background-color" => "#AA104F")
    style!(hiddencell, "cursor" => "pointer")
    hiddencell
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#

#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function read_toml(path::String)
    concat::String = ""
    file::String = read(path, String)
    lines = split(file, "\n")
    filter!(cell -> ~(isnothing(cell)), [begin
        n = length(line)
        if e == length(lines)
            concat = concat * line
            Cell(e, "tomlvalues", concat)
        elseif length(line) > 1
            if contains(line[1:3], "[")
                source = concat
                concat = line * "\n"
                Cell(e, "tomlvalues", source)
            else
                concat = concat * line * "\n"
                nothing
            end
        else
            concat = concat * line * "\n"
            nothing
        end
    end for (e, line) in enumerate(lines)])
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cell::Cell{:toml},
    d::Directory)
    hiddencell = build_base_cell(c, cell, d)
    style!(hiddencell, "background-color" => "#000080")
    if cell.source == "Project.toml"
        activatebutton = topbar_icon("$(cell.id)act", "bolt")
        style!(activatebutton, "font-size" => 20pt, "color" => "white")
        on(c, activatebutton, "click") do cm::ComponentModifier
            [begin
                b = button("activate$(proj.id)", text = proj.name)
                on(c, b, "click") do cm2::ComponentModifier
                    modname = proj.id
                    Main.evalin(
                    Meta.parse(olive_module(modname, cell.outputs)))
                    proj.data[:mod] = getfield(Main, Symbol(modname))
                    olive_notify!(cm2, "environment $(cell.outputs) activated",
                    color = "blue")
                        [begin
                            remove!(cm2, "activate$(proj.id)")
                        end for k in c[:OliveCore].open[getname(c)].projects]
                end
                append!(cm, hiddencell, b)
            end for proj in c[:OliveCore].open[getname(c)].projects]
        end
        insert!(hiddencell[:children], 2, activatebutton)
    end
    hiddencell
end

#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
toml_string(cell::Cell{<:Any}) = ""
toml_string(cell::Cell{:tomlvalues}) = cell.source * "\n"
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
#==output[TODO]
Have this `string` below be some kind of writing which may be read back
in and evaluated into a dictionary as Julia.
==#
#==|||==#
string(cell::Cell{:tomlvalues}) = ""
#==output[code]
Session cells
==#
#==|||==#
"""
**Olive Cells**
```
build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
proj::Project{<:Any}) -> ::Component{:div}
```
------------------
The catchall/default `build` function for session cells. This function is what
creates the gray boxes for cells that Olive cannot create.
Using this function as a template, you can create your own olive cells.
#### example
```

```
Also important for cells:
- `cell_bind!`
- `build_base_cell`
- `evaluate`
- `bind!`
- `cell_highlight!`
- `olive_save`
- `string`

And code cells can be extended with
- `on_code_evaluate`
- `on_code_highlight`
- `on_code_build`
"""
function build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any})
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    ToolipsMarkdown.julia_block!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = false)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    sidebox = interior[:children]["cellside$(cell.id)"]
    [style!(child, "color" => "red") for child in sidebox[:children]]
    insert!(builtcell[:children], 1, h("unknown", 3, text = "$(cell.type)"))
    style!(sidebox, "background" => "transparent")
    inp = interior[:children]["cellinput$(cell.id)"]
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km)
    style!(inp[:children]["cell$(cell.id)"], "color" => "black")
    builtcell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
##### Olive Cells
```
evaluate(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
proj::Project{<:Any}) -> ::Nothing
```
------------------
This is the catchall/default function for the evaluation of any cell. Use this
as a template to add evaluation to your cell using the `evaluate` method binding.
If you were to, say bind your cell without using evaluate, the only problem would
be it will not run with the `runall` window button. This function is usually accessed through the cell's 
**sidebox** or the hot-key binding `Shift` + `Enter`. This means that the sidebox from 
`build_base_cell` and the bindings from `cell_bind!` will facilitate this feature so long as 
this method exists.

The process of creating an evaluation extension is simple; get the text from the cell and then 
evaluate it however, providing a return to the cell's outputs. The example below is the `evaluate` 
function for a `txt` cell.
#### example
```
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:txt},
    proj::Project{<:Any})
    cells = proj[:cells]
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    cell.source = cm["cell\$(cell.id)"]["text"]
    if pos != length(cells)
        focus!(cm, "cell\$(cells[pos + 1].id)")
    else
        new_cell = Cell(length(cells) + 1, "txt", "")
        push!(cells, new_cell)
        ToolipsSession.append!(cm, proj.id, build(c, cm, new_cell, proj))
        focus!(cm, "cell\$(new_cell.id)")
    end
    set_text!(cm, "cell\$(cell.id)out", "<sep></sep>")
end
```
"""
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any})
    cells = proj[:cells]
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    cell.source = cm["cell$(cell.id)"]["text"]
    if pos != length(cells)
        focus!(cm, "cell$(cells[pos + 1].id)")
    else
        new_cell = Cell(length(cells) + 1, "creator", "")
        push!(cells, new_cell)
        ToolipsSession.append!(cm, proj.id, build(c, cm, new_cell, proj))
        focus!(cm, "cell$(new_cell.id)")
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:txt},
    proj::Project{<:Any})
    cells = proj[:cells]
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    cell.source = cm["cell$(cell.id)"]["text"]
    if pos != length(cells)
        focus!(cm, "cell$(cells[pos + 1].id)")
    else
        new_cell = Cell(length(cells) + 1, "txt", "")
        push!(cells, new_cell)
        ToolipsSession.append!(cm, proj.id, build(c, cm, new_cell, proj))
        focus!(cm, "cell$(new_cell.id)")
    end
    set_text!(cm, "cell$(cell.id)out", "<sep></sep>")
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
##### Olive Cells
```
cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
proj::Project{<:Any})
```
------------------
The catchall/default highlighting function for cells. Build a base cell using
`build_base_cell`, setting the `highlight` key-word argument to `false`, then
write this function for your cell and it should highlight properly. The example below 
    is a `python` cell implementation from [OlivePy](https://github.com/ChifiSource/OlivePy.jl)
#### example
```
import Olive: cell_highlight!
using Olive: Cell, Project
using Olive.Toolips
using Olive.ToolipsMarkdown
using Olive.ToolipsSession

function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:python}, proj::Project{<:Any})
    curr = cm["cell\$(cell.id)"]["text"]
    cell.source = curr
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    python_block!(tm)
    set_text!(cm, "cellhighlight\$(cell.id)", string(tm))
end
```
"""
function cell_highlight!(c::Connection,   cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any})

end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
##### Olive Cells
```
cell_bind!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
proj::Project{<:Any}) -> ::ToolipsSession.KeyMap
```
------------------
Binds default cell controls, returns keymap to bind to your cell's input.
#### example
```

```
"""
function cell_bind!(c::Connection, cell::Cell{<:Any}, proj::Project{<:Any})
    keybindings = c[:OliveCore].client_data[getname(c)]["keybindings"]
    km = ToolipsSession.KeyMap()
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    bind!(km, keybindings["save"], prevent_default = true) do cm::ComponentModifier
        save_project(c, cm, proj)
    end
    bind!(km, keybindings["saveas"], prevent_default = true) do cm::ComponentModifier
        style!(cm, "projectexplorer", "width" => "500px")
        style!(cm, "olivemain", "margin-left" => "500px")
        style!(cm, "explorerico", "color" => "lightblue")
        set_text!(cm, "explorerico", "folder_open")
        cm["olivemain"] = "ex" => "1"
        save_project_as(c, cm, proj)
    end
    bind!(km, keybindings["focusup"]) do cm::ComponentModifier
        focus_up!(c, cm, cell, proj)
    end
    bind!(km, keybindings["up"]) do cm2::ComponentModifier
        cell_up!(c, cm2, cell, proj)
    end
    bind!(km, keybindings["down"]) do cm2::ComponentModifier
        cell_down!(c, cm2, cell, proj)
    end
    bind!(km, keybindings["delete"]) do cm2::ComponentModifier
        cell_delete!(c, cm2, cell, cells)
    end
    bind!(km, keybindings["evaluate"]) do cm2::ComponentModifier
        icon = olive_loadicon()
        icon.name = "load$(cell.id)"
        icon["width"] = "16"
        append!(cm2, "cellside$(cell.id)", icon)
        script!(c, cm2, "$(cell.id)eval", ["cell$(cell.id)", "cellinput$(cell.id)", "cellside$(cell.id)", "cellhightlight$(cell.id)"], type = "Timeout") do cm::ComponentModifier
            evaluate(c, cm, cell, proj)
            remove!(cm, "load$(cell.id)")
        end
    end
    bind!(km, keybindings["new"]) do cm2::ComponentModifier
        cell_new!(c, cm2, cell, proj)
    end
    bind!(km, keybindings["focusdown"]) do cm::ComponentModifier
        focus_down!(c, cm, cell, proj)
    end
    km::KeyMap
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
##### Olive Cells
```
build_base_input(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
proj::Project{<:Any}; highlight::Bool = false) -> ::Component{:div}
```
------------------
This function builds the base input box of a standard cell with or without highlighting. 
    In most cases, a use-case would be better served by `build_base_cell`, which builds 
    the rest the base `Cell` and calls this function to create the input box.
#### example
```

```
"""
function build_base_input(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any}; highlight::Bool = false)
    windowname::String = proj.id
    inputbox::Component{:div} = div("cellinput$(cell.id)")
    inside::Component{:div} = ToolipsDefaults.textdiv("cell$(cell.id)",
    text = replace(cell.source, "\n" => "</br>", " " => "&nbsp;"),
    "class" => "input_cell", "spellcheck" => false)
    style!(inside, "border-top-left-radius" => 0px)
    if highlight
        highlight_box::Component{:div} = div("cellhighlight$(cell.id)",
        text = "", class = "input_cell")
        style!(highlight_box, "position" => "absolute !important",
        "background" => "transparent", "z-index" => "5", "padding" => 20px,
        "border-top-left-radius" => "0px !important",
        "border-radius" => "0px !important",
        "border-width" =>  0px,  "pointer-events" => "none", "color" => "#4C4646 !important",
        "border-radius" => 0px, "max-width" => 90percent)
        on(c, inputbox, "keyup", ["cell$(cell.id)"]) do cm2::ComponentModifier
            cell_highlight!(c, cm2, cell, proj)
        end
        on(cm, inputbox, "paste") do cl
            push!(cl.changes, """
            e.preventDefault();
            var text = e.clipboardData.getData('text/plain');
            document.execCommand('insertText', false, text);
            """)
        end
        push!(inputbox, highlight_box, inside)
    else
        push!(inputbox, inside)
    end
    inputbox::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
##### Olive Cells
```
build_base_cell(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
proj::Project{<:Any}; highlight::Bool = false, sidebox::Bool = false) -> ::Component{:div}
```
------------------
This function builds a base `Cell` which comes pre-binded using `cell_bind!`. This creates a quick `Cell` that easily 
    fits into the other functions an `Olive` -- a nice starting point to create other cells from.
#### example
```

```
"""
function build_base_cell(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any}; highlight::Bool = false,
    sidebox::Bool = false)
    windowname::String = proj.id
    outside::Component{:div} = div("cellcontainer$(cell.id)", class = "cell")
    style!(outside, "transition" => 2seconds, "width" => 106percent)
    interiorbox::Component{:div} = div("cellinterior$(cell.id)")
    inputbox::Component{:div} = build_base_input(c, cm, cell, proj,
    highlight = highlight)
    output::Component{:div} = divider("cell$(cell.id)out", class = "output_cell", text = cell.outputs)
    if sidebox
        sidebox::Component{:div} = div("cellside$(cell.id)", class = "cellside")
        cell_drag = topbar_icon("cell$(cell.id)drag", "drag_indicator")
        cell_run = topbar_icon("cell$(cell.id)drag", "play_arrow")
        on(c, cell_run, "click") do cm2::ComponentModifier
            evaluate(c, cm2, cell, proj)
        end
        sidebox[:class] = "cellside"
        style!(cell_drag, "color" => "white", "font-size" => 17pt)
        style!(cell_run, "color" => "white", "font-size" => 17pt)
        push!(sidebox, cell_drag, br(), cell_run)
        push!(interiorbox, sidebox, inputbox)
    else
        push!(interiorbox, inputbox)
    end
    # TODO move these styles to stylesheet
    style!(inputbox, "padding" => 0px, "width" => 100percent, "overflow-x" => "hidden",
    "overflow" => "hidden", "border-top-left-radius" => "0px",
    "border-bottom-left-radius" => 0px, "border-radius" => "0px",
    "position" => "relative", "height" => "auto")
    style!(interiorbox, "display" => "flex", "width" => "auto", "overflow" => "hidden")
    push!(outside, interiorbox, output)
    outside::Component{:div}
end

function build_base_replcell(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any}; repl::String = "pkg>", replc::String = "#301934", sideboxc::String = "blue", lblc::String = "white")
    outside::Component{:div} = div("cellcontainer$(cell.id)", class = "cell")
    output::Component{:div} = div("cell$(cell.id)out")
    interior::Component{:div} = div("cellinterior$(cell.id)")
    km::ToolipsSession.KeyMap = cell_bind!(c, cell, proj)
    style!(interior, "display" => "flex")
    inside::Component{:div} = ToolipsDefaults.textdiv("cell$(cell.id)", text = cell.outputs)
    bind!(km, "Enter") do cm2::ComponentModifier
        realevaluate(c, cm2, cell, proj)
    end
    sidebox::Component{:div} = div("cellside$(cell.id)")
    style!(sidebox, "display" => "inline-block",
    "background-color" => sideboxc,
    "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px,
    "overflow" => "hidden", "border-width" => 2px, "border-style" => "solid")
    pkglabel::Component{:a} =  a("$(cell.id)pkglabel", text = repl)
    style!(pkglabel, "font-weight" => "bold", "color" => lblc)
    push!(sidebox, pkglabel)
    style!(inside, "width" => 80percent, "border-bottom-left-radius" => 0px,
    "border-top-left-radius" => 0px,
    "min-height" => 50px, "display" => "inline-block",
     "margin-top" => 0px, "font-weight" => "bold",
     "background-color" => repl, "color" => "white", "border-width" => 2px,
     "border-style" => "solid")
    push!(interior, sidebox, inside)
    push!(outside, interior, output)
    bind!(c, cm, inside, km, ["cell$(cell.id)"])
    outside::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    proj::Project{<:Any})
    windowname::String = proj.id
    tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["julia"]
    tm.raw = cell.source
    ToolipsMarkdown.mark_julia!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = true)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    inp[:children]["cellhighlight$(cell.id)"][:text] = string(tm)
    sideb = interior[:children]["cellside$(cell.id)"]
    style!(sideb, "background-color" => "pink")
    ToolipsMarkdown.clear!(tm)
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km, ["cell$(cell.id)", "cellinput$(cell.id)", "cellside$(cell.id)", "cellhightlight$(cell.id)"], on = :down)
    [begin
        xtname = m.sig.parameters[4]
        if xtname != OliveExtension{<:Any}
            ext = xtname()
            on_code_build(c, cm, ext, cell, proj, builtcell)
        end
    end for m in methods(on_code_build)]
    builtcell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
##### Olive Cells
```
on_code_evaluate(c::Connection, cm::ComponentModifier, oe::OliveExtension{<:Any},
cell::Cell{:code}, proj::Project{<:Any}) -> ::Nothing
```
------------------
This is the stub function for `on_code_evaluate`. This method is only used to denote the existence of this function. 
    Each time a `code` cell is evaluated, every method for this function is ran. This allows you to extend `code` cells 
    by importing and explicitly extending them.
#### example
```
using Olive
import Olive: on_code_evaluate, on_code_highlight, on_code_build

function on_code_evaluate(c::Olive.Toolips.Connection, cm::Olive.ToolipsSession.ComponentModifier, oe::Olive.OliveExtension{:myeval},
 cell::Cell{:code}, proj::Olive.Project{<:Any})
    Olive.olive_notify!(cm, "hello")
end
```
"""
function on_code_evaluate(c::Connection, cm::ComponentModifier, oe::OliveExtension{<:Any}, 
    cell::Cell{:code}, proj::Project{<:Any})

end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
##### Olive Cells
```
on_code_highlight(c::Connection, cm::ComponentModifier, oe::OliveExtension{<:Any},
cell::Cell{:code}, proj::Project{<:Any}) -> ::Nothing
```
------------------
This is the stub function for `on_code_evaluate`. This method is only used to denote the existence of this function. 
    Each time a `code` cell is typed into, every method for this function is ran. This allows you to extend `code` cells 
    by importing and explicitly extending them.
#### example
```
using Olive
import Olive: on_code_evaluate, on_code_highlight, on_code_build

function on_code_highlight(c::Olive.Toolips.Connection, cm::Olive.ToolipsSession.ComponentModifier, oe::Olive.OliveExtension{:myeval},
 cell::Cell{:code}, proj::Olive.Project{<:Any})
    Olive.olive_notify!(cm, "hello")
end
```
"""
function on_code_highlight(c::Connection, cm::ComponentModifier, oe::OliveExtension{<:Any}, 
    cell::Cell{:code}, proj::Project{<:Any})

end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
##### Olive Cells
```
on_code_evaluate(c::Connection, cm::ComponentModifier, oe::OliveExtension{<:Any},
cell::Cell{:code}, proj::Project{<:Any}) -> ::Nothing
```
------------------
This is the stub function for `on_code_evaluate`. This method is only used to denote the existence of this function. 
    Each time a `code` cell is created, every method for this function is ran. This allows you to extend `code` cells 
    by importing and explicitly extending them.
#### example
```
using Olive
import Olive: on_code_evaluate, on_code_highlight, on_code_build

function on_code_build(c::Olive.Toolips.Connection, cm::Olive.ToolipsSession.ComponentModifier, oe::Olive.OliveExtension{:myeval},
 cell::Cell{:code}, proj::Olive.Project{<:Any})
    Olive.olive_notify!(cm, "hello")
end
```
"""
function on_code_build(c::Connection, cm::ComponentModifier, oe::OliveExtension{<:Any}, 
    cell::Cell{:code}, proj::Project{<:Any}, component::Component{:div})

end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    [begin
    xtname = m.sig.parameters[4]
    if xtname != OliveExtension{<:Any}
        ext = xtname()
        on_code_highlight(c, cm, ext, cell, proj)
    end
    end for m in methods(on_code_highlight)]
    cell.source = replace(curr, "<div>" => "", "<br>" => "\n", "&nbsp;" => " ")
    tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["julia"]
    ToolipsMarkdown.set_text!(tm, cell.source)
    ToolipsMarkdown.mark_julia!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    ToolipsMarkdown.clear!(tm)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    proj::Project{<:Any})
    window = proj.id
    cells = proj[:cells]
    # get code
    testdiv = cm["cell$(cell.id)"]
    cell.source = cm["cell$(cell.id)"]["text"]
    execcode::String = *("begin\n", cell.source, "\nend\n")
    ret::Any = ""
    p = Pipe()
    err = Pipe()
    standard_out::String = ""
    redirect_stdio(stdout = p, stderr = err) do
        try
            ret = proj[:mod].evalin(Meta.parse(execcode))
        catch e
            ret = e
        end
    end
    close(err)
    close(Base.pipe_writer(p))
    standard_out = replace(read(p, String), "\n" => "<br>")
    # output
    outp::String = ""
    od = OliveDisplay()
    [begin
        xtname = m.sig.parameters[4]
        if xtname != OliveExtension{<:Any}
            ext = xtname()
            on_code_evaluate(c, cm, ext, cell, proj)
        end
    end for m in methods(on_code_evaluate)]
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
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    if pos == length(cells)
        new_cell = Cell(length(cells) + 1, "code", "", id = ToolipsSession.gen_ref())
        push!(cells, new_cell)
        append!(cm, window, build(c, cm, new_cell, proj))
        focus!(cm, "cell$(new_cell.id)")
        return
    else
        new_cell = cells[pos + 1]
    end
end
#==output[code]
Session cells
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    proj::Project{<:Any})
    keybindings = c[:OliveCore].client_data[getname(c)]["keybindings"]
    newcell = build_base_cell(c, cm, cell, proj, highlight = true, sidebox = true)
    windowname::String = proj.id
    km = cell_bind!(c, cell, proj)
    interior = newcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    sideb = interior[:children]["cellside$(cell.id)"]
    style!(sideb, "background-color" => "#88807B")
    sideb[:children] = [sideb[:children][1:2]]
   # cell_edit = topbar_icon("cell$(cell.id)drag", "edit")
    #style!(cell_edit, "color" => "white", "font-size" => 17pt)
    maincell = inp[:children]["cell$(cell.id)"]
    maincell[:contenteditable] = false
    newtmd = tmd("cell$(cell.id)tmd", cell.source)
    push!(maincell, newtmd)
    on(c, cm, maincell, "dblclick", ["none"]) do cm::ComponentModifier
        cm["cell$(cell.id)"] = "contenteditable" => "true"
        set_children!(cm, "cell$(cell.id)", Vector{Servable}())
        set_text!(cm, "cell$(cell.id)", replace(cell.source, "\n" => "<br>"))
        tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["markdown"]
        tm.raw = cell.source
        mark_markdown!(tm)
        set_text!(cm, "cellhighlight$(cell.id)", string(tm))
        ToolipsMarkdown.clear!(tm)
    end
    km = cell_bind!(c, cell, proj)
    bind!(c, cm, maincell, km)
    newcell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    proj::Project{<:Any})
    activemd = cm["cell$(cell.id)"]["text"]
    cell.source = replace(activemd, "<br>" => "\n", "<div>" => "")
    newtmd = tmd("cell$(cell.id)tmd", cell.source)
    set_children!(cm, "cell$(cell.id)", [newtmd])
    cm["cell$(cell.id)"] = "contenteditable" => "false"
    set_text!(cm, "cellhighlight$(cell.id)", "")
end

function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    cell.source = replace(curr, "<br>" => "\n", "<div>" => "")
    tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["markdown"]
    ToolipsMarkdown.set_text!(tm, cell.source)
    mark_markdown!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    ToolipsMarkdown.clear!(tm)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:TODO},
    proj::Project{<:Any})
    cell.source = "#"
    maincontainer = div("cellcontainer$(cell.id)")
    style!(maincontainer, "background-color" => "#242526",
    "border-color" => "darkpink", "border-width" => 2px, "padding" => 2percent)
    todolabel = h("todoheader$(cell.id)", 2, text = "TODO")
    style!(todolabel, "font-weight" => "bold")
    style!(todolabel, "color" => "pink")
    inpbox = ToolipsDefaults.textdiv("cell$(cell.id)", text = cell.outputs)
    style!(inpbox, "background-color" => "#242526", "color" => "white",
    "padding" => 10px, "min-height" => 5percent, "font-size" => 15pt,
    "font-weight" => "bold", "outline" => "transparent",
    "-moz-appearance" => "textfield-multiline;", "white-space" => "pre-wrap",
    "-webkit-appearance" => "textarea")
    on(c, inpbox, "input") do cm::ComponentModifier
        cell.outputs = cm[inpbox]["text"]
    end
    km = cell_bind!(c, cell, proj)
    bind!(km, "Backspace", prevent_default = false) do cm2::ComponentModifier
        if cm2["cell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell(pos, "code", "")
            deleteat!(cells, pos)
            insert!(cells, pos, new_cell)
            remove!(cm2, maincontainer)
            built = build(c, cm2, new_cell, proj)
            ToolipsSession.insert!(cm2, proj.id, pos, built)
            focus!(cm2, "cell$(cell.id)")
        end
    end
    bind!(c, cm, inpbox, km)
    push!(maincontainer, todolabel, inpbox)
    maincontainer
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:NOTE},
    proj::Project{<:Any})
    cell.source = "#"
    maincontainer = div("cellcontainer$(cell.id)")
    style!(maincontainer, "background-color" => "#242526",
    "border-color" => "darkpink", "border-width" => 2px, "padding" => 1percent)
    todolabel = h("todoheader$(cell.id)", 2, text = "NOTE")
    style!(todolabel, "font-weight" => "bold", "color" => "lightblue")
    inpbox = ToolipsDefaults.textdiv("cell$(cell.id)", text = cell.outputs)
    style!(inpbox, "background-color" => "#242526", "color" => "white",
    "padding" => 10px, "min-height" => 5percent, "font-size" => 15pt,
    "font-weight" => "bold", "outline" => "transparent",
    "-moz-appearance" => "textfield-multiline;", "white-space" => "pre-wrap",
    "-webkit-appearance" => "textarea")
    on(c, inpbox, "input") do cm::ComponentModifier
        cell.outputs = cm[inpbox]["text"]
    end
    km = cell_bind!(c, cell, proj)
    bind!(km, "Backspace", prevent_default = false) do cm2::ComponentModifier
        if cm2["cell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell(pos, "code", "")
            deleteat!(cells, pos)
            insert!(cells, pos, new_cell)
            remove!(cm2, maincontainer)
            built = build(c, cm2, new_cell, proj)
            ToolipsSession.insert!(cm2, proj.id, pos, built)
            focus!(cm2, "cell$(cell.id)")
        end
    end
    bind!(c, cm, inpbox, km)
    push!(maincontainer, todolabel, inpbox)
    maincontainer
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:getstarted},
    proj::Project{<:Any})
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = false, highlight = false)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    getstarted = div("getstarted$(cell.id)", contenteditable = false)
    style!(getstarted, "padding" => 8px, "margin-top" => 0px)
    use_this = button("new$(cell.id)", text = "start now")
    style!(use_this, "background-color" => "white", "color" => "darkgray", 
    "border-width-bottom" => 2px, "font-weight" => 10px)
    push!(getstarted, h("gshead$(cell.id)", 4, text = ""), 
    use_this)
    bcelln::String = builtcell.name
    on(c, use_this, "click", ["none"]) do cm::ComponentModifier
        proj.data[:cells]::Vector{IPyCells.Cell{<:Any}} = Vector{IPyCells.Cell{<:Any}}()
        new_cell::Cell{:code} = Cell(1, "code", "")
        push!(proj[:cells], new_cell)
        append!(cm, proj.id, build(c, cm, new_cell, proj))
        olive_notify!(cm, "use ctrl + alt + S to name your project!", color = "blue")
        remove!(cm, bcelln)
        focus!(cm, "cell$(new_cell.id)")
    end
    if "recent" in keys(c[:OliveCore].client_data[getname(c)])
        recent_projects = [begin

        end]
    end
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km)
    style!(inp[:children]["cell$(cell.id)"], "color" => "black", "border-left" => "6px solid pink", 
    "border-top-left-radius" => 8px, "border-bottom-left-radius" => 8px, "margin-bottom" => 0px)
    inp[:children]["cell$(cell.id)"][:text] = ""
    inp[:children]["cell$(cell.id)"][:children] = [olive_motd(), getstarted]
    builtcell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function toml_style!(tm::ToolipsMarkdown.TextStyleModifier)
    style!(tm, :keys, ["color" => "#D67229"])
    style!(tm, :equals, ["color" => "purple"])
    style!(tm, :string, ["color" => "#007958"])
    style!(tm, :default, ["color" => "darkblue"])
    style!(tm, :number, ["color" => "#8b0000"])
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function markdown_style!(tm::ToolipsMarkdown.TextStyleModifier)
    style!(tm, :link, ["color" => "#D67229"])
    style!(tm, :heading, ["color" => "purple"])
    style!(tm, :point, ["color" => "darkgreen"])
    style!(tm, :bold, ["color" => "darkblue"])
    style!(tm, :italic, ["color" => "#8b0000"])
    style!(tm, :keys, ["color" => "#ffc00"])
    style!(tm, :code, ["color" => "#8b0000"])
    style!(tm, :default, ["color" => "brown"])
    style!(tm, :link, ["color" => "#8b0000"])
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
function mark_toml!(tm::ToolipsMarkdown.TextModifier)
    ToolipsMarkdown.mark_between!(tm, "[", "]", :keys)
    ToolipsMarkdown.mark_between!(tm, "\"", :string)
    ToolipsMarkdown.mark_all!(tm, "=", :equals)
    [ToolipsMarkdown.mark_all!(tm, string(dig), :number) for dig in digits(1234567890)]
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
function mark_markdown!(tm::ToolipsMarkdown.TextModifier)
    ToolipsMarkdown.mark_after!(tm, "# ", until = ["\n"], :heading)
    ToolipsMarkdown.mark_between!(tm, "[", "]", :keys)
    ToolipsMarkdown.mark_between!(tm, "(", ")", :link)
    ToolipsMarkdown.mark_between!(tm, "**", :bold)
    ToolipsMarkdown.mark_between!(tm, "*", :italic)
    ToolipsMarkdown.mark_between!(tm, "``", :code)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function toml_block!(tm::ToolipsMarkdown.TextStyleModifier)
    mark_toml!(tm)
    toml_style!(tm)
end
#==|||==#
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:tomlvalues},
    proj::Project{<:Any})
    tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["toml"]
    tm.raw = cell.source
    mark_toml!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = true)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    style!(builtcell, "transition" => 1seconds)
    inp = interior[:children]["cellinput$(cell.id)"]
    inp[:children]["cellhighlight$(cell.id)"][:text] = string(tm)
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km)
    sideb = interior[:children]["cellside$(cell.id)"]
    collapsebutt = topbar_icon("$(cell.id)collapse", "unfold_less")
    collapsebutt["col"] = "false"
    style!(collapsebutt, "color" => "white", "font-size" => 17pt)
    on(c, collapsebutt, "click") do cm2::ComponentModifier
        if cm2[collapsebutt]["col"] == "false"
            style!(cm2, builtcell,
            "min-height" => 3percent, "height" => 10percent,
            "overflow" => "hidden", "border-bottom-width" => 2px,
             "border-bottom-style" => "solid",
             "border-bottom-color" => "lightblue")
            set_text!(cm2, collapsebutt, "unfold_more")
            cm2[collapsebutt] = "col" => "true"
            return
        end
        style!(cm2, builtcell, "min-height" => 50px, "height" => "auto",
        "border-bottom-width" => 0px)
        set_text!(cm2, collapsebutt, "unfold_less")
        cm2[collapsebutt] = "col" => "false"
    end
    style!(sideb, "background-color" => "lightblue")
    ToolipsMarkdown.clear!(tm)
    sideb[:children] = [sideb[:children][1:2], collapsebutt]
    builtcell::Component{:div}
end
#==|||==#
#==output[code]
inputcell_style (generic function with 1 method)
==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:tomlvalues},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    varname = "data"
    if length(curr) > 2
        if contains(curr[1:2], "[")
            st = findfirst("[", curr)[1] + 1:findfirst("]", curr)[1] - 1
            varname = curr[st]
        else
            curr = "[data]\n$curr"
        end
    end
    evalstr = "using TOML;$varname = TOML.parse(\"\"\"$(curr)\"\"\")[\"$varname\"]"
    ret::Any = ""
    p = Pipe()
    err = Pipe()
    redirect_stdio(stdout = p, stderr = err) do
        try
            ret = proj[:mod].evalin(Meta.parse(evalstr))
        catch e
            ret = e
        end
    end
    if typeof(ret) <: Exception
        set_text!(cm, "cell$(cell.id)out", replace(string(ret),
        "\n" => "<br>"))
    else
        cell.outputs = varname
        set_text!(cm, "cell$(cell.id)out", varname)
    end
end
#==|||==#
#==output[code]
inputcell_style (generic function with 1 method)
==#

#==|||==#
function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:tomlvalues},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    cell.source = replace(curr, "<br>" => "\n", "<div>" => "")
    tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["toml"]
    ToolipsMarkdown.set_text!(tm, cell.source)
    mark_toml!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    ToolipsMarkdown.clear!(tm)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:creator},
    proj::Project{<:Any})
    cells = proj[:cells]
    windowname::String = proj.id
    creatorkeys = c[:OliveCore].client_data[getname(c)]["creatorkeys"]
    cbox = ToolipsDefaults.textdiv("cell$(cell.id)", text = "")
    style!(cbox, "outline" => "transparent", "color" => "white")
    on(c, cbox, "input", [cbox.name]) do cm2::ComponentModifier
        txt = cm2[cbox]["text"]
        if txt in keys(creatorkeys)
            cellt = creatorkeys[txt]
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            remove!(cm2, buttonbox)
            new_cell = Cell(5, string(cellt), "")
            deleteat!(cells, pos)
            insert!(cells, pos, new_cell)
            insert!(cm2, windowname, pos, build(c, cm2, new_cell, proj))
            focus!(cm2, "cell$(new_cell.id)")
         elseif txt != ""
             olive_notify!(cm2, "not a recognized cell hotkey", color = "red")
             set_text!(cm2, cbox, "")
        end
    end
    km = cell_bind!(c, cell, proj)
    bind!(c, cm, cbox, km)
    olmod = c[:OliveCore].olmod
    signatures = [m.sig.parameters[4] for m in methods(Olive.build,
    [Toolips.AbstractConnection, Toolips.Modifier, IPyCells.AbstractCell,
    Project{<:Any}])]
     buttonbox = div("cellcontainer$(cell.id)")
     push!(buttonbox, cbox)
     push!(buttonbox, h("spawn$(cell.id)", 3, text = "new cell"))
     for sig in signatures
         if sig in (Cell{:creator}, Cell{<:Any}, Cell{:versioninfo})
             continue
         end
         if length(sig.parameters) < 1
             continue
         end
         b = button("$(sig)butt", text = string(sig.parameters[1]))
         on(c, b, "click") do cm2::ComponentModifier
             pos = findfirst(lcell -> lcell.id == cell.id, cells)
             remove!(cm2, buttonbox)
             new_cell = Cell(5, string(sig.parameters[1]), "")
             deleteat!(cells, pos)
             insert!(cells, pos, new_cell)
             insert!(cm2, windowname, pos, build(c, cm2, new_cell,
              proj))
         end
         push!(buttonbox, b)
     end
     buttonbox
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:helprepl},
    proj::Project{<:Any})
    built_cell::Component{:div} = build_Base_replcell(c, cm, cell, proj, repl = "help>", sideboxc => "orange", 
    replc = "#b33000")
    src::String = ""
    if contains(cell.source, "#")
        src = split(cell.source, "?")[2]
    end
    cell.source = src
    output = built_cell[:children]["cell$(cell.id)out"]
    style!(output, "max-height" => 40percent)
    opbox::Component{:div} = div("opbox$(cell.id)")
    pinbox::Component{:div} = div("pinbox$(cell.id)")
    push!(output, opbox, pinbox)
    if contains(cell.outputs, ";")
        spl = split(cell.outputs, ";")
        lastoutput = spl[1]
        pinned = spl[2]
        [begin
            if pin != " "

            end
        end for (e, pin) in enumerate(split(pinned, " "))]
     else
         cell.outputs = " ; "
     end
    built_cell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function realevaluate(c::Connection, cm::ComponentModifier, cell::Cell{:helprepl},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    window::String = proj.id
    splitcmd = split(replace(curr, "\n" => ""), " ")
    if length(splitcmd) == 1
        sec = section("$(splitcmd[1])")
        exp = Meta.parse("""t = eval(Meta.parse("$(splitcmd[1])")); @doc(t)""")
        docs = proj[:mod].evalin(exp)
        push!(sec, tmd("docmd$(splitcmd[1])", string(docs)))
        set_children!(cm, "opbox$(cell.id)", 
        [sec])
    elseif length(splitcmd) == 2
        if string(splitcmd[1]) == "pin"
            if splitcmd[2] != ""
                cell.outputs = cell.outputs * "$(splitcmd[2]);"
            end
        end
    end
    splitputs = split(replace(cell.outputs, " " => ""), ";")
    if contains(replace(cell.outputs, " " => " ", "\n" => ""), ";")
        pins = [begin
        docsection::Component{:section} = section("doc$pin")
        push!(docsection, h("doclabel$pin", 2, text = pin))
        exp = Meta.parse("""t = eval(Meta.parse("$pin")); @doc(t)""")
        docs = string(proj[:mod].evalin(exp))
        if contains(docs, "t` is of type `Nothing`.")
            nothing::Nothing
        else
            push!(docsection, tmd("docmd$pin", string(docs)))
            docsection::Component{:section}
        end
        end for pin in splitputs]
        filter!(c -> ~(isnothing(c)), pins)
        pinhead = h("pinhead$(cell.id)", 3, text = "pins")
        pinsect::Vector{Servable} = Vector{Servable}([pinhead, pins ...])
        set_children!(cm, "pinbox$(cell.id)", pinsect)
    end
    set_text!(cm, "cell$(cell.id)", "")
    focus!(cm, "cell$(cell.id)")
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:shell},
    proj::Project{<:Any})
    km = cell_bind!(c, cell, proj)
    src = ""
    if contains(cell.source, "#")
        src = split(cell.source, "?")[2]
    end
    build_base_replcell(c, cm, cell, proj, repl = "shell>", replc = "#b33000", 
    sideboxc = "red")
end
#==output[code]
Session cells
==#
#==|||==#
function realevaluate(c::Connection, cm::ComponentModifier, cell::Cell{:shell},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    mod = proj[:mod]
    p = Pipe()
    err = Pipe()
    standard_out::String = ""
    ret = ""
    redirect_stdio(stdout = p, stderr = err) do
        try
            mod.evalin(Meta.parse("Base.run(`$curr`)"))
        catch e
            ret = e
        end
    end
    close(Base.pipe_writer(p))
    standard_out = replace(read(p, String), "\n" => "<br>")
    set_text!(cm, "cell$(cell.id)out", standard_out)
    set_text!(cm, "cell$(cell.id)", "")
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:pkgrepl},
    proj::Project{<:Any})
    build_base_replcell(c, cm, cell, proj)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function realevaluate(c::Connection, cm::ComponentModifier, cell::Cell{:pkgrepl},
    proj::Project{<:Any})
    cells = proj[:cells]
    mod = proj[:mod]
    rt = cm["cell$(cell.id)"]["text"]
    args = split(rt, " ")
    if args[1] == "clear"
        cell.source = ""
        set_text!(cm, "cell$(cell.id)out", "")
        set_text!(cm, "$(cell.id)cmds", "")
    elseif args[1] == "dev"
        args[1] = "develop"
    elseif args[1] == "rm"
        args[1] = "remove"
    end
    evalstr = "Pkg.$(args[1])("
    if length(args) != 1
        for command in args[2:length(args)]
            if command == "" || command == " "
                continue
            end
            if contains(command, "http")
                evalstr = evalstr * "url = \"$(command)\", "
                continue
            end
            if contains(command, "#")
                l = length(command)
                revision = command[findfirst("#", command)[1] + 1:l]
                evalstr = evalstr * "rev = \"$(revision)\", "
                continue
            end
            if contains(command, "@")
                l = length(command)
                version = command[findfirst("@", command)[1] + 1:l]
                evalstr = evalstr * "version = \"$(version)\", "
                continue
            end
            if contains(command, "/")
                evalstr = evalstr * "path = \"$(command)\""
                continue
            end
            evalstr = evalstr * "\"$command\", "
        end
    end
    evalstr = evalstr * ")"
    p = Pipe()
    err = Pipe()
    standard_out::String = ""
    ret = ""
    redirect_stdio(stdout = p, stderr = err) do
        try
            ret = mod.evalin(Meta.parse(evalstr))
        catch e
            ret = e
        end
    end
    close(Base.pipe_writer(err))
    close(Base.pipe_writer(p))
    standard_out = read(err, String)
    out_p = read(p, String)
    if typeof(ret) <: Exception
        set_text!(cm, "cell$(cell.id)out", string(ret))
        style!(cm, "cell$(cell.id)out", "height" => "auto",
        "opacity" => 100percent)
        return
    end
    if typeof(ret) == Vector{String}
        standard_out = standard_out * "\n" * string(join(ret, "\n"))
    end
    cell.source = cell.source * "\n" * evalstr
    cell.outputs = rt
    if out_p == ""
        set_text!(cm, "cell$(cell.id)out", replace(standard_out, "✗" => "X",
        "\n" => "<br>", "✓" => "</", "*" => "", "⇒" => "->"))
    else
        set_text!(cm, "cell$(cell.id)out", replace(out_p, "✗" => "X",
        "\n" => "<br>", "✓" => "</", "*" => "", "⇒" => "->"))
    end
    set_text!(cm, "cell$(cell.id)", "")
    set_text!(cm, "$(cell.id)cmds", replace(cell.source, "\n" => "<br>"))
    style!(cm, "cell$(cell.id)out", "height" => "auto", "opacity" => 100percent)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:include},
    proj::Project{<:Any})
    cells = proj[:cells]
    projs = c[:OliveCore].open[getname(c)].projects
    if cell.source != ""
        cell.source = replace(cell.source, "include(\"" => "", "\")" => "")
    end
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    ToolipsMarkdown.julia_block!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = true)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    style!(interior[:children]["cellside$(cell.id)"],
    "background-color" => "lightgreen")
    inp[:children]["cellhighlight$(cell.id)"][:text] = string(tm)
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km)
    builtcell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:include}, 
    proj::Project{<:Any})
    path = cm["cell$(cell.id)"]["text"]
    env = c[:OliveCore].open[getname(c)]
    current_path::String = env.pwd
    if :path in keys(proj.data)
        fnamesplit = split(proj.data[:path], "/")
        current_path = join(fnamesplit[1:length(fnamesplit) - 1], "/")
    end
    fullpath = current_path * "/" * path
    if ~(isfile(fullpath))
        olive_notify!(cm, "$fullpath is not a file!", color = "red")
    end
    cell.source = path
    projs = c[:OliveCore].open[getname(c)].projects
    if isnothing(findfirst(p -> p.id == cell.outputs, projs))
        if isfile(fullpath)
            fnamesplit = split(fullpath, "/")
            fname = string(fnamesplit[length(fnamesplit)])
            fcell = Cell(1, "jl", fname, fullpath)
            new_cells = olive_read(fcell)
            inclproj = add_to_session(c, new_cells, cm, fname, 
            env.pwd, type = "include")
            inclproj.data[:mod] = proj[:mod]
            cell.outputs = inclproj.id
            olive_notify!(cm, "file $fname included", color = "darkgreen")
            set_text!(cm, "cell$(cell.id)out", fname)
        end
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:include},
    proj::Project{<:Any})
    txt = cm["cell$(cell.id)"]["text"]
    tm = ToolipsMarkdown.TextStyleModifier(txt)
    ToolipsMarkdown.julia_block!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    ToolipsMarkdown.clear!(tm)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function string(cell::Cell{:include})
    if cell.source != ""
        return(*("include(\"$(cell.source)\")",
        "\n#==output[$(cell.type)]\n$(string(cell.outputs))\n==#\n#==|||==#\n"))::String
    end
    ""::String
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:module},
    proj::Project{<:Any})
    cells = proj[:cells]
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = false)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    inp[:children]["cell$(cell.id)"][:text] = cell.outputs
    style!(inp[:children]["cell$(cell.id)"], "color" => "darkred")
    style!(interior[:children]["cellside$(cell.id)"],
    "background-color" => "red")
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km)
    builtcell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function read_module_cells(s::String)
    r = maximum(findfirst("module", s))
    st = findnext("\n", s, r)[1]
    nd = minimum(findlast("end", s)) - 1
    modsrc = split(s[st:nd], "#--\n")
    [begin
            srcsplt = split(cellc, "#==\n")
            src = srcsplt[1]
            if length(srcsplt) > 1
                outptype = srcsplt[2]
                outptype = replace(outptype, "==#" => "")
                outsplit = split(outptype, "/")
            else
                outsplit = ["code", ""]
            end
            Cell(e, string(outsplit[1]), string(src), string(outsplit[2]))
        end for (e, cellc) in enumerate(modsrc)]
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function make_module_cells(proj::Project{:module}, cell::Cell{:module})
    src = join([begin
    """$(cell.source)\n#==\n$(cell.type)/$(cell.outputs)\n==#\n#--\n""" 
    end for cell in proj[:cells]])
    modname = cell.outputs
    cell.source = """module $modname\n$src\nend"""
    cell.outputs = modname
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function string(cell::Cell{:module})
    if cell.source != ""
        return(*(cell.source,
        "\n#==output[$(cell.type)]\n$(string(cell.outputs))\n==#\n#==|||==#\n"))::String
    end
    ""::String
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:module}, 
    proj::Project{<:Any})
    projects = c[:OliveCore].open[getname(c)].projects
    if length(findall(proj -> proj.id == cell.outputs, projects)) > 0
        modname = cell.outputs
        proj = projects[modname]
        make_module_cells(proj, cell)
        return
    elseif contains(cell.source, "module")
        new_cells = read_module_cells(cell.source)
    else
        new_cells = Vector{Cell}([Cell(1, "code", "")])
    end
    modname = cm["cell$(cell.id)"]["text"]
    modstr = olive_module(modname, proj[:env])
    newmod = proj.data[:mod].evalin(Meta.parse(modstr))
    projdict = Dict{Symbol, Any}(:cells => new_cells, :env => proj[:env], 
    :path => proj[:path], :mod => newmod)
    inclproj = Project{:module}(modname, projdict)
    inclproj.id = modname
    push!(c[:OliveCore].open[getname(c)].projects, inclproj)
    tab = build_tab(c, inclproj)
    open_project(c, cm, inclproj, tab)
    olive_notify!(cm, "module $modname added", color = "red")
    set_text!(cm, "cell$(cell.id)out", modname)
    cell.outputs = modname
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:module},
    proj::Project{<:Any})
    cell.source = cm["cell$(cell.id)"]["text"]
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    ToolipsMarkdown.julia_block!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    ToolipsMarkdown.clear!(tm)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
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
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
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
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
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
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
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
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
