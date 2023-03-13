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
OliveExtension{}
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
"""
**Olive Core**
### build(om::OliveModifier, oe::OliveExtension{<:Any})
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
        c[:OliveCore].client_data[getname(c)]["keybindings"] = Dict{Symbol, Any}(
        :evaluate => ("Enter", :shift),
        :delete => ("Delete", :ctrl, :shift),
        :up => ("ArrowUp", :ctrl, :shift),
        :down => ("ArrowDown", :ctrl, :shift),
        :copy => ("C", :ctrl, :shift),
        :paste => ("V", :ctrl, :shift),
        :cut => ("X", :ctrl, :shift),
        :new => ("Q", :ctrl, :shift)
        )
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
        shift_checkbox = ToolipsDefaults.checkbox("shiftk$(keybinding[1])")
        ctrl_checkbox = ToolipsDefaults.checkbox("ctrlk$(keybinding[1])")
        confirm = button("keybind$(keybinding[1])confirm", text = "confirm")
        on(c, confirm, "click") do cm::ComponentModifier
            key_vec = Vector{Union{String, Symbol}}()
            k = cm[setinput]["value"]
            if length(k) == 1
                k = uppercase(k)
            end
            push!(key_vec, k)
            if parse(Bool, cm[shift_checkbox]["value"])
                push!(key_vec, :shift)
            end
            if parse(Bool, cm[ctrl_checkbox]["value"])
                push!(key_vec, :ctrl)
            end
            c[:OliveCore].client_data[getname(c)]["keybindings"][keybinding[1]] = Tuple(key_vec)
            olive_notify!(cm, "binding $(keybinding[1]) saved")
        end
        push!(newkeymain, head, shftlabel, shift_checkbox,
        ctrllabel, ctrl_checkbox, setinput, br(), confirm)
        newkeymain
    end for keybinding in c[:OliveCore].client_data[getname(c)]["keybindings"]]))
    append!(om, "settingsmenu", keybind_section)
end
"""
### Directory
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
- Directory(uri::String, access::Pair{String, String} ...; type::Symbol = :olive)
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
#==output[code]
==#
#==|||==#
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
function build(c::Connection, dir::Directory{<:Any}, m::Module;
exp::Bool = false)
    container = section(dir.uri, align = "left")
    if "Project.toml" in readdir(dir.uri)
        toml_cats = TOML.parse(read(dir.uri * "/Project.toml",
        String))
        if "name" in keys(toml_cats)
            projname = toml_cats["name"]
            envtop = h("headingenv$(dir.uri)", 2, text = projname)
            push!(container, envtop)
        end
        if "type" in keys(toml_cats)
            projtype = toml_cats["type"]
            push!(container, h("typeenv$(dir.uri)", 4, text = projtype))
        end
    end
    dirtop = h("heading$(dir.uri)", 3, text = dir.uri)
    push!(container, dirtop)
    cells = [begin
        Base.invokelatest(m.build, c, cell, dir, explorer = exp)
    end for cell in dir.cells]
    becell = replace(dir.uri, "/" => "|")
    cellcontainer = section("$(becell)cells", sel = becell)
    style!(cellcontainer, "padding" => 7px)
    cellcontainer[:children] = cells
    containercontrols = div("$(dir.uri)controls")
    newtxt = ToolipsDefaults.textdiv("newtxt$becell", text = "")
    newtxt["align"] = "left"
    style!(newtxt, "border-width" => 2px, "border-style" => "solid",
    "opacity" => 0percent, "transition" => "1s", "width" => 0percent,
    "display" => "inline-block")
    style!(containercontrols, "padding" => 0px, "overflow" => "visible")
    new_dirb = topbar_icon("newdir$(becell)", "create_new_folder")
    new_fb = topbar_icon("newfb$(becell)", "article")
    if dir.uri == c[:OliveCore].data["home"]
        style!(cellcontainer, "border-color" => "pink")
        srcbutton = button("src$(becell)", text = "source")
        on(c, srcbutton, "click") do cm::ComponentModifier
            home = c[:OliveCore].data["home"]
            try
                olive_cells = IPyCells.read_jl("$home/src/olive.jl")
                source_module!(c[:OliveCore])
                olive_notify!(cm, "olive module successfully sourced!", color = "green")
            catch e
                olive_notify!(cm,
                "failed to source olive module",
                color = "red")
            end
        end
        headerimg = olive_cover()
        headerimg["width"] = "100"
        oliveheaderbox = div("homeheaderbx", align = "center")
        style!(oliveheaderbox, "overflow" => "hidden")
        push!(oliveheaderbox, headerimg)
        push!(container, oliveheaderbox)
        style!(srcbutton, "background-color" => "red")
        push!(containercontrols, srcbutton)
    end
    push!(containercontrols, new_dirb, new_fb, newtxt)
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
            style!(cm, newtxt, "width" => 40percent, "opacity" => 100percent)
            style!(cm, newconfbutton, "opacity" => 100percent)
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
            style!(cm, newtxt, "width" => 80percent, "opacity" => 100percent)
            style!(cm, newconfbutton, "opacity" => 100percent)
            return
        end
        olive_notify!(cm, "you already have a naming box open...", color = "red")
    end
    push!(container, containercontrols, cellcontainer)
    return(container)
end


mutable struct Project{name <: Any} <: Servable
    name::String
    dir::String
    directories::Vector{Directory{<:Any}}
    environment::String
    open::Dict{String, Dict{Symbol, Any}}
    function Project(name::String, dir::String; environment::String = dir)
        open::Dict{String, Dict{String, Any}} = Dict{String, Dict{String, Any}}()
        new{Symbol(name)}(name, dir, Vector{Directory{<:Any}}(),
         environment, open)::Project{<:Any}
    end
    Project{T}(name::String, dir::String; environment::String = dir) where {T <: Any} = begin
        open::Dict{String, Dict{String, Any}} = Dict{String, Dict{String, Any}}()
        groups::Dict{String, String} = Dict("root" => "rw")
        new{T}(name, dir, Vector{Directory{<:Any}}(), environment, open)::Project{<:Any}
    end
end

function build(c::AbstractConnection, cm::ComponentModifier, p::Project{<:Any};
    at::String = first(p.open)[1])
    name = at
    frstcells::Vector{Cell} = p.open[at][:cells]
    retvs = Vector{Servable}()
    [begin
        push!(retvs, Base.invokelatest(c[:OliveCore].olmod.build, c, cm, cell,
        frstcells, name))
    end for cell in frstcells]
    overwindow = div("$(name)over")
    style!(overwindow, "display" => "inline-block",
    "overflow-y" => "scroll !important", "min-width" => 70percent,
    "padding" => 0px, "max-height" => 20percent, "margin-top" => 2px)
    proj_window = section(name)
    proj_window[:children] = retvs
    push!(overwindow, build_tab(c, name), proj_window)
    overwindow::Component{:div}
end

function group(c::Connection)

end

can_read(c::Connection, d::Directory{<:Any}) = contains("r", d.access[group(c)])
can_evaluate(c::Connection, p::Project{<:Any}) = contains("e", d.access[group(c)])
can_write(c::Connection, p::Project{<:Any}) = contains("w", d.access[group(c)])

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

mutable struct OliveCore <: ServerExtension
    olmod::Module
    type::Vector{Symbol}
    data::Dict{String, Any}
    names::Dict{String, String}
    client_data::Dict{String, Dict{String, Any}}
    open::Dict{String, Project{<:Any}}
    client_keys::Dict{String, String}
    function OliveCore(mod::String)
        data = Dict{Symbol, Any}()
        m = eval(Meta.parse("module olive end"))
        projopen = Dict{String, Project{<:Any}}()
        client_data = Dict{String, Dict{String, Any}}()
        client_keys::Dict{String, String} = Dict{String, String}()
        new(m, [:connection], data, Dict{String, String}(),
        client_data, projopen, client_keys)
    end
end

getname(c::Connection) = c[:OliveCore].names[getip(c)]::String

function source_module!(oc::OliveCore)
    homedirec = oc.data["home"]
    olive_cells = IPyCells.read_jl("$homedirec/src/olive.jl")
    filter!(ocell -> ocell.type == "code" || ocell.source != "\n" || cell.source != "\n\n",
    olive_cells)
    modstr = join([cell.source for cell in olive_cells[2:length(olive_cells)]])
    modend = findlast("end # module", modstr)
    modstr = modstr[1:modend[1] + 3]
    pmod = Meta.parse(modstr[1:length(modstr) - 1])
    olmod::Module = eval(pmod)
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
         :time_crayon => Crayon(foreground = :blue),
        :message_crayon => Crayon(foreground = :light_magenta, bold = true)), prefix = "🫒 olive> ")

mutable struct OliveDisplay <: AbstractDisplay
    io::IOBuffer
    OliveDisplay() = new(IOBuffer())::OliveDisplay
end

function display(d::OliveDisplay, m::MIME{:olive}, o::Any)
    T::Type = typeof(o)
    mymimes = [MIME"text/html", MIME"text/svg", MIME"image/png",
     MIME"text/plain"]
    mmimes = [m.sig.parameters[3] for m in methods(show, [IO, Any, T])]
    correctm = nothing
    for m in mymimes
        if m in mmimes
            correctm = m
            break
        end
    end
    display(d, correctm(), o)
end

function display(d::OliveDisplay, m::MIME"text/html", o::Any)
    show(d.io, m, o)
end

function display(d::OliveDisplay, m::MIME"image/png", o::Any)
    show(d.io, m, o)
end

function display(d::OliveDisplay, m::MIME"text/plain", o::Any)
    show(d.io, m, o)
end

display(d::OliveDisplay, o::Any) = display(d, MIME{:olive}(), o)
