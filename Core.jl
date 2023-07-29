#==output[filemap]
==#
#==|||==#
"""
### OliveExtension{P <: Any}
The OliveExtension is a symbolic type that is used by the `build` function in
order to create extensions using an OliveModifier. This constructor should only
be called internally. Instead, simply use methods to define your extension.
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
OliveExtension{}
"""
mutable struct OliveExtension{P <: Any} end
#==output[code]
==#
#==|||==#
"""
### OliveModifier <: ToolipsSession.AbstractComponentModifier
- rootc**::Dict{String, AbstractComponent}**
- changes**::Vector{String}**
- data::Dict{String, Any}
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
- OliveExtension{}
"""
mutable struct OliveModifier <: ToolipsSession.AbstractComponentModifier
    rootc::Dict{String, AbstractComponent}
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
        Base.invokelatest(c[:OliveCore].olmod.build, c, mod, sig())
    end
end

"""
**Olive Core**
### build(c::Connection, om::OliveModifier, oe::OliveExtension{<:Any})
------------------
This is the base `build` function. These functions are ran whenever an extension
is loaded into your root project. This function is not meant to be called, but
extended and written
#### example
```

```
"""
build(c::Connection, om::OliveModifier, oe::OliveExtension{<:Any}) = return
#==output[code]
==#
#==|||==#
build(c::Connection, om::OliveModifier, oe::OliveExtension{:keybinds}) = begin
    # load default key-bindings (if non-existent)
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
        "new" => ["Enter", "ctrl", "shift"],
        "focusup" => ["ArrowUp", "shift"],
        "focusdown" => ["ArrowDown", "shift"],
        "save" => ["s", "ctrl"]
        ))
    end
    keybind_section = section("settings_keys")
    shftlabel = a("shiftlabel", text = "  shift:    ")
    ctrllabel = a("ctrllabel", text = "  ctrl:   ")
    keybind_section[:children] = Vector{Servable}(vcat([h("setkeyslbl", 2, text = "keybindings")],
    [begin
        newkeymain = div("keybind$(keybinding[1])")
        head = h("keylabel$(keybinding[1])",5,  text = "$(keybinding[1])")
        setinput = ToolipsDefaults.keyinput("$(keybinding[1])inp", text = keybinding[2][1])
        style!(setinput, "background-color" => "blue", "width" => 5percent,
        "display" => "inline-block", "color" => "white")
        shift_checkbox = ToolipsDefaults.checkbox("shiftk$(keybinding[1])",
        value = "shift" in keybinding[2])
        ctrl_checkbox = ToolipsDefaults.checkbox("ctrlk$(keybinding[1])",
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
    append!(om, "settingsmenu", keybind_section)
end

build(c::Connection, om::OliveModifier, oe::OliveExtension{:creatorkeys}) = begin
    if ~("creatorkeys" in keys(c[:OliveCore].client_data[getname(c)]))
        push!(c[:OliveCore].client_data[getname(c)],
        "creatorkeys" => Dict{String, String}("c" => "code", "v" => "markdown"))
    end
    if om.data["selected"] == "files"
        return
    end
    creatorkeys = c[:OliveCore].client_data[getname(c)]["creatorkeys"]
    creatorkeysmen = section("creatormenu")
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
    push!(creatorkeysmen, h("creatorkeys", 2, text = "creator keys"), regkeys)
    setinput = ToolipsDefaults.keyinput("creatorkeyinp", text = "c")
    style!(setinput, "background-color" => "blue", "width" => 5percent,
    "display" => "inline-block", "color" => "white")
    newsection = div("newcreator")
    push!(newsection, h("news", 4, text = "bind new"), setinput)
    signatures = [m.sig.parameters[4] for m in methods(c[:OliveCore].olmod.build,
    [Toolips.AbstractConnection, Toolips.Modifier, IPyCells.AbstractCell, Vector{Cell}, String])]
    opts = Vector{Servable}()
    for sig in signatures
        if sig == Cell{:creator} || sig == Cell{<:Any} || sig == Cell{:versioninfo}
            continue
        end
        if length(sig.parameters) < 1
            continue
        end
        b = ToolipsDefaults.option("creatorkey", text = string(sig.parameters[1]))
        push!(opts, b)
    end
    sigselector = ToolipsDefaults.dropdown("sigselector", opts, value = "code")
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
    append!(om, "settingsmenu", creatorkeysmen)
end

build(c::Connection, om::OliveModifier, oe::OliveExtension{:highlightstyler}) = begin
    if ~("highlighting" in keys(c[:OliveCore].client_data[getname(c)]))
        tm = ToolipsMarkdown.TextStyleModifier("")
        ToolipsMarkdown.highlight_julia!(tm)
        dic = Dict{String, Dict{<:Any, <:Any}}()
        push!(c[:OliveCore].client_data[getname(c)], "highlighting" => dic)
        push!(dic, "julia" => Dict{String, String}(
            [string(k) => string(v[1][2]) for (k, v) in tm.styles]))
    end
    dic = c[:OliveCore].client_data[getname(c)]["highlighting"]
    sect = section("highlight_settings")
    highheader = h("highlighthead", 3, text = "highlights")
    push!(sect, highheader)
    for colorset in keys(dic)
        [begin 
            label = h("colorlabel", 5, text = color)
            vbox = ToolipsDefaults.colorinput("$(color)$(colorset)", 
            value = "'$(dic[colorset][color])'")
            clrdiv = div("clrdiv$(color)$(colorset)")
            style!(clrdiv, "display" => "inline-block")
            push!(clrdiv, label, vbox)
            push!(sect, clrdiv)
        end for color in keys(dic[colorset])]
    end
    append!(om, "settingsmenu", sect)
end

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

function save_settings!(c::Connection; core::Bool = false)
    homedir = c[:OliveCore].data["home"]
    alltoml = read("$homedir/Project.toml", String)
    current_toml = TOML.parse(alltoml)
    name = getname(c)
    client_settings = c[:OliveCore].client_data[name]
    current_toml["oliveusers"][name] = client_settings
    datakeys = c[:OliveCore].data
    toml_datakeys = keys(current_toml["olive"])
    if core
        [begin
            if datakey[1] in toml_datakeys
                current_toml[datakey[1]] = datakey[2]
            else
                push!(current_toml, datakey[1] => datakey[2])
            end
        end for datakey in datakeys]
    end
    open("$homedir/Project.toml", "w") do io
        TOML.print(io, current_toml)
    end
end

"""
### Directory{S <: Any}
- dirtype::String
- uri::String
- access::Dict{String, Vector{String}}
- cells::Vector{Cell}
The directory type holds Directory information and file cells on startup. It
is built with the `Olive.build(c::Connection, dir::Directory)` method. This holds
cells and directories
##### example
```
```
------------------
##### constructors
- Directory(uri::String, access::Pair{String, String} ...; dirtype::String = "olive")
"""
mutable struct Directory{S <: Any}
    dirtype::String
    uri::String
    access::Dict{String, String}
    cells::Vector{Cell}
    function Directory(uri::String, access::Pair{String, String} ...;
        dirtype::String = "olive")
        file_cells = directory_cells(uri, access ...)
        new{Symbol(dirtype)}(dirtype, uri, Dict(access ...), file_cells)
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
"""
**Interface**
### build(c::Connection, dir::Directory{<:Any}, m::Module, exp::Bool = false) -> ::Component{:div}
------------------
The catchall/default `build` function. If you want to add a custom directory,
create an OliveaExtension and
#### example
```

```
"""
function build(c::Connection, dir::Directory{<:Any}, m::Module;
exp::Bool = false)
    becell = replace(dir.uri, "/" => "|")
    container = div(dir.uri, align = "left")
    style!(container, "overflow" => "hidden")
    containercontrols = div("$(dir.uri)controls", align = "center")
    dir_b = topbar_icon("dirb$(becell)", "expand_more")
    style!(dir_b, "color" => "white", "font-size" => 23pt, "display" => "flex", 
    "background-color" => "#8B4000", "font-weight" => "bold")
    push!(containercontrols, dir_b)
    if "Project.toml" in readdir(dir.uri)
        toml_cats = TOML.parse(read(dir.uri * "/Project.toml",
        String))
        if "name" in keys(toml_cats)
            projname = toml_cats["name"]
            envtop = a("headingenv$(dir.uri)", text = projname)
            style!(envtop, "padding" => 4px, "background-color" => "blue",
            "font-size" => 12pt, "font-weight" => "bold", "margin-top" => 0px,
            "border-radius" => 0px, "color" => "white", "display" => "flex")
            push!(containercontrols, envtop)
        end
        if "type" in keys(toml_cats)
            projtype = toml_cats["type"]
            projtop = a("typeenv$(dir.uri)", text = projtype)
            style!(projtop, "padding" => 4px, "background-color" => "darkgreen",
            "font-size" => 12pt, "border-radius" => 0px, "color" => "white", "margin-top" => 0px,
            "display" => "flex")
            push!(containercontrols, projtype)
        end
    end
    dirtext = split(replace(dir.uri, homedir() => "~",), "/")
    if length(dirtext) > 3
        dirtext = dirtext[length(dirtext) - 3:length(dirtext)]
    end
    dirtop = a("heading$(dir.uri)", text = join(dirtext, "/"))
    style!(dirtop, "color" => "white", "background-color" => "darkblue",
    "font-size" => 12pt, "border-radius" => 0px,
    "font-weight" => "bold", "padding" => 4px, "display" => "flex")
    push!(containercontrols, dirtop)
    cells = [begin
        Base.invokelatest(m.build, c, cell, dir, explorer = exp)
    end for cell in dir.cells]
    cellcontainer = section("$(becell)cells", ex = 0)
    style!(cellcontainer, "padding" => 10px, "background-color" => "transparent",
    "overflow" => "visible", "border-style" => "solid", "border-width" => 0px, "border-radius" => 0px,
    "border-color" => "darkblue", "border-bottom-width" => 1px, "border-top-width" => 1px,
    "transition" => 1seconds, "height" => 0percent, "opacity" => 0percent)
    cellcontainer[:children] = cells
    newtxt = ToolipsDefaults.textdiv("newtxt$becell", text = "")
    newtxt["align"] = "left"
    style!(newtxt, "border-width" => 0px,
    "opacity" => 0percent, "transition" => "1s", "width" => 0percent,
    "display" => "flex", "padding" => "0px", "outline" => "none",
    "background-color" => "white", "font-weight" => "bold", "color" => "darkblue",
    "border-style" => "solid", "border-width" => 2px)
    style!(containercontrols, "padding" => 0px, "overflow" => "visible",
    "display" => "flex", "margin-left" => 0px,
    "border-width" => 0px, "border-radius" => 0px,
    "border-bottom-left-radius" => "0px",
    "border-bottom-right-radius" => 0px, "background-color" => "white",
    "border-style" => "solid", "border-color" => "darkblue")
    new_dirb = topbar_icon("newdir$(becell)", "create_new_folder")
    collapse_b = topbar_icon("col$becell", "expand_more")
    new_fb = topbar_icon("newfb$(becell)", "article")
    style!(new_dirb, "color" => "white", "font-size" => 23pt, "display" => "flex", "background-color" => "blue")
    style!(collapse_b, "color" => "white", "font-size" => 23pt, "display" => "flex", "background-color" => "red",
    "transition" => 1seconds)
    style!(new_fb, "color" => "white", "font-size" => 23pt, "background-color" => "red")
    on(c, collapse_b, "click") do cm2::ComponentModifier
        if cm2[cellcontainer]["ex"] == "0"
            cm2[cellcontainer] = "ex" => 1
            style!(cm2, cellcontainer, "height" => 20percent, "opacity" => 100percent, 
            "overflow-y" => "scroll")
            style!(cm2, collapse_b, "transform" => "rotate(-90deg)")
            return
        end
        cm2[cellcontainer] = "ex" => 0
        style!(cm2, collapse_b, "transform" => "rotate(0deg)")
        style!(cm2, cellcontainer, "height" => 0percent, "opacity" => 0percent)        
    end
    if dir.uri == c[:OliveCore].data["home"]
        srcbutton = div("src$(becell)", text = "source")
        on(c, srcbutton, "click") do cm::ComponentModifier
            home = c[:OliveCore].data["home"]
            try
                source_module!(c[:OliveCore])
                olive_notify!(cm, "olive module successfully sourced!", color = "green")
            catch e
                olive_notify!(cm,
                "failed to source olive module",
                color = "red")
            end
        end
        style!(srcbutton, "background-color" => "red", "font-size" => 12pt, "padding" => 4px, "color" => "white",
        "font-weight" => "bold", "display" => "flex", "align" => "center", "cursor" => "pointer", "border-radius" => 0px)
        push!(containercontrols, srcbutton)
    end
    push!(containercontrols, new_dirb, new_fb, collapse_b)
    on(c, new_dirb, "click") do cm::ComponentModifier
        newconfbutton = button("fconfbutt$(becell)", text = "confirm")
        if ~(newconfbutton.name in keys(cm.rootc))
            cancelbutton = button("fcancbutt$(becell)", text = "cancel")
            on(c, cancelbutton, "click") do cm2::ComponentModifier
                remove!(cm2, newconfbutton)
                remove!(cm2, cancelbutton)
                set_text!(cm2, newtxt, "")
                style!(cm2, newtxt, "width" => 0percent, "opacity" => 0percent)
            end
            on(c, newconfbutton, "click") do cm2::ComponentModifier
                fname = cm2[newtxt]["text"]
                dirname = replace(cm2[cellcontainer]["sel"], "|" => "/")
                final_dir = dirname * "/" * fname
                mkdir(final_dir)
                newcells = directory_cells(dirname)
                #if typeof()
                remove!(cm2, newconfbutton)
                remove!(cm2, cancelbutton)
                set_text!(cm2, newtxt, "")
                style!(cm2, newtxt, "width" => 0percent, "opacity" => 0percent)
                olive_notify!(cm2, "directory $final_dir created!", color = "green")
                set_children!(cm2, "$(becell)cells",
                Vector{Servable}([build(c, cel, dir, explorer = exp) for cel in newcells]))
            end
            append!(cm, containercontrols, newconfbutton)
            append!(cm, containercontrols, cancelbutton)
            style!(cm, newtxt, "width" => 35percent, "opacity" => 100percent)
            style!(cm, newconfbutton, "opacity" => 100percent)
            focus!(cm, newtxt)
            return
        end
        olive_notify!(cm, "you already have a naming box open...", color = "red")
    end
    on(c, new_fb, "click") do cm::ComponentModifier
        newconfbutton = button("fconfbutt$(becell)", text = "confirm")
        if ~(newconfbutton.name in keys(cm.rootc))
            cancelbutton = button("fcancbutt$(becell)", text = "cancel")
            on(c, cancelbutton, "click") do cm2::ComponentModifier
                remove!(cm2, newconfbutton)
                remove!(cm2, cancelbutton)
                set_text!(cm2, newtxt, "")
                style!(cm2, newtxt, "width" => 0percent, "opacity" => 0percent)
            end
            on(c, newconfbutton, "click") do cm2::ComponentModifier
                fname = cm2[newtxt]["text"]
                dirname = replace(cm2[cellcontainer]["sel"], "|" => "/")
                final_dir = dirname * "/" * fname
                touch(final_dir)
                newcells = directory_cells(dirname)
                remove!(cm2, newconfbutton)
                remove!(cm2, cancelbutton)
                set_text!(cm2, newtxt, "")
                style!(cm2, newtxt, "width" => 0percent, "opacity" => 0percent)
                olive_notify!(cm2, "file $final_dir created!", color = "green")
                set_children!(cm2, "$(becell)cells",
                Vector{Servable}(
                [build(c, cel, dir, explorer = exp) for cel in newcells]))
            end
            append!(cm, containercontrols, newconfbutton)
            append!(cm, containercontrols, cancelbutton)
            style!(cm, newtxt, "width" => 20percent, "opacity" => 100percent)
            style!(cm, newconfbutton, "opacity" => 100percent)
            focus!(cm, newtxt)
            return
        end
        olive_notify!(cm, "you already have a naming box open...", color = "red")
    end
    style!(containercontrols[:children][length(containercontrols[:children])], 
    "border-top-left-radius" => 0px, "border-bottom-left-radius" => 0px, "border-radius" => 8px)
    push!(container, newtxt, containercontrols, cellcontainer)
    return(container)
end

"""
### Project{name <: Any}
- name::String
- dir::String
- directories::Vector{Directory{<:Any}}
- environment::String
- open::Dict{String, Dict{String, Any}}
The directory type holds Directory information and file cells on startup. It
is built with the `Olive.build(c::Connection, dir::Directory)` method. This holds
cells and directories
##### example
```
```
------------------
##### constructors
- Directory(uri::String, access::Pair{String, String} ...; dirtype::String = "olive")
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

getindex(p::Project{<:Any}, symb::Symbol) = p.data[symb]

getindex(p::Vector{Project{<:Any}}, s::String) = begin
    pos = findfirst(proj::Project{<:Any} -> proj.name == s, p)
    if isnothing(pos)
        throw(KeyError("project $s not found!"))
    end
    p[pos]
end

"""
**Interface**
```
build(c::Connection, cm::ComponentModifier, p::Project{<:Any};
at::String = first(p.open)[1]
```
------------------
The catchall/default `build` function. If you want to add a custom directory,
create an OliveaExtension and
#### example
```

```
"""
function build(c::AbstractConnection, cm::ComponentModifier, p::Project{<:Any})
    frstcells::Vector{Cell} = p[:cells]
    retvs = Vector{Servable}([begin
        Base.invokelatest(c[:OliveCore].olmod.build, c, cm, cell,
        frstcells, p)::Component{<:Any}
    end for cell in frstcells])
    proj_window::Component{:div} = div(p.id)
    proj_window[:children] = retvs
    style!(proj_window, "overflow-y" => "scroll", "overflow-x" => "hidden")
    proj_window::Component{:div}
end

mutable struct Environment
    name::String
    directories::Vector{Directory}
    projects::Vector{Project}
    function Environment(name::String)
        new(name, Vector{Directory}(),
        Vector{Project}())::Environment
    end
end

getindex(e::Environment, proj::String) = e.projects[proj]::Project{<:Any}

getindex(e::Vector{Environment}, name::String) = begin
    pos = findfirst(env::Environment -> env.name == name, e)
    if isnothing(pos)
        throw(KeyError("Environment for $name not found."))
    end
    e[pos]::Environment
end

mutable struct OliveCore <: ServerExtension
    olmod::Module
    type::Vector{Symbol}
    data::Dict{String, Any}
    names::Dict{String, String}
    client_data::Dict{String, Dict{String, Any}}
    open::Vector{Environment}
    client_keys::Dict{String, String}
    function OliveCore(mod::String)
        data = Dict{Symbol, Any}()
        m = eval(Meta.parse("module olive end"))
        open = Vector{Environment}()
        client_data = Dict{String, Dict{String, Any}}()
        client_keys::Dict{String, String} = Dict{String, String}()
        new(m, [:connection], data, Dict{String, String}(),
        client_data, open, client_keys)
    end
end

getname(c::Connection) = c[:OliveCore].names[getip(c)]::String

function source_module!(oc::OliveCore)
    homedirec = oc.data["home"]
    olive_cells = IPyCells.read_jl("$homedirec/src/olive.jl")
    filter!(ocell -> ocell.type == "code" || ocell.source != "\n" || cell.source != "\n\n",
    olive_cells)

    modstr = join(
        [cell.source for cell in olive_cells[2:length(olive_cells)]]
        )
    println(modstr)
    modend = findlast("end", modstr)
    modstr = modstr[1:modend[1] + 3]
    pmod = Meta.parse(modstr[1:length(modstr) - 1])
    olmod::Module = Main.evalin(pmod)
    Base.invokelatest(olmod.build, oc)
    oc.olmod = olmod
end

build(f::Function, oc::OliveCore) = f(oc)::OliveCore

is_cell(cell::Cell{<:Any}, s::String) = begin

end

function getindex(oc::OliveCore, s::String)

end

function setindex!(oc::OliveCore)

end

OliveLogger() = Logger(Dict{Any, Crayon}(
    1 => Crayon(foreground = :blue),
    2 => Crayon(foreground = :black),
    3 => Crayon(foreground = :red),
         :time_crayon => Crayon(foreground = :blue),
        :message_crayon => Crayon(foreground = :light_magenta, bold = true)), prefix = "🫒 olive> ")

mutable struct OliveDisplay <: AbstractDisplay
    io::IOBuffer
    OliveDisplay() = new(IOBuffer())::OliveDisplay
end

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

function display(d::OliveDisplay, m::MIME"text/html", o::Any)
    show(d.io, m, o)
end

function display(d::OliveDisplay, m::MIME"image/png", o::Any)
    show_img(d, o, "png")
end

function display(d::OliveDisplay, m::MIME"image/jpeg", o::Any)
    show_img(d, o, "jpeg")
end

function display(d::OliveDisplay, m::MIME"image/gif", o::Any)
    show_img(d, o, "gif")
end

function show_img(d::OliveDisplay, o::Any, ftype::String)
    show(d.io, MIME"text/html"(), base64img("$(ToolipsSession.gen_ref())", o,
    ftype))
end

function display(d::OliveDisplay, m::MIME"text/plain", o::Any)
    show(d.io, m, o)
end

function display(d::OliveDisplay, m::MIME"text/markdown", o::Any)
    show(d.io, m, o)
end

display(d::OliveDisplay, o::Any) = display(d, MIME{:olive}(), o)
