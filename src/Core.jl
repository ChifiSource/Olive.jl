#== map (your welcome)
- extenssions (OliveExtension{}, OliveModifier, build)
- Directories
- Projects
- OliveCore
- OliveDisplay
==#
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
        new(cm.rootc, cm.changes, c[:OliveCore].client_data[getip(c)])
    end
end

getindex(om::OliveModifier, symb::Symbol) = om.data[symb]

setindex!(om::OliveModifier, o::Any, symb::Symbol) = setindex!(om.data, o, symb)

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
build(om::OliveModifier, oe::OliveExtension{<:Any}) = return

function build(om::OliveModifier, oe::OliveExtension{:settings})

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
build(c::Connection, dir::Directory{<:Any}, m::Module;
exp::Bool = false) = begin
    container = section(dir.uri, align = "left")
    if "Project.toml" in readdir(dir.uri)
        toml_cats = TOML.parse(read(dir.uri * "/Project.toml",
        String))
        if "name" in keys(toml_cats)
            projname = toml_cats["name"]
            envtop = h("headingenv$(dir.uri)", 2, text = projname)
            push!(container, envtop)
        end
    end
    dirtop = h("heading$(dir.uri)", 3, text = dir.uri)
    push!(container, dirtop)
    cells = [begin
        Base.invokelatest(m.build, c, cell, dir, explorer = exp)
    end for cell in dir.cells]
    becell = replace(dir.uri, "/" => "|")
    cellcontainer = section("$(becell)cells", sel = becell)
    cellcontainer[:children] = cells
    containercontrols = div("$(dir.uri)controls")
    newtxt = ToolipsDefaults.textdiv("newtxt$becell", text = "")
    newtxt["align"] = "left"
    style!(newtxt, "border-width" => 2px, "border-style" => "solid",
    "opacity" => 0percent, "transition" => "1s", "width" => 0percent)
    style!(containercontrols, "padding" => 0px, "overflow" => "visible")
    new_dirb = topbar_icon("newdirb", "create_new_folder")
    new_fb = topbar_icon("newfb", "article")
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
            style!(cm, newtxt, "width" => 80percent, "opacity" => 100percent)
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
    "overflow-y" => "scroll !important", "min-width" => 40percent,
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
    Base.invokelatest(c[:OliveCore].olmod.build, mod, OliveExtension{:invoker}())
    signatures = [m.sig.parameters[3] for m in methods(olmod.build, [Modifier, OliveExtension])]
    for sig in signatures
        if sig == OliveExtension{<:Any}
            continue
        end
        Base.invokelatest(c[:OliveCore].olmod.build, mod, sig())
    end
end

mutable struct OliveCore <: ServerExtension
    olmod::Module
    type::Vector{Symbol}
    data::Dict{String, Any}
    client_data::Dict{String, Dict{String, Any}}
    open::Dict{String, Project{<:Any}}
    f::Function
    function OliveCore(mod::String)
        data = Dict{Symbol, Any}()
        m = eval(Meta.parse("module olive end"))
        projopen = Dict{String, Project{<:Any}}()
        client_data = Dict{String, Dict{String, Any}}()
        f(c::Connection) = begin
            if ~(getip(c) in keys(client_data))
                push!(client_data, getip(c) => Dict{String, Any}("open" => ""))
            end
        end
        new(m, [:connection, :func], data, client_data, projopen, f)
    end
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
