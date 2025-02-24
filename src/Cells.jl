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
        switchcell = cells[pos + 1]
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
    cellid::String = cell.id
    pos = findfirst(c -> c.id == cellid, cells)
    if isnothing(pos)
        olive_notify!(cm, "the cell was not found -- your client might be bugged, try refreshing the page !")
        return
    end
    remove!(cm, "cellcontainer$(cellid)")
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
    newcell = Cell(type, "")
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
    joinedstr = join([toml_string(cell) for cell in p.data[:cells]])
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
    @warn "hello?"
    opts = Vector{AbstractComponent}(filter(x -> ~(isnothing(x)), [begin
        Tsig = m.sig.parameters[4]
        if Tsig != OliveExtension{<:Any} && Tsig.parameters[1] != not_this_template
            @info Tsid.parameters[1]
            Components.option("creatorkey", text = string(Tsig.parameters[1]))   
        end        
    end for m in methods(create_new)]))
  # insert!(opts, 1, ))
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
        p.data[:path] = direc * "/" * fname * ".$fmtn"
        p.data[:export] = string(fmtn)
        save_project(c, cm, p)
        remove!(cm, "cell$(cell.id)")
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
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:txt},
    proj::Project{<:Any})
    cells = proj[:cells]
    cellid::String = cell.id
    pos = findfirst(lcell -> lcell.id == cellid, cells)
    cell.source = cm["cell$(cellid)"]["text"]
    if pos != length(cells)
        focus!(cm, "cell$(cells[pos + 1].id)")
    else
        new_cell = Cell("txt", "")
        push!(cells, new_cell)
        ToolipsSession.append!(cm, proj.id, build(c, cm, new_cell, proj))
        focus!(cm, "cell$(new_cell.id)")
    end
    set_text!(cm, "cell$(cellid)out", "<sep></sep>")
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
    tm = OliveHighlighters.TextStyleModifier(cell.source)
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
    ToolipsSession.bind(km, keybindings["delete"]) do cm2::ComponentModifier
        style!(cm2, "cellcontainer$(cell.id)", "transform" => translateX(-100percent))
        next!(c, cm2, "cellcontainer$(cell.id)") do cm::ComponentModifier
            cell_delete!(c, cm, cell, cells)
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
            env.cell_clipboard = [cell]
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
        cells = [begin
            old_cell = env[cell_path[2]].data[:cells][cell_path[1]]
            new_cell = Cell{typeof(old_cell).parameters[1]}(old_cell.source, old_cell.outputs)
            new_cell.id = Components.gen_ref(5)
            built_cell = build(c, cm2, new_cell, proj)
            ToolipsSession.insert!(cm2, proj.id, e + found_pos, built_cell)
            new_cell
        end for (e, cell_path) in enumerate(env.cell_clipboard)]
        proj.data[:cells] = vcat(proj.data[:cells][1:found_pos], cells, proj.data[:cells][found_pos:end])
    end
 #   ToolipsSession.bind(km, keybindings["select"]) do cm2::ComponentModifier

  #  end
    ToolipsSession.bind(km, keybindings["open"]) do cm2::ComponentModifier

    end
    ToolipsSession.bind(km, keybindings["find"]) do cm2::ComponentModifier

    end

    ToolipsSession.bind(km, keybindings["focusdown"]) do cm::ComponentModifier
        focus_down!(c, cm, cell, proj)
    end
    km::KeyMap
end
indent_after = ("begin", "function", "struct")
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

function build_base_replcell(c::Connection, cm::ComponentModifier, cell::Cell{<:Any},
    proj::Project{<:Any}; repl::String = "pkg>", replc::String = "#301934", sideboxc::String = "blue", lblc::String = "white")
    outside::Component{:div} = div("cellcontainer$(cell.id)", class = "cell")
    output::Component{:div} = div("cell$(cell.id)out")
    interior::Component{:div} = div("cellinterior$(cell.id)")
    km::ToolipsSession.KeyMap = cell_bind!(c, cell, proj)
    style!(interior, "display" => "flex")
    inside::Component{:div} = Components.textdiv("cell$(cell.id)", text = cell.outputs)
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
     "background-color" => replc, "color" => "white", "border-width" => 2px,
     "border-style" => "solid")
    push!(interior, sidebox, inside)
    push!(outside, interior, output)
    ToolipsSession.bind(c, cm, inside, km)
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

# TODO This will be part of `Olive` auto-complete instead.
function on_code_build(c::Connection, cm::ComponentModifier, oe::OliveExtension{:indent}, 
    cell::Cell{:code}, proj::Project{<:Any}, component::Component{:div}, km::ToolipsSession.KeyMap)
    ToolipsSession.bind(c, cm, component, "Enter", on = :up) do cm::ComponentModifier
        callback_comp::Component = cm["cell$(cell.id)"]
        curr::String = callback_comp["text"]
        last_n::Int64 = parse(Int64, callback_comp["caret"])
        n::Int64 = length(curr)
        previous_line_i = findprev("\n", curr, last_n)
        @info previous_line_i
        if isnothing(previous_line_i)
            @info curr
            @warn last_n
            previous_line_i = 1
        else
            previous_line_i = minimum(previous_line_i) + 1
        end
        line_slice = curr[previous_line_i:last_n]
        contains_indent::Bool = ~isnothing(findfirst(x -> contains(line_slice, x), indent_after))
        # TODO get last line, check for indent key-words, pre-indentation, and `end`.
        #<br> is replaced, so `\n` is shorter by 2. Plus, JS index starts at 0
        if contains_indent
            cell.source = curr[1:last_n] * "\n&nbsp;&nbsp;&nbsp;&nbsp;" * curr[last_n + 1:length(curr)]
            set_text!(cm, "cell$(cell.id)", cell.source)
            focus!(cm, "cell$(cell.id)")
            Components.set_textdiv_cursor!(cm, "cell$(cell.id)", last_n + 4)
        end
    end
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
    tm::TextStyleModifier = c[:OliveCore].client_data[getname(c)]["highlighters"]["julia"]
    OliveHighlighters.set_text!(tm, cell.source)
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
    cell.source::String = cm["cell$(cell.id)"]["text"]
    execcode::String = *("begin\n", cell.source, "\nend\n")
    ret::Any = ""
    try
        ret = proj[:mod].evalin(Meta.parse(execcode))
    catch e
        ret = e
    end
    # output
    [begin
        xtname = m.sig.parameters[4]
        if xtname != OliveExtension{<:Any}
            ext = xtname()
            on_code_evaluate(c, cm, ext, cell, proj)
        end
    end for m in methods(on_code_evaluate)]
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
        outp = replace(String(active_display.io.data), "\n" => "</br>")
    elseif ~(isnothing(ret))
        display(active_display, MIME"olive"(), ret)
        outp = outp * "</br>" * String(active_display.io.data)
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
    maincell[:contenteditable] = false
    newtmd = tmd("cell$(cell.id)tmd", cell.source)
    push!(maincell, newtmd)
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
    set_text!(cm, "cellhighlight$(cell.id)", "")
end

function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:markdown},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    cell.source = replace(curr, "<br>" => "\n", "<div>" => "")
    tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["markdown"]
    OliveHighlighters.set_text!(tm, cell.source)
    OliveHighlighters.mark_markdown!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    OliveHighlighters.clear!(tm)
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
    todolabel = h2("todoheader$(cell.id)", text = "TODO")
    style!(todolabel, "font-weight" => "bold")
    style!(todolabel, "color" => "pink")
    inpbox = Components.textdiv("cell$(cell.id)", text = cell.outputs)
    style!(inpbox, "background-color" => "#242526", "color" => "white",
    "padding" => 10px, "min-height" => 5percent, "font-size" => 15pt,
    "font-weight" => "bold", "outline" => "transparent",
    "-moz-appearance" => "textfield-multiline;", "white-space" => "pre-wrap",
    "-webkit-appearance" => "textarea")
    on(c, inpbox, "input") do cm::ComponentModifier
        cell.outputs = cm[inpbox]["text"]
    end
    km = cell_bind!(c, cell, proj)
    ToolipsSession.bind(km, "Backspace", prevent_default = false) do cm2::ComponentModifier
        if cm2["cell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell{:code}("")
            deleteat!(cells, pos)
            insert!(cells, pos, new_cell)
            remove!(cm2, maincontainer)
            built = build(c, cm2, new_cell, proj)
            ToolipsSession.insert!(cm2, proj.id, pos, built)
            focus!(cm2, "cell$(cell.id)")
        end
    end
    ToolipsSession.bind(c, cm, inpbox, km)
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
    todolabel = h2("todoheader$(cell.id)", text = "NOTE")
    style!(todolabel, "font-weight" => "bold", "color" => "lightblue")
    inpbox = Components.textdiv("cell$(cell.id)", text = cell.outputs)
    style!(inpbox, "background-color" => "#242526", "color" => "white",
    "padding" => 10px, "min-height" => 5percent, "font-size" => 15pt,
    "font-weight" => "bold", "outline" => "transparent",
    "-moz-appearance" => "textfield-multiline;", "white-space" => "pre-wrap",
    "-webkit-appearance" => "textarea")
    on(c, inpbox, "input") do cm::ComponentModifier
        cell.outputs = cm[inpbox]["text"]
    end
    km = cell_bind!(c, cell, proj)
    ToolipsSession.bind(km, "Backspace", prevent_default = false) do cm2::ComponentModifier
        if cm2["cell$(cell.id)"]["text"] == ""
            pos = findfirst(lcell -> lcell.id == cell.id, cells)
            new_cell = Cell{:code}("")
            deleteat!(cells, pos)
            insert!(cells, pos, new_cell)
            remove!(cm2, maincontainer)
            built = build(c, cm2, new_cell, proj)
            ToolipsSession.insert!(cm2, proj.id, pos, built)
            focus!(cm2, "cell$(cell.id)")
        end
    end
    ToolipsSession.bind(c, cm, inpbox, km)
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
    km::ToolipsSession.KeyMap = cell_bind!(c, cell, proj)
    interior::Component{:div} = builtcell[:children]["cellinterior$(cell.id)"]
    inp::Component{:div} = interior[:children]["cellinput$(cell.id)"]
    getstarted::Component{:div} = div("getstarted$(cell.id)", contenteditable = true)
    style!(getstarted, "padding" => 8px, "margin-top" => 0px, "overflow" => "visible")
    runl::Component{:div} = tmd("runl", """- use `shift` + `enter` to use this project""")
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
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function toml_block!(tm::OliveHighlighters.TextStyleModifier)
    OliveHighlighters.mark_toml!(tm)
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
    OliveHighlighters.mark_toml!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = true)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    style!(builtcell, "transition" => 1seconds)
    inp = interior[:children]["cellinput$(cell.id)"]
    inp[:children]["cellhighlight$(cell.id)"][:text] = string(tm)
    ToolipsSession.bind(c, cm, inp[:children]["cell$(cell.id)"], km)
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
    OliveHighlighters.clear!(tm)
    sideb[:children] = [sideb[:children][1:2] ..., collapsebutt]
    builtcell::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
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
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:tomlvalues},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    cell.source = replace(curr, "<br>" => "\n", "<div>" => "")
    tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["toml"]
    OliveHighlighters.set_text!(tm, cell.source)
    OliveHighlighters.mark_toml!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    OliveHighlighters.clear!(tm)
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
             olive_notify!(cm2, "not a recognized cell hotkey", color = "red")
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
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:helprepl},
    proj::Project{<:Any})
    built_cell::Component{:div} = build_base_replcell(c, cm, cell, proj, repl = "help>", sideboxc = "orange", 
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
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:helprepl},
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
        push!(docsection, h2("doclabel$pin", text = pin))
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
        pinhead = h3("pinhead$(cell.id)", text = "pins")
        pinsect::Vector{AbstractComponent} = Vector{AbstractComponent}([pinhead, pins ...])
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
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:shell},
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
function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:pkgrepl},
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
    tm = OliveHighlighters.TextStyleModifier(cell.source)
    OliveHighlighters.julia_block!(tm)
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = true)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    style!(interior[:children]["cellside$(cell.id)"],
    "background-color" => "lightgreen")
    inp[:children]["cellhighlight$(cell.id)"][:text] = string(tm)
    ToolipsSession.bind(c, cm, inp[:children]["cell$(cell.id)"], km)
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
            fcell = Cell("jl", fname, fullpath)
            new_cells = olive_read(fcell)
            inclproj = add_to_session(c, new_cells, cm, fname, 
            fullpath, type = "include")
            inclproj.data[:mod] = proj[:mod]
            cell.outputs = inclproj.id
            olive_notify!(cm, "file $fname included", color = "darkgreen")
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
    new_a = a(text = txt)
    style!(new_a, "color" => "#fffdd0")
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    OliveHighlighters.clear!(tm)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function string(cell::Cell{:include})
    if cell.source != ""
        return(*("include(\"$(cell.source)\")",
        "\n#==output[$(typeof(cell).parameters[1])]\n$(string(cell.outputs))\n==#\n#==|||==#\n"))::String
    end
    ""::String
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:module},
    proj::Project{<:Any})
    builtcell::Component{:div} = build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = false)
    km = cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    inp = interior[:children]["cellinput$(cell.id)"]
    if typeof(cell.outputs) == String && cell.outputs != ""
        name = replace(cell.outputs, "\n" => "", " " => "")
        cell.outputs = read_module_cells(cell.source)
        cell.source = name
        inp[:children]["cell$(cell.id)"][:text] = cell.source
        builtcell[:children]["cell$(cell.id)out"][:text] = cell.source
    else
        inp[:children]["cell$(cell.id)"][:text] = cell.source
        builtcell[:children]["cell$(cell.id)out"][:text] = cell.source
    end
    style!(inp[:children]["cell$(cell.id)"], "color" => "darkred")
    style!(interior[:children]["cellside$(cell.id)"],
    "background-color" => "red")
    ToolipsSession.bind(c, cm, inp[:children]["cell$(cell.id)"], km)
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
            Cell(string(outsplit[1]), string(src), string(outsplit[2]))
        end for (e, cellc) in enumerate(modsrc)]
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function make_module_cells(cells::Vector{Cell{<:Any}})
    join((begin
    """$(cell.source)\n#==\n$(typeof(cell).parameters[1])/$(cell.outputs)\n==#\n#--\n""" 
    end for cell in cells))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function string(cell::Cell{:module})
    if cell.source != ""
        return(*("module $(cell.source)\n", make_module_cells(cell.outputs), "\nend\n",
        "\n#==output[$(typeof(cell).parameters[1])]\n$(cell.source)\n==#\n#==|||==#\n"))::String
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
    if length(findall(proj -> proj.id == cell.source, projects)) > 0
        modname = cell.outputs[1]
        proj = projects[modname]
    elseif contains(cell.source, "module")
        new_cells = read_module_cells(cell.source)
    else
        new_cells = Vector{Cell}([Cell("code", "")])
    end
    modname = cm["cell$(cell.id)"]["text"]
    cell.source = modname
    projdict = Dict{Symbol, Any}(:cells => new_cells, :env => proj[:env])
    if haskey(proj.data, :path)
        :path => proj[:path]
    end
    inclproj = Project{:module}(modname, projdict)
    source_module!(c, inclproj)
    proj.data[:mod].evalin(Meta.parse("$modname = nothing"))
    Main.evalin(Meta.parse("$(proj.data[:modid]).$modname = $(inclproj.data[:modid])"))
    push!(c[:OliveCore].open[getname(c)].projects, inclproj)
    tab = build_tab(c, inclproj)
    open_project(c, cm, inclproj, tab)
    olive_notify!(cm, "module $modname added", color = "red")
    cell.outputs = inclproj[:cells]
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
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
            children = Vector{AbstractComponent}([build_comp(c, path, f) for f in readdir(path)])::Vector{AbstractComponent}
            set_children!(cm, "filebox", vcat(Vector{AbstractComponent}([build_returner(c, path)]), children))
        end
        return(maincomp)::Component{:div}
    end
    maincomp::Component{:div} = div("$dir")
    push!(maincomp, a("$dir-a", text = dir))
    maincomp::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
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
inputcell_style (generic function with 1 method)
==#
#==|||==#
