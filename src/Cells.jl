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
    windowname::String = proj.id
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    cellid::String = cell.id
    pos = findfirst(lcell -> lcell.id == cellid, cells)
    if pos != 1
        switchcell = cells[pos - 1]
        remove!(cm2, "cellcontainer$(switchcell.id)")
        remove!(cm2, "cellcontainer$cellid")
        ToolipsSession.insert!(cm2, windowname, pos - 1, build(c, cm2, switchcell, proj))
        ToolipsSession.insert!(cm2, windowname, pos - 1, build(c, cm2, cell, proj))
        focus!(cm2, "cell$cellid")
        cells[pos] = switchcell
        cells[pos - 1] = cell
    else
        olive_notify!(cm2, "this cell cannot go up any further!", color = "red")
    end
    push!(CORE.open[getname(c)].cell_ops, CellOperation{:cellup}(cell, pos))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_down!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any})
    windowname::String = proj.id
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    cellid::String = cell.id
    pos = findfirst(lcell -> lcell.id == cellid, cells)
    if pos != length(cells)
        switchcell = cells[pos]
        remove!(cm, "cellcontainer$(switchcell.id)")
        remove!(cm, "cellcontainer$(cellid)")
        ToolipsSession.insert!(cm, windowname, pos, build(c, cm, switchcell, proj))
        ToolipsSession.insert!(cm, windowname, pos + 1, build(c, cm, cell, proj))
        focus!(cm, "cell$(cellid)")
        cells[pos] = switchcell
        cells[pos + 1] = cell
    else
        olive_notify!(cm, "this cell cannot go down any further!", color = "red")
    end
    push!(CORE.open[getname(c)].cell_ops, CellOperation{:celldown}(cell, pos))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_delete!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    cells::Vector{Cell{<:Any}})
    cellid::String = cell.id
    pos = findlast(tempcell::Cell{<:Any} -> tempcell.id == cellid, cells)
    if isnothing(pos)
        @info [lcell.id for lcell in cells]
        @info cell.id
    end
    if pos == 1
        focus!(cm, "cell$(cells[pos + 1].id)")
    else
        focus!(cm, "cell$(cells[pos - 1].id)")
    end
    remove!(cm, "cellcontainer$(cellid)")
    push!(CORE.open[getname(c)].cell_ops, CellOperation{:delete}(cell, pos))
    deleteat!(cells, pos)
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
    newcell = Cell(type, "")
    insert!(cells, pos + 1, newcell)
    ToolipsSession.insert!(cm, windowname, pos + 1, build(c, cm, newcell,
    proj))
    focus!(cm, "cell$(newcell.id)")
    cm["cell$(newcell.id)"] = "contenteditable" => "true"
    nothing::Nothing
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
    selected_cell = cells[i - 1]
    focus_on!(c, cm, selected_cell, proj)
    focus_off!(c, cm, cell, proj)
    nothing::Nothing
end

focus_on!(c::AbstractConnection, cm::ComponentModifier, selected_cell::Cell{<:Any}, 
    proj::Project{<:Any}) = begin
    focus!(cm, "cell" * selected_cell.id)
end

focus_on!(c::AbstractConnection, cm::ComponentModifier, selected_cell::Cell{:markdown}, 
    proj::Project{<:Any}) = begin
    on(cm, 50) do cl::ClientModifier
        focus!(cl, "cell" * selected_cell.id)
    end
    cm["cell" * selected_cell.id] = "contenteditable" => "true"
    set_text!(cm, "cell" * selected_cell.id, selected_cell.source)
    cell_highlight!(c, cm, selected_cell, proj)
    nothing::Nothing
end

focus_off!(c::AbstractConnection, cm::ComponentModifier, cell::Cell{<:Any}, proj::Project{<:Any}) = begin

end

focus_off!(c::AbstractConnection, cm::ComponentModifier, selected_cell::Cell{:markdown}, proj::Project{<:Any}) = begin
    set_children!(cm, "cell" * selected_cell.id, [tmd("-", selected_cell.source)])
    set_text!(cm, "cellhighlight$(selected_cell.id)", "")
    cm["cell$(selected_cell.id)"] = "contenteditable" => "false"
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
    selected_cell = cells[i + 1]
    focus_on!(c, cm, selected_cell, proj)
    focus_off!(c, cm, cell, proj)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function ToolipsSession.bind(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any})

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
function build_base_cell(c::Connection, cell::Cell{<:Any}, d::Directory{<:Any}; binding::Bool = true)
    cellid::String = cell.id
    hiddencell::Component{:div} = div("cell$cellid", class = "file-cell")
    name::Component{:a} = a("cell$(cellid)label", text = cell.source)
    outputfmt::String = "b"
    fs::Number = filesize(cell.outputs)
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
    if binding
        on(c, hiddencell, "dblclick") do cm::ComponentModifier
            cs::Vector{Cell{<:Any}} = olive_read(cell)
            add_to_session(c, cs, cm, cell.source, cell.outputs)
        end
    end
    finfo::Component{:a} = a("cell$(cellid)info", text =  string(fs) * outputfmt)
    style!(finfo, "color" => "white", "font-weight" => "bold", "margin-left" => 15percent)
    delbutton::Component{:span} = topbar_icon("$(cellid)expand", "cancel")
    copyb::Component{:span} = topbar_icon("copb$(cellid)", "copy")
    on(c, delbutton, "click") do cm::ComponentModifier
        new_dialog = olive_confirm_dialog(c, "delete file $(cell.outputs)?") do cm::ComponentModifier
            rm(cell.outputs)
            olive_notify!(cm, "file $(cell.outputs) deleted", color = "red")
            remove!(cm, hiddencell)
        end
        append!(cm, "mainbody", new_dialog)
    end
    on(c, copyb, "click") do cm::ComponentModifier
        splt = split(cell.outputs, "/")
        nfmt = split(splt[length(splt)], ".")
        creatorcell = Cell("creator", string(nfmt[1]), "copy")
        built = build(c, creatorcell, string(nfmt[2])) do cm::ComponentModifier
            fmat = cm["formatbox"]["value"]
            ext = OliveExtension{Symbol(fmat)}()
            finalname = cm["new_namebox"]["text"] * ".$fmat"
            path = cm["selector"]["text"]
            cp(cell.outputs, path * "/" * finalname)
        end
        insert!(cm, "pwdmain", 2, built)
    end
    movbutton::Component{:span} = topbar_icon("$(cellid)move", "drive_file_move")
    on(c, movbutton, "click") do cm::ComponentModifier
        switch_work_dir!(c, cm, d.uri)
        splt = split(cell.outputs, "/")
        nfmt = split(splt[length(splt)], ".")
        creatorcell = Cell("creator", string(nfmt[1]), "move")
        built = build(c, creatorcell, string(nfmt[2])) do cm::ComponentModifier
            fmat = cm["formatbox"]["value"]
            ext = OliveExtension{Symbol(fmat)}()
            finalname = cm["new_namebox"]["text"] * ".$fmat"
            path = cm["selector"]["text"]
            mv(cell.outputs, path * "/" * finalname)
        end
        insert!(cm, "pwdmain", 2, built)
    end
    editbutton::Component{:span} = topbar_icon("$(cellid)edit", "edit")
    on(c, editbutton, "click") do cm
        ToolipsSession.bind(c, cm, name, "Enter") do cm2::ComponentModifier
            fname = replace(cm2[name]["text"], "\n" => "")
            new_dialog = olive_confirm_dialog(c, "rename file $(cell.outputs) to $(fname)?") do cm::ComponentModifier
                ps = split(cell.outputs, "/")
                nps = ps[1:length(ps) - 1]
                push!(nps, SubString(fname))
                joined = join(nps, "/")
                newfd = read(cell.outputs, String)
                rm(cell.outputs)
                open(joined, "w") do o::IO
                    write(o, newfd)
                end
                cell.outputs = joined
                cell.source = fname
                olive_notify!(cm, "file renamed", color = "green")
                cm2[name] = "contenteditable" => "false"
                set_text!(cm, name, fname)
            end
            append!(cm2, "mainbody", new_dialog)
        end
        cm[name] = "contenteditable" => "true"
        set_text!(cm, name, "")
        focus!(cm, name)
    end
    style!(delbutton, "color" => "white", "font-size" => 17pt)
    style!(movbutton, "color" => "white", "font-size" => 17pt)
    style!(copyb, "color" => "white", "font-size" => 17pt)
    style!(editbutton, "color" => "white", "font-size" => 17pt)
    style!(name, "color" => "white", "font-weight" => "bold",
    "font-size" => 14pt, "margin-left" => 5px, "pointer-events" => "none")
    push!(hiddencell, delbutton, movbutton, copyb, editbutton, name, finfo)
    hiddencell::Component{:div}
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
        Cell("txt", string(cellsource)) 
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

function olive_read(cell::Cell{:olivestyle})::Vector{Cell}
    cells = read_toml(cell.outputs)
    if length(cells) > 1
        cells[2:end]
    else
        cells
    end
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
function olive_save(p::Project{<:Any}, pe::ProjectExport{<:Any})
    IPyCells.save(p.data[:cells], p.data[:path])
    nothing
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_save(p::Project{<:Any}, pe::ProjectExport{:jl})
    IPyCells.save(p.data[:cells], p.data[:path])
    nothing
end

function olive_save(p::Project{<:Any}, pe::ProjectExport{:raw})
    IPyCells.save(p.data[:cells], p.data[:path], raw = true)
    nothing
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_save(p::Project{<:Any}, pe::ProjectExport{:ipynb})
    IPyCells.save_ipynb(p.data[:cells], p.data[:path])
    nothing
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function olive_save(p::Project{<:Any}, pe::ProjectExport{:toml})
    joinedstr = join((cell.source for cell in p.data[:cells]), "\n")
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
            Cell(fending, fname, replace(dir * "/" * path, "\\" => "/"))
        else
            return
        end
    else
        if pwd
            Cell("switchdir", path, dir)
        else
            Cell("dir", path, dir)
        end
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cell::Cell{:dir}, d::Directory{<:Any}; bind::Bool = true)
    cellid::String = cell.id
    container = div("cellcontainer$(cellid)")
    style!(container, "padding" => 0px, "border-radius" => 0px, 
    "padding" => 0px, "margin-bottom" => 0px, "overflow" => "visible", "border-radius" => 0px, 
    "border-bottom" => "2px solid #3b444b", "width" => 100percent)
    filecell = build_base_cell(c, cell, d, binding = false)
    cdto = topbar_icon("$(cellid)cd", "file_open")
    on(c, cdto, "click") do cm::ComponentModifier
        switch_work_dir!(c, cm, cell.outputs * "/" * cell.source)
    end
    style!(cdto, "font-size" => 17pt, "color" => "white")
    filecell[:children] = vcat(cdto, filecell[:children][4:5])
    filecell[:ex] = "0"
    childbox = div("child$(cellid)")
    style!(childbox, "opacity" => 0percent, "border-left" => "10px solid", "border-radius" => 0px,
    "border-color" => "#18191A", "height" => 0percent,  "background-color" => "#3b444b",
    "transition" => "600ms", "padding" => 0px, "overflow" => "visible", "pointer-events" => "none")
    style!(filecell, "background-color" => "#18191A")
    if bind
        on(c, filecell, "click") do cm::ComponentModifier
            childs = Vector{AbstractComponent}([begin
            build(c, mcell, d)
            end
            for mcell in directory_cells(cell.outputs * "/" * cell.source)])
            if cm[filecell]["ex"] == "0"
                style!(cm, childbox, "height" => "auto", "opacity" => 100percent, "pointer-events" => "auto")
                set_children!(cm, childbox, childs)
                cm[filecell] = "ex" => "1"
                return
            end
            style!(cm, childbox, "opacity" => 0percent, "height" => 0percent, "pointer-events" => "none")
            cm[filecell] = "ex" => "0"
        end
    end
    push!(container, filecell, childbox)
    container
end

function build(c::Connection, cell::Cell{:switchdir}, d::Directory{<:Any}, bind::Bool = true)
    filecell::Component{<:Any} = build_base_cell(c, cell, d, binding = false)
    filecell[:children] = filecell[:children][5:5]
    if getname(c) == c[:OliveCore].data["root"]
        cellid::String = cell.id
        addir::Component{:span} = topbar_icon("$(cellid)adddir", "save")
        cdto::Component{:span} = topbar_icon("$(cellid)cd", "file_open")
        style!(cdto, "font-size" => 17pt, "color" => "white")
        style!(addir, "font-size" => 17pt, "color" => "white")
        on(c, addir, "click") do cm::ComponentModifier
            direcs = c[:OliveCore].open[getname(c)].directories
            path::String = cell.outputs * "/" * cell.source
            inalready = findfirst(d -> d.uri == path, direcs)
            if isnothing(inalready)
                newdir::Directory{<:Any} = Directory(path)
                push!(direcs, newdir)
                append!(cm, "projectexplorer", build(c, newdir))
                olive_notify!(cm, "directory added to instance")
                return
            end
            olive_notify!(cm, "$path is already in your project explorer!", color = "darkred")
        end
        on(c, cdto, "click") do cm::ComponentModifier
            switch_work_dir!(c, cm, cell.outputs * "/" * cell.source)
        end
        insert!(filecell[:children], 1, cdto)
        insert!(filecell[:children], 1, addir)
    end
    style!(filecell, "background-color" => "#18191A")
    if bind
        on(c, filecell, "dblclick") do cm::ComponentModifier
            switch_work_dir!(c, cm, cell.outputs * "/" * cell.source)
        end
    end
    filecell
end

function build(c::Connection, cell::Cell{:retdir}, d::Directory{<:Any}, bind::Bool = true)
    filecell = build_base_cell(c, cell, d, binding = false)
    filecell[:children] = filecell[:children][5:5]
    filecell[:children][1][:text] = "..."
    style!(filecell, "background-color" => "darkred")
    if bind
        newpspl::Vector{SubString} = split(d.uri, "/")
        newdir::String = join(newpspl[1:length(newpspl) - 1], "/")
        on(c, filecell, "click") do cm::ComponentModifier
            switch_work_dir!(c, cm, newdir)
        end
    end
    filecell
end

function build(f::Function, c::Connection, cell::Cell{:creator}, template::String = "jl")
    d = Directory(c[:OliveCore].open[getname(c)].pwd)
    maincell::Component{:div} = build_base_cell(c, cell, d, binding = false)
    style!(maincell, "display" => "flex", "background-color" => "#64bf6a")
    namebox = Components.textdiv("new_namebox", text = cell.source)
    style!(namebox, "width" => 50percent, "border" => "1px solid", "background-color" => "white", 
    "border-radius" => 0px)
    savebutton = button("confirm_new", text = cell.outputs)
    cancelbutton = button("cancel_new", text = "cancel")
    on(c, cancelbutton, "click") do cm::ComponentModifier
        remove!(cm, maincell)
    end
    not_this_template = Symbol(template)
    opts = Vector{AbstractComponent}(filter(x -> ~(isnothing(x)), [begin
        Tsig = m.sig.parameters[4]
        if Tsig != OliveExtension{<:Any} && Tsig.parameters[1] != not_this_template
            Components.option("creatorkey", text = string(Tsig.parameters[1]))   
        end        
    end for m in methods(create_new)]))
    push!(opts, Components.option("creatorkey", text = template))
    formatbox = Components.select("formatbox", opts, value = template)
    style!(formatbox, "width" => 25percent)
    on(c, savebutton, "click") do cm::ComponentModifier
        f(cm)
        remove!(cm, "cell$(cell.id)")
    end
    maincell[:children] = [namebox, formatbox, cancelbutton, savebutton]
    maincell
end

function build(c::Connection, cell::Cell{:creator}, p::Project{<:Any}, cm::ComponentModifier, template::String = "jl")
    projpath = c[:OliveCore].open[getname(c)].pwd
    if :path in keys(p.data)
        projpath::String = p[:path]
    end
    switch_work_dir!(c, cm, projpath)
    save_split = split(projpath, "/")
    nfmt = split(save_split[length(save_split)], ".")
    d = Directory(join(save_split[1:length(save_split) - 1], "/"))
    maincell = build_base_cell(c, cell, d, binding = false)
    style!(maincell, "display" => "flex", "background-color" => "#64bf6a")
    namebox = Components.textdiv("new_namebox", text = string(nfmt[1]))
    style!(namebox, "width" => 50percent, "border" => "1px solid", "background-color" => "white", 
    "border-radius" => 0px)
    savebutton = button("confirm_new", text = cell.outputs)
    cancelbutton = button("cancel_new", text = "cancel")
    on(c, cancelbutton, "click") do cm::ComponentModifier
        remove!(cm, maincell)
    end
    not_this_template = Symbol(template)
    opts = Vector{AbstractComponent}(filter(x -> ~(isnothing(x)), [begin
        Tsig = m.sig.parameters[3]
        if Tsig != ProjectExport{<:Any} && Tsig.parameters[1] != not_this_template
            Components.option("creatorkey", text = string(Tsig.parameters[1]))   
        end        
    end for m in methods(olive_save)]))
    insert!(opts, 1, Components.option("creatorkey", text = template))
    formatbox = Components.select("formatbox", opts, value = template)
    if length(nfmt) > 1
        formatbox[:value] = string(nfmt[2])
    end
    style!(formatbox, "width" => 25percent)
    on(c, savebutton, "click") do cm::ComponentModifier
        fname = cm[namebox]["text"]
        fmtn = cm[formatbox]["value"]
        direc = cm["selector"]["text"]
        if ~(contains(fname, ".$fmtn"))
            fname = fname * ".$fmtn"
        end
        p.data[:path] = direc * "/" * fname 
        p.data[:export] = string(fmtn)
        save_project(c, cm, p)
        remove!(cm, "cell$(cell.id)")
        set_text!(cm, "tablabel$(p.id)", fname)
    end
    maincell[:children] = [namebox, formatbox, cancelbutton, savebutton]
    maincell
end

function build(c::Connection, cell::Cell{:creator}, d::Directory{:home})
    maincell = build_base_cell(c, cell, d, binding = false)
    addheading = a("addheading", text = "add extension")
    style!(addheading, "color" => "white", "font-weight" => "bold")
    nameenter = Components.textdiv("extensionn", text = "OliveDefaults")
    addbutt = button("addextb", text = "add")
    style!(maincell, "display" => "flex", "background-color" => "#D90166")
    cancelbutton = button("cancel_new", text = "cancel")
    on(c, cancelbutton, "click") do cm::ComponentModifier
        remove!(cm, maincell)
    end
    on(c, addbutt, "click") do cm::ComponentModifier
        packg = cm[nameenter]["text"]
        try
            packgn = packg
            if contains(packg, "http")
                Pkg.add(url = packg)
                pkgsplit = split(packg, "/")
                packgn = split(pkgsplit[length(pkgsplit)], ".")[1]
            else
                Pkg.add(packg)
            end
            srcp = c[:OliveCore].data["home"] * "/src/olive.jl"
            current = read(srcp, String)
            curr = current * "#==|||==#\nusing $packg\n#==output[code]\n==#\n"
            open(srcp, "w") do o::IO
                write(o, curr)
            end
            remove!(cm, maincell)
            olive_notify!(cm, "added extension $packg", color = "#D90166")
        catch e
            show(e)
            olive_notify!(cm, "could not add package $packg", color = "darkred")
        end
    end
    on(nameenter, "click") do cl::ClientModifier
        set_text!(cl, nameenter, "")
    end
    style!(nameenter, "width" => 70percent, "border-radius" => 0px, "border" => "2px solid darkgray", 
    "background-color" => "#301934", "color" => "white")
    maincell[:children] = [addheading, nameenter, cancelbutton, addbutt]
    maincell
end

#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cell::Cell{:ipynb},
    d::Directory{<:Any})
    filecell = build_base_cell(c, cell, d)
    on(c, filecell, "dblclick") do cm::ComponentModifier
        cs::Vector{Cell{<:Any}} = olive_read(cell)
        proj = add_to_session(c, cs, cm, cell.source, cell.outputs)
        proj.data[:export] = "ipynb"
    end
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
            Cell("tomlvalues", concat)
        elseif length(line) > 1
            if contains(line[1:3], "[")
                source = concat
                concat = line * "\n"
                Cell("tomlvalues", source)
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

string(cell::Cell{:tomlvalues}) = ""

#==
Session cells
==#

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
- `ToolipsSession.bind`
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
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = false)
    km::ToolipsSession.KeyMap = cell_bind!(c, cell, proj)
    cellid::String = cell.id
    interior = builtcell[:children]["cellinterior$cellid"]
    sidebox = interior[:children]["cellside$cellid"]
    sidebox[:children] = Vector{AbstractComponent}([a("unknown", text = "$(typeof(cell).parameters[1])", align = "center")])
    style!(sidebox[:children][1], "color" => "darkred")
    style!(sidebox, "background" => "transparent")
    inp = interior[:children]["cellinput$cellid"]
    ToolipsSession.bind(c, cm, inp[:children]["cell$cellid"], km)
    style!(inp[:children]["cell$(cellid)"], "color" => "black")
    builtcell::Component{:div}
end

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
    cellid::String = cell.id
    pos = findfirst(lcell -> lcell.id == cellid, cells)
    cell.source = cm["cell$(cellid)"]["text"]
    if pos != length(cells)
        focus!(cm, "cell$(cells[pos + 1].id)")
    else
        new_cell = Cell("creator", "")
        push!(cells, new_cell)
        ToolipsSession.append!(cm, proj.id, build(c, cm, new_cell, proj))
        focus!(cm, "cell$(new_cell.id)")
    end
end


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
    tm = OliveHighlighters.Highlighter(cell.source)
    python_block!(tm)
    set_text!(cm, "cellhighlight\$(cell.id)", string(tm))
end
```
"""
function cell_highlight!(c::Connection,   cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any})
end

function cell_open!(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any})
    olive_notify!(cm2, "this cell does not have an `open` binding", color = "red")
end

function get_highlighter(c::Connection, cell::Cell{<:Any})
    nothing::Nothing
end

function get_highlighter(c::Connection, cell::Cell{:code})
    c[:OliveCore].client_data[getname(c)]["highlighters"]["julia"]
end

function get_highlighter(c::Connection, cell::Cell{:markdown})
    c[:OliveCore].client_data[getname(c)]["highlighters"]["markdown"]
end

function get_highlighter(c::Connection, cell::Cell{:tomlvalues})
    c[:OliveCore].client_data[getname(c)]["highlighters"]["toml"]
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
function cell_bind!(c::Connection, cell::Cell{<:Any}, proj::Project{<:Any}, km::ToolipsSession.KeyMap = ToolipsSession.KeyMap())
    keybindings = c[:OliveCore].client_data[getname(c)]["keybindings"]
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    ToolipsSession.bind(km, keybindings["save"], prevent_default = true) do cm::ComponentModifier
        save_project(c, cm, proj)
    end
    ToolipsSession.bind(km, keybindings["saveas"], prevent_default = true) do cm::ComponentModifier
        style!(cm, "projectexplorer", "width" => "500px")
        style!(cm, "olivemain", "margin-left" => "500px")
        style!(cm, "explorerico", "color" => "lightblue")
        set_text!(cm, "explorerico", "folder_open")
        cm["olivemain"] = "ex" => "1"
        save_project_as(c, cm, proj)
    end
    ToolipsSession.bind(km, keybindings["focusup"]) do cm::ComponentModifier
        focus_up!(c, cm, cell, proj)
    end
    ToolipsSession.bind(km, keybindings["up"]) do cm2::ComponentModifier
        cell_up!(c, cm2, cell, proj)
    end
    ToolipsSession.bind(km, keybindings["down"]) do cm2::ComponentModifier
        cell_down!(c, cm2, cell, proj)
    end
    ToolipsSession.bind(km, keybindings["project-new"], prevent_default = true) do cm2::ComponentModifier
        creatorcell::Cell{:creator} = Cell("creator", "", "save")
        cm2["settingsmenu"] =  "open" => "0"
        cm2["settingicon"] = "class" => "material-icons"
        cm2["settingsmenu"] = "class" => "settings"
        cm2["projectexplorer"] = "class" => "pexplorer pexplorer-open"
        style!(cm2, "olivemain", "margin-left" => "500px")
        cm2["explorerico"] = "class" => "material-icons material-icons-selected"
        style!(cm2, "menubar", "border-bottom-left-radius" => 0px)
        set_text!(cm2, "explorerico", "folder_open")
        cm2["olivemain"] = "ex" => "1"
        insert!(cm2, "pwdmain", 2, build(c, creatorcell, p, cm2))
    end
    ToolipsSession.bind(km, keybindings["explorer"], prevent_default = true) do cm2::ComponentModifier
        cm2["settingsmenu"] =  "open" => "0"
        cm2["settingicon"] = "class" => "material-icons"
        cm2["settingsmenu"] = "class" => "settings"
        cm2["projectexplorer"] = "class" => "pexplorer pexplorer-open"
        style!(cm2, "olivemain", "margin-left" => "500px")
        cm2["explorerico"] = "class" => "material-icons material-icons-selected"
        style!(cm2, "menubar", "border-bottom-left-radius" => 0px)
        set_text!(cm2, "explorerico", "folder_open")
        cm2["olivemain"] = "ex" => "1"
    end
    ToolipsSession.bind(km, keybindings["delete"]) do cm2::ComponentModifier
        cellid::String = cell.id
        if length(cells) == 1
            olive_notify!(cm2, "you cannot the last cell in the project", color = "red")
            return
        end
        style!(cm2, "cellcontainer$(cellid)", "transform" => translateX(-100percent))
        deleted::Bool = false
        on(c, cm2, 350) do cm::ComponentModifier
            if ~ deleted
                deleted = true
                cell_delete!(c, cm, cell, proj.data[:cells])
            end
        end
    end
    ToolipsSession.bind(km, keybindings["new"]) do cm2::ComponentModifier
        cell_new!(c, cm2, cell, proj)
    end
    ToolipsSession.bind(km, keybindings["evaluate"]) do cm2::ComponentModifier
        cellid::String = cell.id
        icon = olive_loadicon()
        icon.name = "load$(cell.id)"
        icon["width"] = "16"
        append!(cm2, "cellside$(cell.id)", icon)
        on(c, cm2, 100) do cm::ComponentModifier
            evaluate(c, cm, cell, proj)
            remove!(cm, "load$(cell.id)")
        end
    end
    ToolipsSession.bind(km, keybindings["copy"]) do cm2::ComponentModifier
        env = c[:OliveCore].open[getname(c)]
        if length(env.cells_selected) == 0
            env.cell_clipboard = [cell.id => proj.id]
            olive_notify!(cm2, "Cell added to clipboard")
            return
        end
        env.cell_clipboard = [pairs(env.cells_selected) ...] 
        message = "cell"
        if length(env.cell_clipboard) > 1
            message = "cells"
        end
        olive_notify!(cm2, "$message added to clipboard")
    end
    ToolipsSession.bind(km, keybindings["paste"]) do cm2::ComponentModifier
        env = c[:OliveCore].open[getname(c)]
        found_pos = findfirst(lcell -> lcell.id == cell.id, proj.data[:cells])
        paste_cells = [begin
            old_cell = env[cell_path[2]].data[:cells][cell_path[1]]
            new_cell = Cell{typeof(old_cell).parameters[1]}(old_cell.source, old_cell.outputs)
            new_cell.id = Components.gen_ref(5)
            built_cell = build(c, cm2, new_cell, proj)
            ToolipsSession.insert!(cm2, proj.id, e + found_pos, built_cell)
            new_cell
        end for (e, cell_path) in enumerate(env.cell_clipboard)]
        proj.data[:cells] = vcat(proj.data[:cells][1:found_pos], paste_cells, proj.data[:cells][found_pos + 1:end])
    end
    original_class_inp = ""
    original_class_side = ""
    ToolipsSession.bind(km, keybindings["select"]) do cm2::ComponentModifier
        env::Environment = CORE.open[getname(c)]
        cellid::String = cell.id
        if cellid in keys(env.cells_selected)
            delete!(env.cells_selected, cellid)
            cm2["cellside$(cellid)"] = "class" => original_class_side
            cm2["cell$cellid"] = "class" => original_class_inp
            return
        end
        push!(env.cells_selected, cell.id => proj.id)
        original_class_side = cm2["cellside$cellid"]["class"]
        original_class_inp = cm2["cell$cellid"]["class"]
        cm2["cellside$(cellid)"] = "class" => "cellside selectedside"
        cm2["cell$cellid"] = "class" => "input_cell inputselected"
    end
    ToolipsSession.bind(km, keybindings["open"]) do cm2::ComponentModifier
        cell_open!(c, cm2, cell, proj)
    end
    ToolipsSession.bind(km, keybindings["find"], prevent_default = true) do cm2::ComponentModifier
        found_items::Dict{String, Vector{UnitRange{Int64}}} = Dict{String, Vector{UnitRange{Int64}}}()
        if "findbox" in cm2
            found_items = Dict{String, Vector{UnitRange{Int64}}}()
            style!(cm2, proj.id, "height" => 90percent)
            remove!(cm2, "findbar")
            return
        end
        findbar = build_findbar(c, cm2, cells, proj, found_items)
        insert!(cm2, "mainbody", 6, findbar)
        focus!(cm2, "findbox")
    end
    ToolipsSession.bind(km, keybindings["focusdown"]) do cm::ComponentModifier
        focus_down!(c, cm, cell, proj)
    end
    km::KeyMap
end

get_cell_class(cell::Cell{<:Any}) = "input_cell"

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
    cellid::String = cell.id
    windowname::String = proj.id
    inputbox::Component{:div} = div("cellinput$(cellid)")
    inside::Component{:div} = Components.textdiv("cell$(cellid)",
    text = replace(cell.source, "\n" => "</br>", " " => "&nbsp;"),
    "class" => "input_cell", "spellcheck" => false)
    Components.textdiv_caret_tracker!(inside)
    style!(inside, "border-top-left-radius" => 0px)
    if highlight
        highlight_box::Component{:div} = div("cellhighlight$(cellid)",
        text = "", class = "input_cell")
        style!(highlight_box, "position" => "absolute !important",
        "background" => "transparent", "z-index" => "5", "padding" => 20px,
        "border-top-left-radius" => "0px !important",
        "border-radius" => "0px !important",
        "border-width" =>  0px,  "pointer-events" => "none", "color" => "#4C4646 !important",
        "border-radius" => 0px, "max-width" => 90percent)
        on(c, inputbox, "keyup") do cm2::ComponentModifier
            cell_highlight!(c, cm2, cell, proj)
            style!(cm2, "tablabel$(proj.id)", "border-right" => "20px solid #79305a")
        end
        on(cm, inputbox, "paste") do cl
            push!(cl.changes, """
            event.preventDefault();
            var text = event.clipboardData.getData('text/plain');
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
    cellid::String = cell.id
    windowname::String = proj.id
    outside::Component{:div} = div("cellcontainer$(cellid)", class = "cell")
    interiorbox::Component{:div} = div("cellinterior$(cellid)")
    inputbox::Component{:div} = build_base_input(c, cm, cell, proj,
    highlight = highlight)
    output::Component{:div} = div("cell$(cellid)out", class = "output_cell")
    if typeof(cell.outputs) == String
        output[:text] = cell.outputs
    end
    if sidebox
        sidebox::Component{:div} = div("cellside$(cellid)", class = "cellside")
        cell_drag::Component{:span} = topbar_icon("cell$(cellid)drag", "drag_indicator")
        cell_run::Component{:span} = topbar_icon("cell$(cellid)drag", "play_arrow")
        on(c, cell_run, "click") do cm2::ComponentModifier
            evaluate(c, cm2, cell, proj)
        end
        original_class_side = ""
        original_class_inp = ""
        on(c, cell_drag, "click") do cm2::ComponentModifier
            env::Environment = CORE.open[getname(c)]
            if cellid in keys(env.cells_selected)
                delete!(env.cells_selected, cellid)
                cm2["cellside$(cellid)"] = "class" => original_class_side
                cm2["cell$cellid"] = "class" => original_class_inp
                return
            end
            push!(env.cells_selected, cell.id => proj.id)
            original_class_side = cm2["cellside$cellid"]["class"]
            original_class_inp = cm2["cell$cellid"]["class"]
            cm2["cellside$(cellid)"] = "class" => "cellside selectedside"
            cm2["cell$cellid"] = "class" => "input_cell inputselected"
        end
        style!(cell_drag, "color" => "white", "font-size" => 17pt)
        style!(cell_run, "color" => "white", "font-size" => 17pt)
        push!(sidebox, cell_drag, br(), cell_run)
        push!(interiorbox, sidebox, inputbox)
    else
        push!(interiorbox, inputbox)
    end
    style!(inputbox, "padding" => 0px, "width" => 100percent, "overflow-x" => "hidden",
    "overflow" => "hidden", "border-top-left-radius" => "0px",
    "border-bottom-left-radius" => 0px, "border-radius" => "0px",
    "position" => "relative", "height" => "auto")
    style!(interiorbox, "display" => "flex", "width" => "auto", "overflow" => "hidden")
    push!(outside, interiorbox, output)
    outside::Component{:div}
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    proj::Project{<:Any})
    windowname::String = proj.id
    tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["julia"]
    tm.raw = cell.source
    OliveHighlighters.mark_julia!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = true)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    maincell::Component{:div} = inp[:children]["cell$(cell.id)"]
    Components.textdiv_caret_tracker!(maincell)
    inp[:children]["cellhighlight$(cell.id)"][:text] = string(tm)
    sideb = interior[:children]["cellside$(cell.id)"]
    sideb[:class] = "cellside codeside"
    OliveHighlighters.clear!(tm)
    ToolipsSession.bind(c, cm, maincell, km, on = :down)
    [begin
        xtname = m.sig.parameters[4]
        if xtname != OliveExtension{<:Any}
            ext = xtname()
            on_code_build(c, cm, ext, cell, proj, builtcell, km)
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
    cell::Cell{:code}, proj::Project{<:Any}, km::ToolipsSession.KeyMap)

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
    cell::Cell{:code}, proj::Project{<:Any}, component::Component{:div}, km::ToolipsSession.KeyMap)

end

#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#

function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    proj::Project{<:Any})
    callback_comp::Component = cm["cell$(cell.id)"]
    curr::String = callback_comp["text"]
    [begin
        xtname = m.sig.parameters[4]
        if xtname != OliveExtension{<:Any}
            ext = xtname()
            on_code_highlight(c, cm, ext, cell, proj)
        end
        nothing
    end for m in methods(on_code_highlight)]::Vector{Nothing}
    cell.source = replace(curr, "<div>" => "", "<br>" => "\n", "&nbsp;" => " ")
    tm::Highlighter = c[:OliveCore].client_data[getname(c)]["highlighters"]["julia"]
    tm.raw = cell.source
    OliveHighlighters.mark_julia!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    OliveHighlighters.clear!(tm)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:code},
    proj::Project{<:Any})
    window::String = proj.id
    cells::Vector{Cell} = proj[:cells]
    # get code
    cell.source::String = replace(cm["cell$(cell.id)"]["text"], "&lt;" => "<")
    execcode::String = *("begin\n", cell.source, "\nend")
    ret::Any = ""
    try
        ret = proj[:mod].evalin(Meta.parse(execcode))
    catch e
        ret = e
    end
    # output
    for m in methods(on_code_evaluate)
        xtname = m.sig.parameters[4]
        if xtname != OliveExtension{<:Any}
            ext = xtname()
            on_code_evaluate(c, cm, ext, cell, proj)
        end
    end
    # we do this again, in case a code cell extension changes the output
    projects = c[:OliveCore].open[getname(c)].projects
    projpos = findfirst(p -> p.id == window, projects)
    proj = projects[projpos]
    outp::String = ""
    standard_out::String = proj[:mod].STDO
    active_display::OliveDisplay = OliveDisplay()
    if length(standard_out) > 0
        outp = standard_out
    end
    if typeof(ret) <: Exception
        display(active_display, ret)
        outp = replace(String(take!(active_display.io)), "\n" => "</br>")
    elseif ~(isnothing(ret))
        display(active_display, MIME"olive"(), ret)
        outp = outp * "</br>" * String(take!(active_display.io))
    elseif isnothing(ret)
        outp = standard_out
    end
    proj[:mod].STDO = ""
    set_text!(cm, "cell$(cell.id)out", outp)
    cell.outputs = outp
    pos = findfirst(lcell -> lcell.id == cell.id, cells)
    if isnothing(pos)
        @warn "olive cell error:"
        @info "cell $(pos) $(cell.id)"
        @info "$(length(cells))"
        @info join("$(cell.id)|" for cell in cells)
        olive_notify!(cm, "cell error! check the terminal for more details...", color = "red")
        return
    end
    if pos == length(cells)
        new_cell::Cell{:code} = Cell("code", "", id = ToolipsSession.gen_ref(4))
        push!(cells, new_cell)
        append!(cm, window, build(c, cm, new_cell, proj))
        focus!(cm, "cell$(new_cell.id)")
    end
end

function build_returner(c::Connection, path::String)
    returner_div::Component{:div} = div("returner")
    style!(returner_div, "background-color" => "red", "cursor" => "pointer")
    push!(returner_div, a("returnerbutt", text = "..."))
    on(c, returner_div, "click") do cm::ComponentModifier
        paths = split(path, "/")
        path = join(paths[1:length(paths) - 1], "/")
        set_text!(cm, "selector", path)
        set_children!(cm, "filebox", Vector{AbstractComponent}(vcat(
        build_returner(c, path),
        [build_comp(c, path, f) for f in readdir(path)]))::Vector{AbstractComponent})
    end
    returner_div::Component{:div}
end

function build_comp(c::Connection, path::String, dir::String)
    if isdir(path * "/" * dir)
        maincomp = div("$dir")
        style!(maincomp, "background-color" => "lightblue", "cursor" => "pointer")
        push!(maincomp, a("$dir-a", text = dir))
        on(c, maincomp, "click") do cm::ComponentModifier
            path = path * "/" * dir
            set_text!(cm, "selector", path)
            children = Vector{AbstractComponent}([build_comp(c, path, f) for f in readdir(path)])::Vector{AbstractComponent}
            set_children!(cm, "filebox", vcat(Vector{AbstractComponent}([build_returner(c, path)]), children))
        end
        return(maincomp)::Component{:div}
    end
    maincomp::Component{:div} = div("$dir")
    push!(maincomp, a("$dir-a", text = dir))
    maincomp::Component{:div}
end

function build(c::Connection, cell::Cell{:dirselect})
    selector_indicator::Component{:h4} = h4("selector", text = cell.source)
    path::String = cell.source
    filebox::Component{:section} = section("filebox")
    style!(filebox, "height" => 40percent, "overflow-y" => "scroll")
    filebox[:children]::Vector{AbstractComponent} = vcat(Vector{AbstractComponent}([build_returner(c, path)]),
    Vector{AbstractComponent}([build_comp(c, path, f) for f in readdir(path)]))
    cellover::Component{:div} = div("dirselectover")
    push!(cellover, selector_indicator, filebox)
    cellover::Component{:div}
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
    sideb[:children] = sideb[:children][1:2]

   # cell_edit = topbar_icon("cell$(cell.id)drag", "edit")
    #style!(cell_edit, "color" => "white", "font-size" => 17pt)
    maincell = inp[:children]["cell$(cell.id)"]
    if cell.source != ""
        maincell[:contenteditable] = false
        newtmd = tmd("cell$(cell.id)tmd", cell.source)
        push!(maincell, newtmd)
    end
    on(c, cm, maincell, "dblclick") do cm::ComponentModifier
        cm["cell$(cell.id)"] = "contenteditable" => "true"
        set_children!(cm, "cell$(cell.id)", Vector{AbstractComponent}())
        set_text!(cm, "cell$(cell.id)", replace(cell.source, "\n" => "<br>"))
        tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["markdown"]
        tm.raw = cell.source
        OliveHighlighters.mark_markdown!(tm)
        set_text!(cm, "cellhighlight$(cell.id)", string(tm))
        OliveHighlighters.clear!(tm)
    end
    km = cell_bind!(c, cell, proj)
    ToolipsSession.bind(c, cm, maincell, km)
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
    on(c, cm, 100) do cm2::ComponentModifier
        set_children!(cm2, "cellhighlight$(cell.id)", Vector{AbstractComponent}())
    end
end

function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    cell.source = replace(curr, "<br>" => "\n", "<div>" => "")
    tm::Highlighter = c[:OliveCore].client_data[getname(c)]["highlighters"]["markdown"]
    tm.raw = cell.source
    OliveHighlighters.mark_markdown!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    OliveHighlighters.clear!(tm)
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:getstarted},
    proj::Project{<:Any})
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = false, highlight = false)
    km::ToolipsSession.KeyMap = cell_bind!(c, cell, proj)
    interior::Component{:div} = builtcell[:children]["cellinterior$(cell.id)"]
    inp::Component{:div} = interior[:children]["cellinput$(cell.id)"]
    getstarted::Component{:div} = div("getstarted$(cell.id)", contenteditable = true)
    style!(getstarted, "padding" => 3px, "margin-top" => 0px, "overflow" => "visible")
    runl::Component{:div} = tmd("runl", """- use `shift` + `enter` to use this project""")
    style!(runl, "padding" => 2px)
    push!(getstarted, runl)
    buttons_box::Component{:div} = div("buttons_box")
    issues_button::Component{:button} = button("issues_button", text = "report issues or suggest improvements")
    style!(issues_button, "font-weight" => "bold", "cursor" => "pointer", "margin-left" => 3px)
    on(issues_button, "click") do cl::ClientModifier
        redirect!(cl, "https://github.com/ChifiSource/Olive.jl/issues", new_tab = true)
    end
    doc_button::Component{:button} = button("doc_button", text = "documentation")
    style!(doc_button, "font-weight" => "bold", "cursor" => "pointer")
    on(doc_button, "click") do cl::ClientModifier
        redirect!(cl, "https://chifidocs.com/olive", new_tab = true)
    end
    push!(buttons_box, issues_button, doc_button)
    dir::Directory{<:Any} = Directory("~/")
    if "recents" in keys(c[:OliveCore].client_data[getname(c)])
        recent_box::Component{:section} = section("recents")
        style!(recent_box, "padding" => 0px, "border-radius" => 0px, "overflow-x" => "visible")
        recent_box[:children]::Vector{AbstractComponent} = [begin
            psplit::Vector{SubString} = split(recent_p, "/")
            ftypesplit::Vector{SubString} = split(psplit[length(psplit)], ".")
            if length(ftypesplit) > 1
                build(c, Cell{Symbol(ftypesplit[2])}(string(ftypesplit[1]), recent_p), dir)
            else
                build(c, Cell{:none}(string(ftypesplit[1]), recent_p), dir)
            end
        end for recent_p in c[:OliveCore].client_data[getname(c)]["recents"]::Vector{String}]
        push!(getstarted, h4("recentl", text = "recent files"), recent_box)
    end
    ToolipsSession.bind(c, cm, inp[:children]["cell$(cell.id)"], km)
    style!(inp[:children]["cell$(cell.id)"], "color" => "black", "border-left" => "6px solid pink", 
    "border-top-left-radius" => 8px, "border-bottom-left-radius" => 8px, "margin-bottom" => 0px)
    inp[:children]["cell$(cell.id)"][:text]::String = ""
    inp[:children]["cell$(cell.id)"][:children]::Vector{<:AbstractComponent} = [olive_motd(), buttons_box, getstarted]
    builtcell::Component{:div}
end


function cell_bind!(c::Connection, cell::Cell{:getstarted}, proj::Project{<:Any})
    keybindings = c[:OliveCore].client_data[getname(c)]["keybindings"]
    km::ToolipsSession.KeyMap = ToolipsSession.KeyMap()
    cells::Vector{Cell{<:Any}} = proj.data[:cells]
    projid::String = proj.id
    ToolipsSession.bind(km, keybindings["evaluate"]) do cm::ComponentModifier
        remove!(cm, "cellcontainer" * cell.id)
        new_cell::Cell{:code} = Cell{:code}()
        proj.data[:cells]::Vector{Cell{<:Any}} = Vector{Cell{<:Any}}([new_cell])
        evaluate_get_started(c, cm, projid, build(c, cm, new_cell, proj), new_cell.id)
    end
    km::KeyMap
end

function evaluate_get_started(c::AbstractConnection, cm::ComponentModifier, projid::String, new_cell::AbstractComponent, 
    cellid::String)
    append!(cm, projid, new_cell)
    olive_notify!(cm, "use ctrl + shift + S to name your project!", color = "blue")
    focus!(cm, "cell$cellid")
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:creator},
    proj::Project{<:Any})
    cells = proj[:cells]
    windowname::String = proj.id
    creatorkeys = c[:OliveCore].client_data[getname(c)]["creatorkeys"]
    cbox = Components.textdiv("cell$(cell.id)", text = "")
    style!(cbox, "outline" => "transparent", "color" => "white")
    on(c, cbox, "input") do cm2::ComponentModifier
        txt = cm2[cbox]["text"]
        if txt in keys(creatorkeys)
            cellt = creatorkeys[txt]
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            remove!(cm2, buttonbox)
            new_cell = Cell(string(cellt), "")
            deleteat!(cells, pos)
            insert!(cells, pos, new_cell)
            insert!(cm2, windowname, pos, build(c, cm2, new_cell, proj))
            focus!(cm2, "cell$(new_cell.id)")
         elseif txt != ""
             olive_notify!(cm2, "$txt is not a recognized cell hotkey", color = "red")
             set_text!(cm2, cbox, "")
        end
    end
    km = cell_bind!(c, cell, proj)
    ToolipsSession.bind(c, cm, cbox, km)
    olmod = c[:OliveCore].olmod
    signatures = [m.sig.parameters[4] for m in methods(Olive.build,
    [Toolips.AbstractConnection, Toolips.Modifier, IPyCells.AbstractCell,
    Project{<:Any}])]
     buttonbox = div("cellcontainer$(cell.id)")
     push!(buttonbox, cbox)
     push!(buttonbox, h3("spawn$(cell.id)", text = "new cell"))
     for sig in signatures
         if sig in (Cell{:creator}, Cell{<:Any}, Cell{:getstarted})
             continue
         end
         if length(sig.parameters) < 1
             continue
         end
         b = button("$(sig)butt", text = string(sig.parameters[1]))
         on(c, b, "click") do cm2::ComponentModifier
             pos = findfirst(lcell -> lcell.id == cell.id, cells)
             remove!(cm2, buttonbox)
             new_cell = Cell(string(sig.parameters[1]), "")
             deleteat!(cells, pos)
             insert!(cells, pos, new_cell)
             insert!(cm2, windowname, pos, build(c, cm2, new_cell,
              proj))
         end
         push!(buttonbox, b)
     end
     buttonbox
end

