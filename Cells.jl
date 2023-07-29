"""
# welcome to Cells.jl
This file creates the basis for Olive.jl cells then builds olive cell types
    on  top of it. For extending Cells,
- Cell controls
- Directory cells
- Session cells (markdown, code, TODO, NOTE, creator)
- REPL Cells (pkgrepl, helprepl, shellrepl, oliverepl)
- Environment cells (module cells)
"""
#==|||==#
function cell_up!(c::Connection, cm2::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}}, proj::Project{<:Any})
    windowname::String = proj.id
    pos = findall(lcell -> lcell.id == cell.id, cells)[1]
    if pos != 1
        switchcell = cells[pos - 1]
        originallen = length(cells)
        cells[pos - 1] = cell
        cells[pos] = switchcell
        remove!(cm2, "cellcontainer$(switchcell.id)")
        remove!(cm2, "cellcontainer$(cell.id)")
        ToolipsSession.insert!(cm2, windowname, pos - 1, build(c, cm2, switchcell, cells,
        proj))
        ToolipsSession.insert!(cm2, windowname, pos - 1, build(c, cm2, cell, cells,
        proj))
        focus!(cm2, "cell$(cell.id)")
    else
        olive_notify!(cm2, "this cell cannot go up any further!", color = "red")
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_down!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}}, proj::Project{<:Any})
    windowname::String = proj.id
    pos = findall(lcell -> lcell.id == cell.id, cells)[1]
    if pos != length(cells)
        switchcell = cells[pos + 1]
        cells[pos + 1] = cell
        cells[pos] = switchcell
        remove!(cm, "cellcontainer$(switchcell.id)")
        remove!(cm, "cellcontainer$(cell.id)")
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, switchcell, cells,
        proj))
        ToolipsSession.insert!(cm, windowname, pos + 1, build(c, cm, cell, cells,
        proj))
        focus!(cm, "cell$(cell.id)")
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
    remove!(cm, "cellcontainer$(cell.id)")
    deleteat!(cells, findfirst(c -> c.id == cell.id, cells))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_new!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}}, proj::Project{<:Any}; type::String = "creator")
    windowname::String = proj.id
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    newcell = Cell(pos, type, "")
    insert!(cells, pos + 1, newcell)
    ToolipsSession.insert!(cm, windowname, pos + 1, build(c, cm, newcell,
    cells, proj))
    focus!(cm, "cell$(newcell.id)")
    cm["cell$(newcell.id)"] = "contenteditable" => "true"
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function focus_up!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any}, cells::Vector{Cell{<:Any}}, 
    proj::Project{<:Any})
    i::Int64 = findfirst(cel::Cell{<:Any} -> cel.id == cell.id, cells)
    if i == 1 || isnothing(i)
        return
    end
    focus!(cm, "cell$(cells[i - 1].id)")
end

function focus_down!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any}, cells::Vector{Cell{<:Any}}, 
    proj::Project{<:Any})
    i::Int64 = findfirst(cel::Cell{<:Any} -> cel.id == cell.id, cells)
    if i == length(cells) || isnothing(i)
        return
    end
    focus!(cm, "cell$(cells[i + 1].id)")
end

function bind!(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any};
    explorer::Bool = false)

end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
**Olive Cells**
### build(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any}; explorer::Bool = false) -> ::Component{:div}
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
Here are some other **important** functions to look at for creating cells:
- `cell_bind!`
- `build_base_cell`
- `evaluate`
- `bind!`
- `cell_highlight!`
- `olive_save`
"""
function build(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any};
    explorer::Bool = false)
    hiddencell = div("cell$(cell.id)")
    hiddencell["class"] = "cell-jl"
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
"""
**Olive Cells**
### olive_save(cells::Vector{Cell}, sc::Cell{<:Any})
------------------
Saves the vector of cells into the output format of `sc`. For example, if we
were saving a Julia file, we would write
`olive_save(cells::Vector{Cell}, sc::Cell{:jl})`
#### example
```
cells = IPyCells.read_jl("myfolder/myjl.jl")
filecell = Cell(1, "jl", "myjl.jl", "myfolder/myjl.jl")
olive_save(cells, filecell) # saves `cells` to "myfolder/myjl.jl"
```
"""
function olive_save(cells::Vector{<:IPyCells.AbstractCell}, sc::Cell{<:Any})
    open(sc.outputs, "w") do io
        [write(io, string(cell.source) * "\n") for cell in cells]
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function directory_cells(dir::String = pwd(), access::Pair{String, String} ...)
    files = readdir(dir)
    return([build_file_cell(e, path, dir) for (e, path) in enumerate(files)]::AbstractVector)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build_file_cell(e::Int64, path::String, dir::String)
    if ~(isdir(dir * "/" * path))
        splitdir::Vector{SubString} = split(path, "/")
        fname::String = string(splitdir[length(splitdir)])
        fsplit = split(fname, ".")
        fending::String = ""
        if length(fsplit) > 1
            fending = string(fsplit[2])
        end
        Cell(e, fending, fname, replace(dir * "/" * path, "\\" => "/"))
    else
        Cell(e, "dir", path, dir)
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
**Olive Cells**
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
function build_base_cell(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any};
    explorer::Bool = false)
    hiddencell = div("cell$(cell.id)")
    hiddencell["class"] = "cell-hidden"
    name = a("cell$(cell.id)label", text = cell.source, contenteditable = true)
    #bind!(c, name, "Enter") do cm::ComponentModifier
    #    cm[name] = "contenteditable" => "false"
    #end
    on(c, name, "click") do cm
        km = ToolipsSession.KeyMap()
        bind!(km, "Enter") do cm2
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
    finfo = a("cell$(cell.id)info", text =  string(fs) * outputfmt)
    style!(finfo, "color" => "white", "float" => "right", "font-weight" => "bold")
    delbutton = topbar_icon("$(cell.id)expand", "cancel")
    on(c, delbutton, "click") do cm::ComponentModifier
        rm(cell.outputs)
        olive_notify!(cm, "file deleted", color = "red")
        remove!(cm, hiddencell)
    end
    style!(delbutton, "color" => "white", "font-size" => 17pt)
    style!(name, "color" => "white", "font-weight" => "bold",
    "font-size" => 14pt, "margin-left" => 5px)
    push!(hiddencell, delbutton, name, finfo)
    hiddencell
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cell::Cell{:dir}, d::Directory{<:Any};
    explorer::Bool = false)
    container = div("cellcontainer$(cell.id)")
    filecell = div("cell$(cell.id)", class = "cell-ipynb", ex = 0)
    childbox = div("child$(cell.id)")
    style!(container, "padding" => 0px, "margin-bottom" => 0px)
    expandarrow = topbar_icon("$(cell.id)expand", "expand_more")
    style!(childbox, "opacity" => 0percent, "margin-left" => 7px, "border-width-left" => 1px, 
    "border-color" => "darkblue", "height" => 0percent, 
    "border-width" => 0px, "transition" => 1seconds)
    style!(filecell, "background-color" => "#FFFF88")
    childbox[:children] = Vector{Servable}([begin
    build(c, mcell, d, explorer = true)
    end
    for mcell in directory_cells(cell.outputs * "/" * cell.source)])
    on(c, filecell, "dblclick") do cm::ComponentModifier
        if cm[filecell]["ex"] == "0"
            style!(cm, childbox, "height" => 50percent, "opacity" => 100percent)
            cm[filecell] = "ex" => "1"
            return
        end
        style!(cm, childbox, "opacity" => 0percent, "height" => 0percent)
        cm[filecell] = "ex" => "0"
    end
    fname = a("$(cell.source)", text = cell.source)
    style!(fname, "color" => "gray", "font-size" => 15pt)
    push!(filecell, expandarrow, fname)
    push!(container, filecell, childbox)
    container
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cell::Cell{:ipynb},
    d::Directory{<:Any}; explorer::Bool = false)
    filecell = build_base_cell(c, cell, d, explorer = explorer)
    style!(filecell, "background-color" => "orange")
    if explorer
        on(c, filecell, "dblclick") do cm::ComponentModifier
            cs::Vector{Cell{<:Any}} = IPyCells.read_ipynb(cell.outputs)
            add_to_session(c, cs, cm, cell.source, cell.outputs)
        end
    else
        on(c, filecell, "dblclick") do cm::ComponentModifier
            cs::Vector{Cell{<:Any}} = IPyCells.read_ipynb(cell.outputs)
            load_session(c, cs, cm, cell.source, cell.outputs, d)
        end
    end
    filecell
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_save(cells::Vector{<:IPyCells.AbstractCell}, sc::Cell{:ipynb})
    IPyCells.save_ipynb(cells, sc.outputs)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cell::Cell{:jl},
    d::Directory{<:Any}; explorer::Bool = false)
    hiddencell = build_base_cell(c, cell, d, explorer = explorer)
    hiddencell["class"] = "cell-jl"
    style!(hiddencell, "cursor" => "pointer")
    if explorer
        on(c, hiddencell, "dblclick") do cm::ComponentModifier
            cs::Vector{Cell{<:Any}} = IPyCells.read_jl(cell.outputs)
            add_to_session(c, cs, cm, cell.source, cell.outputs)
        end
    else
        on(c, hiddencell, "dblclick") do cm::ComponentModifier
            cs::Vector{Cell{<:Any}} = IPyCells.read_jl(cell.outputs)
            load_session(c, cs, cm, cell.source, cell.outputs, d)
        end
    end
    hiddencell
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_save(cells::Vector{<:IPyCells.AbstractCell}, sc::Cell{:jl})
    IPyCells.save(cells, sc.outputs)
end
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
    d::Directory; explorer::Bool = false)
    hiddencell = build_base_cell(c, cell, d, explorer = explorer)
    hiddencell["class"] = "cell-toml"
    if explorer
        on(c, hiddencell, "dblclick") do cm::ComponentModifier
            cs::Vector{Cell{<:Any}} = read_toml(cell.outputs)
            add_to_session(c, cs, cm, cell.source, cell.outputs)
        end
        if cell.source == "Project.toml"
            activatebutton = topbar_icon("$(cell.id)act", "bolt")
            style!(activatebutton, "font-size" => 20pt, "color" => "white")
            on(c, activatebutton, "click") do cm::ComponentModifier
                [begin
                    b = button("activate$(proj[1])", text = proj[1])
                    on(c, b, "click") do cm2::ComponentModifier
                        modname = split(proj[1], ".")[1] * replace(
                        ToolipsSession.gen_ref(10),
                        [string(dig) => "" for dig in digits(1234567890)] ...)
                        proj[2][:mod] = eval(
                        Meta.parse(olive_module(modname, cell.outputs)
                        ))
                        olive_notify!(cm2, "environment $(cell.outputs) activated",
                        color = "blue")
                        [begin
                            remove!(cm2, "activate$k")
                        end for k in keys(c[:OliveCore].open[getname(c)].open)]
                    end
                    append!(cm, hiddencell, b)
                end for proj in c[:OliveCore].open[getname(c)].projects]
            end
            insert!(hiddencell[:children], 2, activatebutton)
        end
    else
        on(c, hiddencell, "dblclick") do cm::ComponentModifier
            cs::Vector{Cell{<:Any}} = read_toml(cell.outputs)
            load_session(c, cs, cm, cell.source, cell.outputs, d)
        end
    end
    hiddencell
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
function olive_save(cells::Vector{<:IPyCells.AbstractCell}, sc::Cell{:toml})
    joinedstr = join([toml_string(cell) for cell in cells])
    ret = ""
    try
        ret = TOML.parse(joinedstr * "\n")
    catch e
        return "TOML parse error: $(e)"
    end
    open(sc.outputs, "w") do io
        TOML.print(io, ret)
    end
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
cells::Vector{Cell{<:Any}}, proj::Project{<:Any}) -> ::Component{:div}
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
"""
function build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}}, proj::Project{<:Any})
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    ToolipsMarkdown.julia_block!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell, cells,
    windowname, sidebox = true, highlight = false)
    km = cell_bind!(c, cell, cells, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    sidebox = interior[:children]["cellside$(cell.id)"]
    [style!(child, "color" => "red") for child in sidebox[:children]]
    insert!(builtcell[:children], 1, h("unknown", 3, text = "cell $(cell.type)"))
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
**Olive Cells**
```
evaluate(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
cells::Vector{Cell}, proj::Project{<:Any}) -> ::Nothing
```
------------------
This is the catchall/default function for the evaluation of any cell. Use this
as a template to add evaluation to your cell using the `evaluate` method binding.
If you were to, say bind your cell without using evaluate, the only problem would
be it will not run with the `runall` window button.
#### example
```

```
"""
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell}, proj::Project{<:Any})
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    cell.source = cm["cell$(cell.id)"]["text"]
    if pos != length(cells)
        focus!(cm, "cell$(cells[pos + 1].id)")
    else
        new_cell = Cell(length(cells) + 1, "creator", "")
        push!(cells, new_cell)
        ToolipsSession.append!(cm, proj.id, build(c, cm, new_cell, cells, proj))
        focus!(cm, "cell$(new_cell.id)")
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function remove_last_eval(c::Connection, cm::ComponentModifier, cell::Cell{<:Any})
    cursorpos = parse(Int64, cm["cell$(cell.id)"]["caret"])
    rawt = cm["cell$(cell.id)"]["text"]
    keybindings = c[:OliveCore].client_data[getname(c)]["keybindings"]
    inp = keybindings["evaluate"][1]
    if inp == "Enter"
        inp = "\n"
    end
    if cursorpos > 1
        lastn = findprev(inp, rawt, cursorpos)
        if isnothing(lastn)
            lastn = 1:cursorpos
        end
        cell.source = rawt[1:lastn[1] - 1] * rawt[maximum(lastn) + 1:length(rawt)]
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
**Olive Cells**
```
cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
cells::Vector{Cell}, proj::Project{<:Any})
```
------------------
The catchall/default highlighting function for cells. Build a base cell using
`build_base_cell`, setting the `highlight` key-word argument to `false`, then
write this function for your cell and it should highlight properly.
#### example
```

```
"""
function cell_highlight!(c::Connection,   cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell},  proj::Project{<:Any})

end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
**Olive Cells**
```
cell_bind!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
cells::Vector{Cell}, proj::Project{<:Any}) -> ::ToolipsSession.KeyMap
```
------------------
Binds default cell controls, returns keymap to bind to your cell's input.
#### example
```

```
"""
function cell_bind!(c::Connection, cell::Cell{<:Any}, cells::Vector{Cell{<:Any}},
    proj::Project{<:Any})
    keybindings = c[:OliveCore].client_data[getname(c)]["keybindings"]
    km = ToolipsSession.KeyMap()
    bind!(km, keybindings["save"], prevent_default = true) do cm::ComponentModifier
        save_project(c, cm, proj)
    end
    bind!(km, keybindings["up"]) do cm2::ComponentModifier
        cell_up!(c, cm2, cell, cells, proj)
    end
    bind!(km, keybindings["down"]) do cm2::ComponentModifier
        cell_down!(c, cm2, cell, cells, proj)
    end
    bind!(km, keybindings["delete"]) do cm2::ComponentModifier
        cell_delete!(c, cm2, cell, cells)
    end
    bind!(km, keybindings["evaluate"]) do cm2::ComponentModifier
        remove_last_eval(c, cm2, cell)
        evaluate(c, cm2, cell, cells, proj)
    end
    bind!(km, keybindings["new"]) do cm2::ComponentModifier
        cell_new!(c, cm2, cell, cells, proj)
    end
    bind!(km, keybindings["focusup"]) do cm::ComponentModifier
        focus_up!(c, cm, cell, cells, proj)
    end
    bind!(km, keybindings["focusdown"]) do cm::ComponentModifier
        focus_down!(c, cm, cell, cells, proj)
    end
    km::KeyMap
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build_base_input(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell}, proj::Project{<:Any}; highlight::Bool = false)
    windowname::String = proj.id
    inputbox::Component{:div} = div("cellinput$(cell.id)")
    inside::Component{:div} = ToolipsDefaults.textdiv("cell$(cell.id)",
    text = replace(cell.source, "\n" => "</br>", " " => "&nbsp;"),
    "class" => "input_cell")
    style!(inside, "border-top-left-radius" => 0px)
    if highlight
        highlight_box::Component{:div} = div("cellhighlight$(cell.id)",
        text = "hl")
        style!(highlight_box, "position" => "absolute",
        "background" => "transparent", "z-index" => "5", "padding" => 20px,
        "border-top-left-radius" => "0px !important",
        "border-radius" => "0px !important", "line-height" => 15px,
        "max-width" => 90percent, "border-width" =>  0px,  "pointer-events" => "none",
        "color" => "#4C4646 !important", "border-radius" => 0px, "font-size" => 13pt, "letter-spacing" => 1px,
        "font-family" => """"Lucida Console", "Courier New", monospace;""", "line-height" => 24px)
        on(c, inputbox, "keyup") do cm2::ComponentModifier
            cell_highlight!(c, cm2, cell, cells, proj)
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
function build_base_cell(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}}, proj::Project{<:Any}; highlight::Bool = false,
    sidebox::Bool = false)
    windowname::String = proj.id
    outside::Component{:div} = div("cellcontainer$(cell.id)", class = "cell")
    style!(outside, "transition" => 2seconds)
    interiorbox::Component{:div} = div("cellinterior$(cell.id)")
    inputbox::Component{:div} = build_base_input(c, cm, cell, cells, proj,
    highlight = highlight)
    output::Component{:div} = divider("cell$(cell.id)out", class = "output_cell", text = cell.outputs)
    if sidebox
        sidebox::Component{:div} = div("cellside$(cell.id)")
        cell_drag = topbar_icon("cell$(cell.id)drag", "drag_indicator")
        cell_run = topbar_icon("cell$(cell.id)drag", "play_arrow")
        on(c, cell_run, "click") do cm2::ComponentModifier
            evaluate(c, cm2, cell, cells, proj)
        end
        # TODO move these styles to stylesheet
        style!(sidebox, "display" => "inline-block", "background-color" => "pink",
        "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px,
        "overflow" => "hidden", "border-style" => "solid", "border-width" => 1px)
        style!(cell_drag, "color" => "white", "font-size" => 17pt)
        style!(cell_run, "color" => "white", "font-size" => 17pt)
        # TODO move these styles to stylesheet
        push!(sidebox, cell_drag, br(), cell_run)
        push!(interiorbox, sidebox, inputbox)
    else
        push!(interiorbox, inputbox)
    end
    # TODO move these styles to stylesheet
    style!(inputbox, "padding" => 0px, "width" => 90percent,
    "overflow" => "hidden", "border-top-left-radius" => "0px !important",
    "border-bottom-left-radius" => 0px, "border-radius" => "0px !important",
    "position" => "relative", "height" => "auto")
    style!(interiorbox, "display" => "flex")
    push!(outside, interiorbox, output)
    outside::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    cells::Vector{Cell}, proj::Project{<:Any})
    windowname::String = proj.id
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    ToolipsMarkdown.julia_block!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell, cells,
    proj, sidebox = true, highlight = true)
    km = cell_bind!(c, cell, cells, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    inp[:children]["cellhighlight$(cell.id)"][:text] = string(tm)
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km, on = :down)
    builtcell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:creator},
    cells::Vector{Cell}, proj::Project{<:Any})
    windowname::String = proj.id
    creatorkeys = c[:OliveCore].client_data[getname(c)]["creatorkeys"]
    cbox = ToolipsDefaults.textdiv("cell$(cell.id)", text = "")
    style!(cbox, "outline" => "transparent", "color" => "white")
    on(c, cbox, "input") do cm2::ComponentModifier
        txt = cm2[cbox]["text"]
        if txt in keys(creatorkeys)
            cellt = creatorkeys[txt]
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            remove!(cm2, buttonbox)
            new_cell = Cell(5, string(cellt), "")
            deleteat!(cells, pos)
            insert!(cells, pos, new_cell)
            insert!(cm2, windowname, pos, build(c, cm2, new_cell, cells,
             proj))
            focus!(cm2, "cell$(new_cell.id)")
         elseif txt != ""
             olive_notify!(cm2, "not a recognized cell hotkey", color = "red")
             set_text!(cm2, cbox, "")
        end
    end
    km = cell_bind!(c, cell, cells, proj)
    bind!(c, cm, cbox, km)
    olmod = c[:OliveCore].olmod
    signatures = [m.sig.parameters[4] for m in methods(Olive.build,
    [Toolips.AbstractConnection, Toolips.Modifier, IPyCells.AbstractCell,
    Vector{Cell}, Project{<:Any}])]
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
             insert!(cm2, windowname, pos, build(c, cm2, new_cell, cells,
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
function last_line(source::String, caret::Int64)

end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    cells::Vector{Cell}, proj::Project{<:Any})
    windowname::String = proj.id
    curr = cm["cell$(cell.id)"]["text"]
    curr_raw = cm["rawcell$(cell.id)"]["text"]
    if curr_raw == "]"
        remove!(cm, "cellcontainer$(cell.id)")
        pos = findfirst(lcell -> lcell.id == cell.id, cells)
        new_cell = Cell(pos, "pkgrepl", "")
        deleteat!(cells, pos)
        insert!(cells, pos, new_cell)
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, new_cell,
         cells, proj))
         focus!(cm, "cell$(new_cell.id)")
    elseif curr_raw == ";"
        remove!(cm, "cellcontainer$(cell.id)")
        pos = findfirst(lcell -> lcell.id == cell.id, cells)
        new_cell = Cell(pos, "shell", "")
        deleteat!(cells, pos)
        insert!(cells, pos, new_cell)
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, new_cell,
         cells, proj))
         focus!(cm, "cell$(new_cell.id)")
    elseif curr_raw == "?"
        pos = findfirst(lcell -> lcell.id == cell.id, cells)
        new_cell = Cell(pos, "helprepl", "")
        deleteat!(cells, pos)
        insert!(cells, pos, new_cell)
        remove!(cm, "cellcontainer$(cell.id)")
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, new_cell,
         cells, proj))
        focus!(cm, "cell$(new_cell.id)")
    elseif curr_raw == "#=TODO"
        remove!(cm, "cellcontainer$(cell.id)")
        pos = findfirst(lcell -> lcell.id == cell.id, cells)
        new_cell = Cell(pos, "TODO", "")
        deleteat!(cells, pos)
        insert!(cells, pos, new_cell)
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, new_cell,
         cells, proj))
         focus!(cm, "cell$(new_cell.id)")
    elseif curr_raw == "#=NOTE"
        pos = findfirst(lcell -> lcell.id == cell.id, cells)
        new_cell = Cell(pos, "NOTE", "")
        deleteat!(cells, pos)
        insert!(cells, pos, new_cell)
        remove!(cm, "cellcontainer$(cell.id)")
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, new_cell,
         cells, proj))
        focus!(cm, "cell$(new_cell.id)")
    elseif curr_raw == "include("
        pos = findfirst(lcell -> lcell.id == cell.id, cells)
        new_cell = Cell(pos, "include", cells[pos].source, cells[pos].outputs)
        deleteat!(cells, pos)
        insert!(cells, pos, new_cell)
        remove!(cm, "cellcontainer$(cell.id)")
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, new_cell,
         cells, proj))
        focus!(cm, "cell$(new_cell.id)")
    end
    cursorpos = parse(Int64, cm["cell$(cell.id)"]["caret"])
    if cursorpos > 1
        lastn = findprev("\n", curr, cursorpos)
        if ~(isnothing(lastn))
            lastline = findprev("\n", curr, lastn[1] - 1)
            if isnothing(lastline)
                lastline = 1:lastn[1] - 1
            end
            if contains(curr[lastline[1]:cursorpos], "function")
                # auto-indent goes here.
            end
        end
    end
    cell.source = curr
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    ToolipsMarkdown.julia_block!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function evaluate(c::Connection, cm2::ComponentModifier, cell::Cell{:code},
    cells::Vector{Cell}, proj::Project{<:Any})
    window = proj.id
    # set load icon
    icon = olive_loadicon()
    cell_drag = topbar_icon("cell$(cell.id)drag", "drag_indicator")
    cell_run = topbar_icon("cell$(cell.id)drag", "play_arrow")
    style!(cell_drag, "color" => "white", "font-size" => 17pt)
    style!(cell_run, "color" => "white", "font-size" => 17pt)
    on(c, cell_run, "click") do cm2::ComponentModifier
        evaluate(c, cm2, cell, cells, window)
    end
    icon.name = "load$(cell.id)"
    icon["width"] = "20"
    remove!(cm2, cell_run)
    set_children!(cm2, "cellside$(cell.id)", [icon])
    script!(c, cm2, "$(cell.id)eval") do cm::ComponentModifier
        # get code
        rawcode::String = cm["cell$(cell.id)"]["text"]
        execcode::String = *("begin\n", rawcode, "\nend\n")
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
        set_children!(cm, "cellside$(cell.id)", [cell_drag, br(), cell_run])
        set_text!(cm, "cell$(cell.id)out", outp)
        cell.outputs = outp
        pos = findfirst(lcell -> lcell.id == cell.id, cells)
        if pos == length(cells)
            new_cell = Cell(length(cells) + 1, "code", "", id = ToolipsSession.gen_ref())
            push!(cells, new_cell)
            append!(cm, window, build(c, cm, new_cell, cells, proj))
            focus!(cm, "cell$(new_cell.id)")
            return
        else
            new_cell = cells[pos + 1]
        end
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function string(cell::Cell{:markdown})
        "\"\"\"$(cell.source)\"\"\"\n#==|||==#\n"::String
end
#==output[code]
Session cells
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    cells::Vector{Cell}, proj::Project{<:Any})
    keybindings = c[:OliveCore].client_data[getname(c)]["keybindings"]
    tlcell = ToolipsDefaults.textdiv("cell$(cell.id)",
    "class" => "cell")
    tlcell[:text] = ""
    tlcell[:contenteditable] = false
    conta = div("cellcontainer$(cell.id)")
    style!(tlcell, "border-width" => 2px, "border-style" => "solid",
    "min-height" => 2percent)
    innercell = tmd("celltmd$(cell.id)", cell.source)
    style!(innercell, "min-hight" => 2percent)
    on(c, cm, tlcell, "dblclick") do cm::ComponentModifier
        set_text!(cm, tlcell, replace(cell.source, "\n" => "</br>"))
        cm["olivemain"] = "cell" => string(cell.n)
        cm[tlcell] = "contenteditable" => "true"
    end
    on(c, cm, tlcell, "click") do cm::ComponentModifier
        focus!(cm, tlcell)
    end
    km = cell_bind!(c, cell, cells, proj)
    bind!(c, cm, tlcell, km)
    tlcell[:children] = [innercell]
    push!(conta, tlcell)
    conta
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    cells::Vector{Cell}, proj::Project{<:Any})
    if cm["cell$(cell.id)"]["contenteditable"] == "true"
        activemd = cm["cell$(cell.id)"]["text"]
        cell.source = activemd * "\n"
        newtmd = tmd("cell$(cell.id)tmd", cell.source)
        set_children!(cm, "cell$(cell.id)", [newtmd])
        cm["cell$(cell.id)"] = "contenteditable" => "false"
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:TODO},
    cells::Vector{Cell}, proj::Project{<:Any})
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
    km = cell_bind!(c, cell, cells, window)
    bind!(km, "Backspace") do cm2::ComponentModifier
        if cm2["cell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell(pos, "code", "")
            deleteat!(cells, pos)
            insert!(cells, pos, new_cell)
            remove!(cm2, maincontainer)
            built = build(c, cm2, new_cell, cells, window)
            ToolipsSession.insert!(cm2, window, pos, built)
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
    cells::Vector{Cell}, proj::Project{<:Any})
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
    km = cell_bind!(c, cell, cells, window)
    bind!(km, "Backspace") do cm2::ComponentModifier
        if cm2["cell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell(pos, "code", "")
            deleteat!(cells, pos)
            insert!(cells, pos, new_cell)
            remove!(cm2, maincontainer)
            built = build(c, cm2, new_cell, cells, window)
            ToolipsSession.insert!(cm2, window, pos, built)
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
function build(c::Connection, cm::ComponentModifier, cell::Cell{:versioninfo},
    cells::Vector{Cell}, proj::Project{<:Any})
    builtcell::Component{:div} = build_base_cell(c, cm, cell, cells,
    proj, sidebox = false, highlight = false)
    km = cell_bind!(c, cell, cells, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km)
    style!(inp[:children]["cell$(cell.id)"], "color" => "black")
    inp[:children]["cell$(cell.id)"][:text] = ""
    inp[:children]["cell$(cell.id)"][:children] = [olive_motd()]
    builtcell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function toml_style!(tm::ToolipsMarkdown.TextStyleModifier)
    style!(tm, :keys, ["color" => "#D67229"])
    style!(tm, :equals, ["color" => "purple"])
    style!(tm, :string, ["color" => "darkgreen"])
    style!(tm, :default, ["color" => "darkblue"])
    style!(tm, :number, ["color" => "#8b0000"])
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
function toml_block!(tm::ToolipsMarkdown.TextModifier)
    ToolipsMarkdown.mark_after!(tm, "[", :keys, until = ["]"])
    ToolipsMarkdown.mark_between!(tm, "\"", :string)
    ToolipsMarkdown.mark_all!(tm, "=", :equals)
    [ToolipsMarkdown.mark_all!(tm, string(dig), :number) for dig in digits(1234567890)]
    toml_style!(tm)
end
#==|||==#
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:tomlvalues},
    cells::Vector{Cell}, proj::Project{<:Any})
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    toml_block!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell, cells,
    proj, sidebox = true, highlight = true)
    km = cell_bind!(c, cell, cells, proj)
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
    sideb[:children] = [sideb[:children][1:2], collapsebutt]
    builtcell::Component{:div}
end
#==|||==#
#==output[code]
inputcell_style (generic function with 1 method)
==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:tomlvalues},
    cells::Vector{Cell}, proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    proj = c[:OliveCore].open[getname(c)][window]
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
    cells::Vector{Cell}, proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    cell.source = curr
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    toml_block!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#

#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:helprepl},
    cells::Vector{Cell}, proj::Project{<:Any})
    km = cell_bind!(c, cell, cells, proj)
    src = ""
    if contains(cell.source, "#")
        src = split(cell.source, "?")[2]
    end
    cell.source = src
    outside = div("cellcontainer$(cell.id)", class = "cell")
    inner  = div("cellinside$(cell.id)")
    style!(inner, "display" => "flex")
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = "")
    bind!(km, "Backspace", prevent_default = false) do cm2::ComponentModifier
        if cm2["cell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell(pos, "code", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm2, outside)
            built = build(c, cm2, new_cell, cells, proj)
            ToolipsSession.insert!(cm2, windowname, pos, built)
            focus!(cm2, "cell$(cell.id)")
        end
    end
    bind!(km, "Enter") do cm2::ComponentModifier
        realevaluate(c, cm2, cell, cells, proj)
    end
    sidebox = div("cellside$(cell.id)")
    style!(sidebox, "display" => "inline-block",
    "background-color" => "orange",
    "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px,
    "overflow" => "hidden", "border-style" => "solid",
    "border-width" => 2px)
    pkglabel =  a("$(cell.id)helplabel", text = "help>")
    style!(pkglabel, "font-weight" => "bold", "color" => "black")
    push!(sidebox, pkglabel)
    style!(inside, "width" => 80percent, "border-bottom-left-radius" => 0px,
    "border-top-left-radius" => 0px,
    "min-height" => 50px, "display" => "inline-block",
     "margin-top" => 0px, "font-weight" => "bold",
     "background-color" => "#b33000", "color" => "white", "border-style" => "solid",
     "border-width" => 2px)
     output = div("cell$(cell.id)out")
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
     push!(inner, sidebox, inside)
    push!(outside, inner, output)
    bind!(c, cm, inside, km)
    outside
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function realevaluate(c::Connection, cm::ComponentModifier, cell::Cell{:helprepl},
    cells::Vector{Cell}, proj::Project{<:Any})
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
    cells::Vector{Cell}, proj::Project{<:Any})
    km = cell_bind!(c, cell, cells, proj)
    src = ""
    if contains(cell.source, "#")
        src = split(cell.source, "?")[2]
    end
    cell.source = src
    outside = div("cellcontainer$(cell.id)", class = "cell")
    inner  = div("cellinside$(cell.id)")
    style!(inner, "display" => "flex")
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = "")
    bind!(km, "Backspace") do cm2::ComponentModifier
        if cm2["rawcell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell(pos, "code", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm2, outside)
            built = build(c, cm2, new_cell, cells, proj)
            ToolipsSession.insert!(cm2, windowname, pos, built)
            focus!(cm2, "cell$(cell.id)")
        end
    end
    bind!(km, "Enter") do cm2::ComponentModifier
        realevaluate(c, cm2, cell, cells, proj)
    end
    sidebox = div("cellside$(cell.id)")
    style!(sidebox, "display" => "inline-block",
    "background-color" => "red",
    "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px,
    "overflow" => "hidden", "border-style" => "solid",
    "border-width" => 2px)
    pkglabel =  a("$(cell.id)helplabel", text = "shell>")
    style!(pkglabel, "font-weight" => "bold", "color" => "white")
    push!(sidebox, pkglabel)
    style!(inside, "width" => 80percent, "border-bottom-left-radius" => 0px,
    "border-top-left-radius" => 0px,
    "min-height" => 50px, "display" => "inline-block",
     "margin-top" => 0px, "font-weight" => "bold",
     "background-color" => "#b33000", "color" => "white", "border-style" => "solid",
     "border-width" => 2px)
     output = div("cell$(cell.id)out")
     if contains(cell.outputs, ";")
         spl = split(cell.outputs, ";")
         lastoutput = spl[1]
         pinned = spl[2]
         [begin
            if pin != " "
                push!(output, iframe("$(e)$(cell.id)pin", width = "500", height = "500",
                src = "/doc?mod=$(windowname)&get=$pin"))
            end
        end for (e, pin) in enumerate(split(pinned, " "))]
     else
         cell.outputs = " ; "
     end
     push!(inner, sidebox, inside)
    push!(outside, inner, output)
    bind!(c, cm, inside, km)
    outside
end
#==output[code]
Session cells
==#
#==|||==#
function realevaluate(c::Connection, cm::ComponentModifier, cell::Cell{:shell},
    cells::Vector{Cell}, proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    mod = c[:OliveCore].open[getname(c)][windowname][:mod]
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
    cells::Vector{Cell}, proj::Project{<:Any})
    cell.source = ""
    windowname::String = proj.id
    km = cell_bind!(c, cell, cells, proj)
    outside = div("cellcontainer$(cell.id)", class = "cell")
    output = div("cell$(cell.id)out")
    style!(output, "background-color" => "#301934", "color" => "white",
    "font-size" => 14pt, "opacity" => 0percent, "height" => 0percent,
    "width" => 50percent, "margin-left" => 30px, "transition" => 1seconds)
    cmds = div("$(cell.id)cmds", text = replace(cell.source, "\n" => "<br>"))
    interior = div("cellinterior$(cell.id)")
    style!(interior, "display" => "flex")
    inside = ToolipsDefaults.textdiv("cell$(cell.id)", text = cell.outputs)
    bind!(km, "Backspace", prevent_default = false) do cm2::ComponentModifier
        if cm2["rawcell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell(pos, "code", "")
            cells[pos] = new_cell
            cell = new_cell
            remove!(cm2, outside)
            built = build(c, cm2, new_cell, cells, proj)
            ToolipsSession.insert!(cm2, windowname, pos, built)
            focus!(cm2, "cell$(cell.id)")
        end
    end
    bind!(km, "Enter") do cm2::ComponentModifier
        realevaluate(c, cm2, cell, cells, proj)
    end
    sidebox = div("cellside$(cell.id)")
    style!(sidebox, "display" => "inline-block",
    "background-color" => "blue",
    "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px,
    "overflow" => "hidden", "border-width" => 2px, "border-style" => "solid")
    pkglabel =  a("$(cell.id)pkglabel", text = "pkg>")
    style!(pkglabel, "font-weight" => "bold", "color" => "white")
    push!(sidebox, pkglabel)
    style!(inside, "width" => 80percent, "border-bottom-left-radius" => 0px,
    "border-top-left-radius" => 0px,
    "min-height" => 50px, "display" => "inline-block",
     "margin-top" => 0px, "font-weight" => "bold",
     "background-color" => "#301934", "color" => "white", "border-width" => 2px,
     "border-style" => "solid")
    push!(interior, sidebox, inside)
    push!(outside, interior, output, cmds)
    bind!(c, cm, inside, km, ["cell$(cell.id)"])
    outside
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function realevaluate(c::Connection, cm::ComponentModifier, cell::Cell{:pkgrepl},
    cells::Vector{Cell}, proj::Project{<:Any})
    mod = proj[:mod]
    rt = cm["cell$(cell.id)"]["text"]
    args = split(rt, " ")
    evalstr = "Pkg.$(args[1])("
    if length(args) != 1
        for command in args[2:length(args)]
            if command[1] == "clear"
                cell.source = ""
                set_text!(cm, "cell$(cell.id)out", "")
                set_text!(cm, "$(cell.id)cmds", "")
            end
            if contains(command, "http")
                evalstr = evalstr * "url = \"$(command)\", "
                continue
            end
            if command == "" || command == " "
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

function build(c::Connection, cm::ComponentModifier, cell::Cell{:include},
    cells::Vector{Cell}, proj::Project{<:Any})
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    ToolipsMarkdown.julia_block!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell, cells,
    proj, sidebox = true, highlight = true)
    km = cell_bind!(c, cell, cells, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    style!(interior[:children]["cellside$(cell.id)"],
    "background-color" => "red")
    inp[:children]["cellhighlight$(cell.id)"][:text] = string(tm)
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km)
    builtcell::Component{:div}
end

function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:include},
    cells::Vector{Cell}, proj::Project{<:Any})
    cell.source = cm["cell$(cell.id)"]["text"]
    tm = ToolipsMarkdown.TextStyleModifier(cell.source)
    ToolipsMarkdown.julia_block!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
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
function build(c::Connection, cm::ComponentModifier, cell::Cell{:docmodule},
    cells::Vector{Cell}, proj::Project{<:Any})
    mainbox::Component{:section} = section("cellcontainer$(cell.id)")
    n::Vector{Symbol} = names(cell.outputs, all = true)
    remove::Vector{Symbol} =  [Symbol("#eval"), Symbol("#include"), :eval, :example, :include, Symbol(string(cell.outputs))]
    filter!(x -> ~(x in remove) && ~(contains(string(x), "#")), n)
    selectorbuttons::Vector{Servable} = [begin
        docdiv = div("doc$name", text = string(name))
        on(c, docdiv, "click") do cm2::ComponentModifier
            exp = Meta.parse("""t = eval(Meta.parse("$name")); @doc(t)""")
            docs = cell.outputs.eval(exp)
            docum = tmd("docs$name", string(docs))
            append!(cm2, docdiv, docum)
        end
        docdiv
    end for name in n]
    mainbox[:children] = vcat([h("$(cell.outputs)", 2, text = string(cell.outputs))], selectorbuttons)
    mainbox
end
