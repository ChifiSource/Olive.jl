#===
Core.jl
---
- Extensions
- `save_settings`
- `onsave`
- Directory
- directory build functions
- Project
- `create_project`
- build functions for projects
- `Environment`
- `OliveCore`
- `source_module(::OliveCore)`
- load_extensions!(oc::OliveCore)
- `OliveLogger`
- `OliveDisplay`
===#
#==output[filemap]
==#
#==|||==#
"""
### OliveExtension{P <: Any}
The OliveExtension is a symbolic type that is used by the `build` function in
order to create extensions using an OliveModifier. This constructor should only
be called internally. Instead, simply use methods to define your extension.
##### example
```example
# this is your olive root file:
module olive
using Olive
import Olive: build

                            # vv the name of your extension ! vv
function build(om::OliveModifier, oe::OliveExtension{:myextension})
    alert!(om, "hello!")
end
```
------------------
##### constructors
OliveExtension{T <: Any}()
"""
mutable struct OliveExtension{P <: Any} end
#==output[code]
==#
#==|||==#
"""
### OliveModifier <: ToolipsSession.AbstractComponentModifier
- rootc**::Dict{String, AbstractComponent}**
- changes**::Vector{String}**
- data**::Dict{String, Any}**
The OliveModifier is used whenever an extension is loaded with a `build`
function.
##### example
```
# this is your olive root file:
module olive
using Olive
import Olive: build

                            # vv the name of your extension ! vv
function build(om::OliveModifier, oe::OliveExtension{:myextension})
    alert!(om, "hello!")
end
```
------------------
##### constructors
- OliveModifier(c::Connection, cm::ComponentModifier)
"""
mutable struct OliveModifier <: ToolipsSession.AbstractComponentModifier
    rootc::String
    changes::Vector{String}
    data::Dict{String, Any}
    function OliveModifier(c::Connection, cm::ComponentModifier)
        new(cm.rootc, cm.changes, c[:OliveCore].client_data[getname(c)])
    end
end
#==output[code]
==#
#==|||==#
getindex(om::OliveModifier, symb::Symbol) = om.data[symb]
setindex!(om::OliveModifier, o::Any, symb::Symbol) = setindex!(om.data, o, symb)
#==output[code]
==#
#==|||==#
"""
### Olive Core
```julia
load_extensions!(c::Connection, cm::ComponentModifier, olmod::Module) -> ::Nothing
```
------------------
Loads `Olive` extensions. This function is called when `Olive` loads the main session.
#### example
```example

```
"""
function load_extensions!(c::Connection, cm::ComponentModifier, olmod::Module)
    mod = OliveModifier(c, cm)
    Base.invokelatest(c[:OliveCore].olmod.build, c, mod,
    OliveExtension{:invoker}())
    signatures = [m.sig.parameters[4] for m in methods(olmod.build,
     [Any, Modifier, OliveExtension])]
    for sig in signatures
        if sig == OliveExtension{<:Any}
            continue
        end
        c[:OliveCore].olmod.build(c, mod, sig())
    end
end
"""
```julia
build(c::Connection, om::OliveModifier, oe::OliveExtension{<:Any}) -> ::Nothing
```
---
This is the base `Olive` extension function, used to create `load` extensions. These are 
    extensions which do something on `Olive's` startup. 
#### example
In order to extend `build`, write `import` build and write a new `Method`:
```example
import Olive: build
using Olive
using ToolipsSession: alert!

build(c::Connection, om::OliveModifier, oe::OliveExtension{:hello}) = begin
    olive_notify!(om, "hello !", color = "darkgreen")
end
```
The example below is pulled from `OliveDocBrowser`:
```example
import Olive: build
using Olive
using Olive.Toolips
using Olive.ToolipsSession

build(c::Connection, om::OliveModifier, oe::OliveExtension{:docbrowser}) = begin
    explorericon = topbar_icon("docico", "newspaper")
    on(c, explorericon, "click") do cm::ComponentModifier
        mods = [begin 
            if :mod in keys(p.data)
                p.data[:mod]
            else
                nothing
            end
        end for p in c[:OliveCore].open[getname(c)].projects]
        filter!(x::Any -> ~(isnothing(x)), mods)
        push!(mods, Olive, olive)
        cells = Vector{Cell}([Cell(e, "docmodule", "", mod) for (e, mod) in enumerate(mods)])
        home_direc = Directory(c[:OliveCore].data["home"])
        projdict::Dict{Symbol, Any} = Dict{Symbol, Any}(:cells => cells,
        :path => home_direc.uri, :env => home_direc.uri)
        myproj::Project{:doc} = Project{:doc}(home_direc.uri, projdict)
        push!(c[:OliveCore].open[getname(c)].projects, myproj)
        tab::Component{:div} = build_tab(c, "documentation")
        open_project(c, om, proj, tab)
    end
    insert!(om, "rightmenu", 1, explorericon)
end
```
"""
build(c::Connection, om::OliveModifier, oe::OliveExtension{<:Any}) = return
#==output[code]
==#
#==|||==#

function load_keybinds_settings(c::Connection, om::AbstractComponentModifier)
    # cell bindings
    if ~("keybindings" in keys(c[:OliveCore].client_data[getname(c)]))
        push!(c[:OliveCore].client_data[getname(c)],
        "keybindings" => Dict{String, Any}(
        "evaluate" => ["Enter", "shift"],
        "delete" => ["Delete", "ctrl", "shift"],
        "up" => ["ArrowUp", "ctrl", "shift"],
        "down" => ["ArrowDown", "ctrl", "shift"],
        "copy" => ["C", "ctrl", "shift"],
        "paste" => ["V", "ctrl", "shift"],
        "cut" => ["X", "ctrl", "shift"],
        "select" => ["F", "ctrl", "shift"],
        "new" => ["Enter", "ctrl", "shift"],
        "focusup" => ["ArrowUp", "shift"],
        "focusdown" => ["ArrowDown", "shift"],
        "save" => ["s", "ctrl"],
        "saveas" => ["S", "ctrl", "shift"],
        "open" => ["O", "ctrl"],
        "find" => ["F", "ctrl"], 
        "explorer" => ["E", "ctrl"]
        ))
    end
    keybind_drop = containersection(c, "keybindings", fillto = 90)
    keybind_section = keybind_drop[:children][2]
    shftlabel = a("shiftlabel", text = "  shift:    ")
    ctrllabel = a("ctrllabel", text = "  ctrl:   ")
    keybind_section[:children] = Vector{Servable}(vcat([h2("setkeyslbl", text = "keybindings")],
    [begin
        newkeymain = div("keybind$(keybinding[1])")
        head = h5("keylabel$(keybinding[1])",  text = "$(keybinding[1])")
        setinput = Components.keyinput("$(keybinding[1])inp", text = keybinding[2][1])
        style!(setinput, "background-color" => "blue", "width" => 5percent,
        "display" => "inline-block", "color" => "white")
        shift_checkbox = Components.checkbox("shiftk$(keybinding[1])",
        value = "shift" in keybinding[2])
        ctrl_checkbox = Components.checkbox("ctrlk$(keybinding[1])",
        value = "ctrl" in keybinding[2])
        confirm = button("keybind$(keybinding[1])confirm", text = "confirm")
        on(c, confirm, "click") do cm::ComponentModifier
            key_vec = Vector{String}()
            k = cm[setinput]["value"]
            if length(k) == 1
                k = uppercase(k)
            end
            push!(key_vec, k)
            if parse(Bool, cm[shift_checkbox]["value"])
                push!(key_vec, "shift")
            end
            if parse(Bool, cm[ctrl_checkbox]["value"])
                push!(key_vec, "ctrl")
            end
            c[:OliveCore].client_data[getname(c)]["keybindings"][keybinding[1]] = key_vec
            olive_notify!(cm, "binding $(keybinding[1]) saved")
        end
        push!(newkeymain, head, shftlabel, shift_checkbox,
        ctrllabel, ctrl_checkbox, setinput, br(), confirm)
        newkeymain
    end for keybinding in c[:OliveCore].client_data[getname(c)]["keybindings"]]))
    append!(om, "settingsmenu", keybind_drop)
    # creator keys
    if ~("creatorkeys" in keys(c[:OliveCore].client_data[getname(c)]))
        push!(c[:OliveCore].client_data[getname(c)],
        "creatorkeys" => Dict{String, String}("c" => "code", "v" => "markdown", 
        "/" => "helprepl", "]" => "pkgrepl", ";" => "shellrepl", "i" => "include", 
        "m" => "module"))
    end
    creatorkeys = c[:OliveCore].client_data[getname(c)]["creatorkeys"]
    creatorkeysdropd = containersection(c, "creatorkeys", text = "creator keys")
    creatorkeysmen = creatorkeysdropd[:children][2]
    regkeys = div("regkeyss")
    regkeys[:children] = [begin
        mainbox = div("creatorkey$(key[1])")
        delet = topbar_icon("$(key[1])delet", "close")
        style!(delet, "color" => "red", "font-size" => 15pt)
        keyname = a("kd", text = key[2])
        binding = a("kb", text = key[1])
        style!(binding, "background-color" => "#FFFDD0",
        "border-radius" => 2px, "padding" => 3px, "color" => "#454545")
        style!(keyname, "margin-left" => 2px, "margin-right" => 2px,
        "color" => "darkblue", "font-weight" => "bold")
        push!(mainbox, delet, keyname, binding)
        on(c, delet, "click") do cm::ComponentModifier
            delete!(creatorkeys, key)
            remove!(cm, mainbox)
        end
        mainbox::Component{:div}
    end for key in creatorkeys]
    push!(creatorkeysmen, h2("creatorkeys", text = "creator keys"), regkeys)
    setinput = Components.keyinput("creatorkeyinp", text = "c")
    style!(setinput, "background-color" => "blue", "width" => 5percent,
    "display" => "inline-block", "color" => "white")
    newsection = div("newcreator")
    push!(newsection, h3("news", text = "bind new"), setinput)
    signatures = [m.sig.parameters[4] for m in methods(c[:OliveCore].olmod.build,
    [Toolips.AbstractConnection, Toolips.Modifier, IPyCells.AbstractCell, Project{<:Any}])]
    opts = Vector{Toolips.AbstractComponent}()
    for sig in signatures
        if sig == Cell{:creator} || sig == Cell{<:Any} || sig == Cell{:versioninfo}
            continue
        end
        if length(sig.parameters) < 1
            continue
        end
        b = Components.option("creatorkey", text = string(sig.parameters[1]))
        push!(opts, b)
    end
    sigselector = Components.select("sigselector", opts, value = "code")
    style!(sigselector, "background-color" => "white", "margin-left" => 5px,
    "margin-right" => 5px)
    addbutton = button("addcreatekey", text = "add key")
    on(c, addbutton, "click") do cm::ComponentModifier
        sigsel = cm[sigselector]["value"]
        setkey = cm[setinput]["value"]
        creatorkeys[setkey] = sigsel
        olive_notify!(cm, "creator key updated")
    end
    push!(newsection, sigselector, addbutton)
    push!(creatorkeysmen, newsection)
    append!(om, "settingsmenu", creatorkeysdropd)
end

function load_style_settings(c::Connection, om::AbstractComponentModifier)
    if ~("highlighting" in keys(c[:OliveCore].client_data[getname(c)]))
        tm = OliveHighlighters.TextStyleModifier("")
        OliveHighlighters.highlight_julia!(tm)
        tomltm = OliveHighlighters.TextStyleModifier("")
        OliveHighlighters.toml_style!(tomltm)
        mdtm = OliveHighlighters.TextStyleModifier("")
        OliveHighlighters.markdown_style!(mdtm)
        dic = Dict{String, Dict{<:Any, <:Any}}()
        push!(c[:OliveCore].client_data[getname(c)], "highlighting" => dic)
        push!(dic, "julia" => Dict{String, String}(string(k) => string(v[1][2]) for (k, v) in tm.styles),
            "toml" => Dict{String, String}(string(k) => string(v[1][2]) for (k, v) in tomltm.styles),
            "markdown" => Dict{String, String}(string(k) => string(v[1][2]) for (k, v) in mdtm.styles))
    end
    mdtm = OliveHighlighters.TextStyleModifier("")
    OliveHighlighters.markdown_style!(mdtm)
    push!(c[:OliveCore].client_data[getname(c)]["highlighting"], 
    "markdown" => Dict{String, String}(string(k) => string(v[1][2]) for (k, v) in mdtm.styles))
    if ~("highlighters" in keys(c[:OliveCore].client_data[getname(c)]))
        highlighting = c[:OliveCore].client_data[getname(c)]["highlighting"]
        julia_highlighter = OliveHighlighters.TextStyleModifier("")
        toml_highlighter = OliveHighlighters.TextStyleModifier("")
        md_highlighter = OliveHighlighters.TextStyleModifier("")
        julia_highlighter.styles = Dict(begin
            Symbol(k[1]) => ["color" => k[2]]
        end for k in c[:OliveCore].client_data[getname(c)]["highlighting"]["julia"])
        toml_highlighter.styles = Dict(begin
            Symbol(k[1]) => ["color" => k[2]]
        end for k in c[:OliveCore].client_data[getname(c)]["highlighting"]["toml"])
        md_highlighter.styles = Dict(begin
            Symbol(k[1]) => ["color" => k[2]]
        end for k in c[:OliveCore].client_data[getname(c)]["highlighting"]["markdown"])
        push!(c[:OliveCore].client_data[getname(c)], 
        "highlighters" => Dict{String, OliveHighlighters.TextStyleModifier}(
            "julia" => julia_highlighter, "toml" => toml_highlighter, "markdown" => md_highlighter
        ))
    end
    dic = c[:OliveCore].client_data[getname(c)]["highlighting"]
    container = containersection(c, "highlighting", fillto = 80)
    sect = container[:children][2]
    highheader = h3("highlighthead", text = "fonts and highlighting")
    push!(sect, highheader)
    for colorset in keys(dic)
        colorsetbox = div("$colorset-settings")
        push!(colorsetbox, h4("$colorset-label", text = colorset))
        [begin 
            label = h5("colorlabel", text = color)
            vbox = Components.colorinput("$(color)$(colorset)", 
            value = "'$(dic[colorset][color])'")
            clrdiv = div("clrdiv$(color)$(colorset)")
            style!(clrdiv, "display" => "inline-block")
            push!(clrdiv, label, vbox)
            push!(colorsetbox, clrdiv)
        end for color in keys(dic[colorset])]
        push!(sect, colorsetbox)
    end
    updatebutton = button("highupdate", text = "apply")
    on(c, updatebutton, "click") do cm::ComponentModifier
        [begin
            hl = c[:OliveCore].client_data[getname(c)]["highlighters"][highlighter[1]]
            styles = Dict([k[1] => cm["$(k[1])$(highlighter[1])"]["value"] for k in dic[highlighter[1]]])
            hl.styles = Dict([Symbol(k[1]) => ["color" => k[2]] for k in styles])
            dic[highlighter[1]] = styles
        end for highlighter in dic]
        olive_notify!(cm, "Your syntax highlighters have been updated", color = "green")
    end
    push!(sect, Component{:sep}("highsep"), updatebutton)
    append!(om, "settingsmenu", container)
end

build(c::Connection, om::OliveModifier, oe::OliveExtension{:olivebase}) = begin
    load_keybinds_settings(c, om)
    load_style_settings(c, om)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
### Directory{S <: Any}
- uri::String
The directory type holds Directory information and file cells on startup. It
is built with the `Olive.build(c::Connection, dir::Directory)` method. This holds
cells and directories
##### example
```
```
------------------
##### constructors
- Directory(uri::String; dirtype::String = "olive")
"""
mutable struct Directory{S <: Any}
    uri::String
    function Directory(uri::String;
        dirtype::String = "olive")
        new{Symbol(dirtype)}(uri)
    end
end

getindex(p::Vector{Directory{<:Any}}, s::String) = begin
    pos = findfirst(dir::Directory{<:Any} -> dir.name == s, p)
    if isnothing(pos)
        throw(KeyError("project $s not found!"))
    end
    p[pos]
end
#==output[code]
==#
#==|||==#
#===
DIRECTORY BUILD FUNCTIONS
===#
"""

"""
function build(c::Connection, dir::Directory{<:Any})
    nsplit::Vector{SubString} = split(dir.uri, "/")
    dircell::Cell{:dir} = Cell{:dir}(string(nsplit[length(nsplit)]),
    string(join(nsplit[1:length(nsplit) - 1], "/")))
    builtcell::Component{:div} = build(c, dircell, dir)
    if "Project.toml" in readdir(dir.uri)
        toml_cats = TOML.parse(read(dir.uri * "/Project.toml",
        String))
        if "name" in keys(toml_cats)
            dirtext = toml_cats["name"]
        end
        if "type" in keys(toml_cats)
            
        end
    end
    builtname::String = builtcell.name
    rmbutton::Component{:span} = topbar_icon("$(dircell.id)rm", "delete")
    save::Component{:span} = topbar_icon("$(dircell.id)adddir", "save")
    on(c, rmbutton, "click") do cm::ComponentModifier
        path::String = dir.uri
        group::Group = get_group(c)
        direcs = c[:OliveCore].open[getname(c)].directories
        inalready = findfirst(d -> d.uri == path, direcs)
        in_group = findfirst(d -> d.uri == path, group.directories)
        if isnothing(inalready) && isnothing(in_group)
            remove!(cm, builtname)
        elseif ~(isnothing(in_group))
            deleteat!(group.directories, in_group)
            olive_notify!(cm, "removed $(dir.uri) from saved directories, remove again to remove from instance.")
            save_settings!(c, core = true)
        elseif ~(isnothing(inalready))
            deleteat!(direcs, inalready)
            remove!(cm, builtname)
            olive_notify!(cm, "$(dir.uri) removed from directories.", color = "darkblue")
        end
    end
    on(c, save, "click") do cm::ComponentModifier
        group::Group = get_group(c)
        in_group = findfirst(d -> d.uri == dir.uri, group.directories)
        if ~(isnothing(in_group))
            olive_notify!(cm, "directory already saved to user group")
            save_settings!(c, core = true)
            return
        end
        push!(group.directories, dir)
        olive_notify!(cm, "directory saved to usergroup", color = "darkblue")
        save_settings!(c, core = true)
    end
    style!(save, "color" => "white", "font-size" => 17pt)
    style!(rmbutton, "color" => "white", "font-size" => 17pt)
    insert!(builtcell[:children][1][:children], 1, save)
    insert!(builtcell[:children][1][:children], 1, rmbutton)
    builtcell::Component{:div}
end

function build(c::Connection, dir::Directory{:saved})
    srcbutton = topbar_icon("srchome", "play_arrow")
    style!(srcbutton, "color" => "white", "font-size" => 17pt)
    if "Project.toml" in readdir(dir.uri)
        toml_cats = TOML.parse(read(dir.uri * "/Project.toml",
        String))
        if "name" in keys(toml_cats)
            dirtext = toml_cats["name"]
        end
        if "type" in keys(toml_cats)
            
        end
    end
    nsplit = split(dir.uri, "/")
    dircell = Cell{:dir}(string(nsplit[length(nsplit)]),
    string(join(nsplit[1:length(nsplit) - 1], "/")))
    builtcell::Component{:div} = build(c, dircell, dir)
    rmbutton = topbar_icon("$(dircell.id)rm", "delete")
    dirs = c[:OliveCore].open[getname(c)].directories
    builtname::String = builtcell.name
    on(c, rmbutton, "click") do cm::ComponentModifier
        pos = findfirst(d -> d.uri == dir.uri, dirs)
        if ~(isnothing(pos))
            deleteat!(dirs, pos)
        end
        remove!(cm, builtname)
        dlist::Vector{String} = c[:OliveCore].client_data[getname(c)]["directories"]
        pos = findfirst(s -> s == dir.uri, dlist)
        if ~(isnothing(pos))
            deleteat!(dlist, pos)
        end
        save_settings!(c)
        olive_notify!(cm, "$(dir.uri) removed from directories.", color = "darkblue")
        Pkg.gc(); Base.GC.gc(true)
    end
    style!(rmbutton, "color" => "white", "font-size" => 17pt)
    insert!(builtcell[:children][1][:children], 1, rmbutton)
    style!(builtcell[:children][1], "background-color" => "#36013F")
    style!(builtcell[:children][2], "border-color" => "#36013F")
    builtcell::Component{:div}
end

function build(c::Connection, dir::Directory{:home})
    srcbutton = topbar_icon("srchome", "play_arrow")
    style!(srcbutton, "color" => "white", "font-size" => 17pt)
    on(c, srcbutton, "click") do cm::ComponentModifier
        home = c[:OliveCore].data["home"]
        try
            load_extensions!(c[:OliveCore])
            olive_notify!(cm, "olive module successfully sourced!", color = "green")
        catch e
            olive_notify!(cm,
            "failed to source olive module",
            color = "red")
            print(e)
        end
    end
    addbutton = topbar_icon("extensionadd", "add")
    style!(addbutton, "color" => "white", "font-size" => 17pt)
    on(c, addbutton, "click") do cm::ComponentModifier
        creatorcell = Cell{:creator}("")
        insert!(cm, "homebox", 2, build(c, creatorcell, dir))
    end
    nsplit = split(dir.uri, "/")
    dircell = Cell{:dir}(string(nsplit[length(nsplit)]),  string(join(nsplit[1:length(nsplit) - 1], "/")))
    filecell = build(c, dircell, dir)
    filecell.name = "homebox"
    maincell = filecell[:children][1]
    maincell[:children] = [maincell[:children][1], srcbutton, maincell[:children][3], addbutton]
    childbox = filecell[:children][2]
    style!(maincell, "background-color" => "#D90166")
    style!(childbox, "border-color" => "#D90166")
    filecell
end

function build(c::Connection, dir::Directory{:pwd})
    splits = split(dir.uri, "/")
    path, name = join(splits[1:length(splits) - 1], "/"), splits[length(splits)]
    dircell = Cell{:dir}(dir.uri, name)
    filecell = build(c, dircell, dir, bind = false)
    maincell = filecell[:children][1]
    childbox = filecell[:children][2]
    style!(maincell, "background-color" => "#64bf6a")
    addbutton = topbar_icon("createfile", "add")
    style!(addbutton, "color" => "white", "font-size" => 17pt)
    on(c, addbutton, "click") do cm::ComponentModifier
        path = cm["selector"]["text"]
        creatorcell = Cell{:creator}("new", "create")
        built = build(c, creatorcell, "jl") do cm::ComponentModifier
            fmat = cm["formatbox"]["value"]
            ext = OliveExtension{Symbol(fmat)}()
            finalname = cm["new_namebox"]["text"] * ".$fmat"
            path = cm["selector"]["text"]
            create_new(c, cm, ext, path, finalname)
        end
        insert!(cm, "pwdmain", 2, built)
    end
    maincell[:children] = [maincell[:children][3], addbutton]
    slctor = maincell[:children][1]
    style!(slctor, "font-size" => 11pt)
    filecell.name = "pwdmain"
    slctor.name = "selector"
    childbox.name = "pwdbox"
    style!(childbox, "border-left" => "10px solid", "border-color" => "#64bf6a")
    on(c, maincell, "click") do cm::ComponentModifier
        childs = Vector{Servable}([begin
            build(c, mcell, dir)
        end
        for mcell
             in directory_cells(dir.uri, pwd = true)])
        if cm[maincell]["ex"] == "0"
            style!(cm, childbox, "height" => "auto", "opacity" => 100percent, "pointer-events" => "auto")
            set_children!(cm, childbox, childs)
            cm[maincell] = "ex" => "1"
            return
        end
        style!(cm, childbox, "opacity" => 0percent, "height" => 0percent, "pointer-events" => "none")
        cm[maincell] = "ex" => "0"
    end
    filecell
end

#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
### Project{name <: Any}
- name::String
- dir::String
- directories::Vector{Directory{<:Any}}
- environment::String
- open::Dict{String, Dict{String, Any}}
The directory type holds Directory information and file cells on startup. It
is built with the `Olive.build(c::Connection, dir::Directory)` method. This holds
cells and directories.
##### example
```
```
------------------
##### constructors
- Project{T}(name::String, data::Dict{Symbol, Any} = Dict{Symbol, Any})
"""
mutable struct Project{name <: Any}
    name::String
    data::Dict{Symbol, Any}
    id::String
    Project{T}(name::String,
    data::Dict{Symbol, Any} = Dict{Symbol, Any}()) where {T <: Any} = begin
        uuid::String = replace(ToolipsSession.gen_ref(10),
        [string(dig) => "" for dig in digits(1234567890)] ...)
        new{T}(name, data, uuid)::Project{<:Any}
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
getindex(p::Project{<:Any}, symb::Symbol) = p.data[symb]
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function create_project(homedir::String = homedir(), olivedir::String = "olive")
    path::String = pwd()
    try
        cd(homedir)
        Pkg.generate(olivedir)
    catch
        throw("unable to access your applications directory.")
    end
    cd(path)
    open("$homedir/$olivedir/src/olive.jl", "w") do o
        write(o,
        """\"""
        ## welcome to olive!
        Welcome to the `0.0.92` **pre-release** of `olive`: the multiple dispatch notebook application for Julia. This file is where extensions
        are added.
        - [getting started with olive]()
        - [installing extensions]()
        - Please report any issues to [our issues page!](https://github.com/ChifiSource/Olive.jl/issues)
        
        Thank you for trying olive !
        \"""
        #==|""" * """||==#
        using Olive
        import Olive: build
        #==output[code]
        ==#""")
    end
    @info "olive files created! welcome to olive! "
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
getindex(p::Vector{Project{<:Any}}, s::String) = begin
    pos = findfirst(proj::Project{<:Any} -> proj.id == s, p)
    if isnothing(pos)
        throw(KeyError("project $s not found!"))
    end
    p[pos]
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
```julia
build(c::Connection, cm::ComponentModifier, p::Project{<:Any}) -> ::Component{:div}
```
The catchall/default `build` function for `Olive` projects. Extend this function to change 
the way a new `Project` type is built. By default, this makes a simple window with generated cells as 
children. The cells are similarly generated by calling `build`.
```julia
using Olive; Olive.start()

# (click your olive link to instantiate your environment)
import Olive: build

build(c::Connection, cm::ComponentModifier, p::Project{:newproject}) = begin
    div(p.id, children = [build(c, cm, p, cell) for cell in p[:cells]])
end

# you'll need to load the project type if it doesn't come from a file or extension:
push!(Olive.CORE.open[1].projects, Project{:newproject}(""))

# refresh the page!
```
Here are some other **important** functions to look at for a `Project`:
- `source_module!`
- `check!`
- `work_preview`
- `open_project`
- `close_project`
- `save_project`
- `save_project_as`
- `olive_save`
- `build_tab`
- `style_tab_closed!`
- `tab_controls`
- `switch_pane!`
- `step_evaluate`

Notably, all of the `Cell` functions are also dispatched to projects, so we can also 
use these methods to change what different projects do with different cell types.
"""
function build(c::AbstractConnection, cm::ComponentModifier, p::Project{<:Any})
    frstcells::Vector{Cell} = p[:cells]
    retvs = Vector{Servable}([begin
       c[:OliveCore].olmod.build(c, cm, cell, p)::Component{<:Any}
    end for cell in frstcells])
    div(p.id, children = retvs, class = "projectwindow")::Component{:div}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
mutable struct Environment{T <: Any}
    name::String
    directories::Vector{Directory}
    projects::Vector{Project}
    cells_selected::Dict{String, String}
    cell_clipboard::Vector{Pair{String, String}}
    pwd::String
    function Environment(T::String, name::String)
        nT::Symbol = Symbol(T)
        new{nT}(name, Vector{Directory}(), 
        Vector{Project}(), Dict{String, String}(), 
        Vector{Pair{String, String}}(), "")::Environment{nT}
    end
    Environment(name::String) = Environment("olive", name)::Environment{:olive}
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
getindex(e::Environment, proj::String) = e.projects[proj]::Project{<:Any}
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
getindex(e::Vector{Environment}, name::String) = begin
    pos = findfirst(env::Environment -> env.name == name, e)
    if isnothing(pos)
        throw(KeyError("Environment $name not found."))
    end
    e[pos]::Environment
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
mutable struct Group
    name::String
    cells::Vector{Symbol}
    directories::Vector{Directory}
    load_extensions::Vector{Symbol}
    function Group(name::String)
        new(name, Vector{Symbol}(), Vector{Directory}(), Vector{Symbol}())
    end
end

getindex(e::Vector{Group}, name::String) = begin
    pos = findfirst(env::Group -> env.name == name, e)
    if isnothing(pos)
        throw(KeyError("Group $name not found."))
    end
    e[pos]::Group
end

function get_group(c)
    group::String = c[:OliveCore].client_data[getname(c)]["group"]
    c[:OliveCore].data["groups"][group]
end

mutable struct OliveCore <: Toolips.AbstractExtension
    olmod::Module
    data::Dict{String, Any}
    names::Dict{String, String}
    client_data::Dict{String, Dict{String, Any}}
    open::Vector{Environment}
    pool::Vector{String}
    client_keys::Dict{String, String}
    function OliveCore(mod::String)
        data::Dict{Symbol, Any} = Dict{Symbol, Any}()
        m = eval(Meta.parse("module $mod build = nothing end"))
        m.build = build
        open::Vector{Environment} = Vector{Environment}()
        pool::Vector{String} = Vector{String}()
        client_data = Dict{String, Dict{String, Any}}()
        client_keys::Dict{String, String} = Dict{String, String}()
        new(m, data, Dict{String, String}(),
        client_data, open, pool, client_keys)::OliveCore
    end
end

function on_start(oc::OliveCore, data::Dict{Symbol, Any}, routes::Vector{<:AbstractRoute})
    push!(data, :OliveCore => oc)
end

#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
getname(c::Connection) = c[:OliveCore].names[get_ip(c)]::String
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function source_module!(oc::OliveCore)
    homemod = """baremodule olive
    using Olive
    end"""
    pmod = Meta.parse(homemod)
    olmod::Module = Main.evalin(pmod)
    oc.olmod = olmod
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function load_extensions!(oc::OliveCore)
    homedirec = oc.data["home"]
    olive_cells = IPyCells.read_jl("$homedirec/src/olive.jl")
    olive_cells = filter!(ocell -> typeof(ocell) == Cell{:code} && ocell.source != "\n" && ocell.source != "\n\n",
    olive_cells)
    modstr = "begin\n" * join(
        [cell.source for cell in olive_cells], "\n") * "\nend"
    olmod = oc.olmod
    olmod.evalin(Meta.parse(modstr))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
OliveLogger() = Toolips.Logger("🫒 olive> ", Crayon(foreground = :blue), Crayon(foreground = :magenta), 
    Crayon(foreground = :red), prefix_crayon = Crayon(foreground = :light_magenta, bold = true))
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#

"""
### Olive Core
```julia
save_settings!(c::Connection; core::Bool = false) -> ::Nothing
```
---
`save_settings!` saves `OliveCore` settings for the user's `Connection`. Providing `core` 
will also save `Olive` core settings, as well. Core settings are in 
`OliveCore.data` whereas client settings are in `OliveCore.client_data`. 
These correspond to the `olive` and `oliveusers` section in the `olive` home 
`Project.toml`
"""
function save_settings!(c::Connection; core::Bool = false)
    homedir::String = c[:OliveCore].data["home"]
    alltoml::String = read("$homedir/Project.toml", String)
    current_toml = TOML.parse(alltoml)
    name::String = getname(c)
    client_settings = deepcopy(c[:OliveCore].client_data[name])
    [onsave(client_settings, OliveExtension{m.sig.parameters[3].parameters[1]}()) for m in methods(onsave, [AbstractDict, OliveExtension{<:Any}])]
    current_toml["oliveusers"][name] = client_settings
    toml_datakeys = keys(current_toml["olive"])
    data_copy = nothing
    if core
        data_copy = deepcopy(c[:OliveCore].data)
        [begin
            onsave(c[:OliveCore], data_copy, OliveExtension{m.sig.parameters[4].parameters[1]}()) 
        end for m in methods(onsave, [OliveCore, AbstractDict, OliveExtension{<:Any}])]
        [begin
            if datakey[1] in toml_datakeys
                current_toml[datakey[1]] = datakey[2]
            else
                push!(current_toml, datakey[1] => datakey[2])
            end
        end for datakey in data_copy]
    end
    open("$homedir/Project.toml", "w") do io
        TOML.print(io, current_toml)
    end
    client_settings = nothing
    data_copy = nothing
    current_toml = nothing
    nothing::Nothing
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
```julia
onsave(cd::Dict{<:Any, <:Any}, oe::OliveExtension{:highlighter}) -> ::Nothing
```
---
Each `onsave` `Method` is called on client data before `save_settings!`, in the case of this `Method`, 
(:highlighter), this method removes the highlighter objects from the client data, which 
may not be saved in TOML. This is an example of where this might be applied -- this is how we 
can store data in memory for only a single session.
"""
function onsave(cd::Dict{<:Any, <:Any}, oe::OliveExtension{:highlighter})
    delete!(cd, "highlighters")
end

function onsave(core::OliveCore, copy::AbstractDict, oe::OliveExtension{:groups})
    @info keys(copy)
    copy["groups"] = Dict{String, Dict{String, Vector}}(begin
        cells::Vector{String} = [string(cell) for cell in group.cells]
        uris::Vector{String} = [string(cell.uri) for cell in group.directories]
        dirs::Vector{String} = [string(typeof(dir).parameters[1]) for dir in group.directories]
        load::Vector{String} = [string(ext) for ext in group.load_extensions]
        group.name => Dict("cells" => cells, "uris" => uris, "dirs" => dirs, "load" => load)
    end for group in copy["groups"])
end

mutable struct OliveDisplay <: AbstractDisplay
    io::IOBuffer
    OliveDisplay() = new(IOBuffer())::OliveDisplay
end

#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function display(d::OliveDisplay, m::MIME{:olive}, o::Any)
    T::Type = typeof(o)
    mymimes = [MIME"text/html", MIME"text/svg", MIME"image/png",
    MIME"image/jpeg", MIME"image/gif", MIME"text/markdown",
     MIME"text/plain"]
    correctm = nothing
    for m in mymimes
        try
            correctm = m
            display(d, correctm(), o)
            break
        catch
            continue
        end
    end
end

function display(d::OliveDisplay, m::MIME{:olive}, o::Number)
    write(d.io, string(o))
end

function display(d::OliveDisplay, m::MIME{:olive}, o::AbstractString)
    write(d.io, "\"$o\"")
end

function display(d::OliveDisplay, m::MIME{:olive}, o::AbstractDict)
    write(d.io, string(o))
end

function display(d::OliveDisplay, m::MIME{:olive}, o::AbstractVector)
    write(d.io, "Vector x$(length(o)):" * string(o[1:5]) * " ...")
end

#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function display(d::OliveDisplay, m::MIME"text/html", o::Any)
    show(d.io, m, o)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function display(d::OliveDisplay, err::Exception)
    write(d.io, string(err))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function display(d::OliveDisplay, m::MIME"image/png", o::Any)
    show_img(d, o, "png")
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function display(d::OliveDisplay, m::MIME"image/jpeg", o::Any)
    show_img(d, o, "jpeg")
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function display(d::OliveDisplay, m::MIME"image/gif", o::Any)
    show_img(d, o, "gif")
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function show_img(d::OliveDisplay, o::Any, ftype::String)
    show(d.io, MIME"text/html"(), base64img("$(ToolipsSession.gen_ref())", o,
    ftype))
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function display(d::OliveDisplay, m::MIME"text/plain", o::Any)
    show(d.io, m, o)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function display(d::OliveDisplay, m::MIME"text/markdown", o::Any)
    show(d.io, m, o)
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
display(d::OliveDisplay, o::Any) = display(d, MIME{:olive}(), o)
#==output[code]
inputcell_style (generic function with 1 method)
==#