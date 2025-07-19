#==
extensions.jl
---
This file contains extensions for `Olive`; Cells, projects, and file-types that are considered an 
    addition on top of the base notebook format -- which includes only `Cell{<:Any}` `Cell{:code}` 
    `Cell{:creator}` and `Cell{:markdown}`
==#

#==
include/module
==#

function build_tab(c::Connection, p::Project{:include}; hidden::Bool = false)
    fname = p.id
    tabbody = div("tab$(fname)")
    style!(tabbody, "border-bottom-right-radius" => 0px,
    "border-bottom-left-radius" => 0px, "display" => "inline-block",
    "border-width" => 2px, "border-color" => "#333333", "border-bottom" => 0px,
    "border-style" => "solid", "margin-bottom" => "0px", "cursor" => "pointer",
    "margin-left" => 0px, "transition" => 1seconds, "background-color" => "green")
    if(hidden)
        style!(tabbody, "background-color" => "gray")
    end
    tablabel = a("tablabel$(fname)", text = p.name)
    style!(tablabel, "font-weight" => "bold", "margin-right" => 5px,
    "font-size"  => 13pt, "color" => "white")
    push!(tabbody, tablabel)
    on(c, tabbody, "click") do cm::ComponentModifier
        projects = CORE.users[getname(c)].environment.projects
        inpane = findall(proj::Project{<:Any} -> proj[:pane] == p[:pane], projects)
        [begin
            if projects[e].id != p.id 
                style_tab_closed!(cm, projects[e])
            end
        end  for e in inpane]
        projbuild = build(c, cm, p)
        set_children!(cm, "pane_$(p[:pane])", [projbuild])
        style!(cm, tabbody, "background-color" => "green")
    end
    on(c, tabbody, "dblclick") do cm::ComponentModifier
        if ~("$(fname)close" in keys(cm.rootc))
            decollapse_button = topbar_icon("$(fname)dec", "arrow_left")
            on(c, decollapse_button, "click") do cm2::ComponentModifier
                remove!(cm2, "$(fname)close")
                remove!(cm2, "$(fname)add")
                remove!(cm2, "$(fname)run")
                remove!(cm2, "$(fname)switch")
                remove!(cm2, decollapse_button)
            end
            style!(decollapse_button, "font-size"  => 17pt, "color" => "blue")
            controls = tab_controls(c, p)
            insert!(controls, 1, decollapse_button)
            [append!(cm, tabbody, serv) for serv in controls]
        end
    end
    tabbody::Component{:div}
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:include},
    proj::Project{<:Any})
    cells = proj[:cells]
    projs = CORE.users[getname(c)].environment.projects
    if cell.source != ""
        cell.source = replace(cell.source, "include(\"" => "", "\")" => "")
    end
    tm = OliveHighlighters.Highlighter(cell.source)
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

function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:include}, 
    proj::Project{<:Any})
    path = cm["cell$(cell.id)"]["text"]
    env = CORE.users[getname(c)].environment
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
    projs = env.projects
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

function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:include},
    proj::Project{<:Any})
    txt = cm["cell$(cell.id)"]["text"]
    new_a = a(text = txt)
    style!(new_a, "color" => "#fffdd0")
    set_text!(cm, "cellhighlight$(cell.id)", string(new_a))
end

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
function build_tab(c::Connection, p::Project{:module}; hidden::Bool = false)
    fname = p.id
    tabbody = div("tab$(fname)")
    style!(tabbody, "border-bottom-right-radius" => 0px,
    "border-bottom-left-radius" => 0px, "display" => "inline-block",
    "border-width" => 2px, "border-color" => "#333333", "border-bottom" => 0px,
    "border-style" => "solid", "margin-bottom" => "0px", "cursor" => "pointer",
    "margin-left" => 0px, "transition" => 1seconds, "background-color" => "#FF6C5C")
    if(hidden)
        style!(tabbody, "background-color" => "gray")
    end
    tablabel = a("tablabel$(fname)", text = p.name)
    style!(tablabel, "font-weight" => "bold", "margin-right" => 5px,
    "font-size"  => 13pt, "color" => "white")
    push!(tabbody, tablabel)
    on(c, tabbody, "click") do cm::ComponentModifier
        projects = c[:OliveCore].users[getname(c)].environment.projects
        inpane = findall(proj::Project{<:Any} -> proj[:pane] == p[:pane], projects)
        [begin
            if projects[e].id != p.id 
                style_tab_closed!(cm, projects[e])
            end
        end  for e in inpane]
        projbuild = build(c, cm, p)
        set_children!(cm, "pane_$(p[:pane])", [projbuild])
        style!(cm, tabbody, "background-color" => "#FF6C5C")
    end
    on(c, tabbody, "dblclick") do cm::ComponentModifier
        if ~("$(fname)close" in keys(cm.rootc))
            decollapse_button = topbar_icon("$(fname)dec", "arrow_left")
            on(c, decollapse_button, "click") do cm2::ComponentModifier
                remove!(cm2, "$(fname)close")
                remove!(cm2, "$(fname)add")
                remove!(cm2, "$(fname)run")
                remove!(cm2, "$(fname)switch")
                remove!(cm2, decollapse_button)
            end
            style!(decollapse_button, "font-size"  => 17pt, "color" => "blue")
            controls = tab_controls(c, p)
            insert!(controls, 1, decollapse_button)
            [append!(cm, tabbody, serv) for serv in controls]
        end
    end
    tabbody::Component{:div}
end

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

function make_module_cells(cells::Vector{Cell{<:Any}})
    join((begin
    """$(cell.source)\n#==\n$(typeof(cell).parameters[1])/$(cell.outputs)\n==#\n#--\n""" 
    end for cell in cells))
end

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

function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:module}, 
    proj::Project{<:Any})
    projects = c[:OliveCore].users[getname(c)].environment.projects
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
    proj.data[:mod].eval(Meta.parse("$modname = nothing"))
    Main.evalin(Meta.parse("$(proj.data[:modid]).$modname = $(inclproj.data[:modid])"))
    push!(projects, inclproj)
    tab = build_tab(c, inclproj)
    open_project(c, cm, inclproj, tab)
    olive_notify!(cm, "module $modname added", color = "red")
    cell.outputs = inclproj[:cells]
end

function string(cell::Cell{:module})
    if cell.source != ""
        return(*("module $(cell.source)\n", make_module_cells(cell.outputs), "\nend\n",
        "\n#==output[$(typeof(cell).parameters[1])]\n$(cell.source)\n==#\n#==|||==#\n"))::String
    end
    ""::String
end
#==
TOML
==#

function build(c::Connection, cell::Cell{:toml},
    d::Directory)
    hiddencell = build_base_cell(c, cell, d)
    style!(hiddencell, "background-color" => "#000080")
    if cell.source == "Project.toml"
        activatebutton = topbar_icon("$(cell.id)act", "bolt")
        style!(activatebutton, "font-size" => 20pt, "color" => "white")
        on(c, activatebutton, "click") do cm::ComponentModifier
            n = getname(c)
            for proj in c[:OliveCore].users[n].environment.projects
                b = button("activate$(proj.id)", text = proj.name)
                on(c, b, "click") do cm2::ComponentModifier
                    modname = proj.id
                    Main.evalin(
                    Meta.parse(olive_module(modname, cell.outputs)))
                    proj.data[:mod] = getfield(Main, Symbol(modname))
                    olive_notify!(cm2, "environment $(cell.outputs) activated",
                    color = "blue")
                    for k in c[:OliveCore].users[n].environment.projects
                        remove!(cm2, "activate$(k.id)")
                    end
                end
                append!(cm, hiddencell, b)
            end
        end
        insert!(hiddencell[:children], 2, activatebutton)
    end
    hiddencell
end

toml_string(cell::Cell{<:Any}) = ""
toml_string(cell::Cell{:tomlvalues}) = cell.source * "\n"

function build(c::Connection, cm::ComponentModifier, cell::Cell{:tomlvalues},
    proj::Project{<:Any})
    tm = c[:OliveCore].users[getname(c)]["highlighters"]["toml"]
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
            "transform" => "scaleY(50%)",
            "overflow" => "hidden", "border-bottom-width" => 2px,
             "border-bottom-style" => "solid",
             "border-bottom-color" => "lightblue")
            set_text!(cm2, collapsebutt, "unfold_more")
            cm2[collapsebutt] = "col" => "true"
            return
        end
        style!(cm2, builtcell, "min-height" => 50px, "height" => "auto",
        "border-bottom-width" => 0px, "transform" => "scaleY(100%)")
        set_text!(cm2, collapsebutt, "unfold_less")
        cm2[collapsebutt] = "col" => "false"
    end
    style!(sideb, "background-color" => "lightblue")
    OliveHighlighters.clear!(tm)
    sideb[:children] = [sideb[:children][1:2] ..., collapsebutt]
    builtcell::Component{:div}
end

function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:tomlvalues},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"] * "\n"
    varname = "data"
    if length(curr) > 2
        if contains(curr[1:2], "[")
            st = findfirst("[", curr)[1] + 1:findfirst("]", curr)[1] - 1
            varname = replace(curr[st], "\"" => "")
        else
            curr = "[data]\n$curr"
        end
    end
    grabname = replace(varname, "." => "", "-" => "_", " " => "")
    curr = replace(curr, "\"" => "\\\"")
    evalstr = "begin using TOML\n$grabname = TOML.parse(\"\"\"$(curr)\"\"\")[\"$varname\"]\n end"
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
        cell.outputs = grabname
        set_text!(cm, "cell$(cell.id)out", grabname)
    end
end

function cell_highlight!(c::Connection, cm::ComponentModifier, cell::Cell{:tomlvalues},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    cell.source = replace(curr, "<br>" => "\n", "<div>" => "")
    tm = c[:OliveCore].users[getname(c)]["highlighters"]["toml"]
    tm.raw = cell.source
    OliveHighlighters.mark_toml!(tm)
    set_text!(cm, "cellhighlight$(cell.id)", string(tm))
    OliveHighlighters.clear!(tm)
end

#==
TXT
==#

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

#==
TODO/NOTE
==#
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

#==
REPL Cells
==# 
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

function evaluate(c::Connection, cm::ComponentModifier, cell::Cell{:shell},
    proj::Project{<:Any})
    curr = cm["cell$(cell.id)"]["text"]
    mod = proj[:mod]
    commands = split(curr, " ")
    cmd = Symbol(commands[1])
    aliased_command = cmd == :ls || cmd == :dir
    out::String = ""
    ret::Any = ""
    if ~aliased_command && ~(cmd in names(proj[:mod], all = true))
        set_text!(cm, "cell$(cell.id)out", "$(commands[1]) is not a recognized command.")
        set_text!(cm, "cell$(cell.id)", "")
        return
    elseif aliased_command
        if length(commands) == 1
            ret = mod.readdir()
        else
            ret = mod.readdir(commands[2])
        end
    else
        args = []
        if length(commands) > 1
            args = commands[2:end]
        end
        getfield(mod, cmd)(args ...)
    end
    active_display::OliveDisplay = OliveDisplay()
    outp = ""
    if typeof(ret) <: Exception
        display(active_display, ret, Base.StackTraces.stacktrace(st_trace))
        outp = replace(String(take!(active_display.io)), "\n" => "</br>")
    elseif ~(isnothing(ret))
        display(active_display, MIME"olive"(), ret)
        outp = outp * "</br>" * String(take!(active_display.io))
    elseif isnothing(ret)
        outp = standard_out
    end
    out = mod.STDO
    if cmd == :pwd || cmd == :cd
        out = mod.WD
    end
    set_text!(cm, "cell$(cell.id)out", outp * out)
    set_text!(cm, "cell$(cell.id)", "")
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:pkgrepl},
    proj::Project{<:Any})
    build_base_replcell(c, cm, cell, proj)
end

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
    remove!(cm, "load$(cell.id)")
    set_text!(cm, "$(cell.id)cmds", replace(cell.source, "\n" => "<br>"))
    style!(cm, "cell$(cell.id)out", "height" => "auto", "opacity" => 100percent)
end

function build(c::Connection, cell::Cell{:olivestyle},
    d::Directory)
    hiddencell = build_base_cell(c, cell, d, binding = false)
    on(c, hiddencell, "dblclick") do cm::ComponentModifier
        cs::Vector{Cell{<:Any}} = olive_read(cell)
        proj::Project{:olivestyle} = add_to_session(c, cs, cm, cell.source, cell.outputs, type = "olivestyle")
        proj.data[:export] = "olivestyle"
    end
    style!(hiddencell, "background-color" => "#F15A60")
    hiddencell
end