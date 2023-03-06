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
    containercontrols = section("$(dir.uri)controls")
    style!(containercontrols, "padding" => 0px)
    new_dirb = button("newdirb", text = "new directory")
    new_fb = button("newfb", text = "new file")
    on(c, new_dirb, "click") do cm::ComponentModifier

    end
    on(c, new_fb, "click") do cm::ComponentModifier

    end
    push!(containercontrols, new_dirb, new_fb)
    cellcontainer = section("$(dir.uri)cells", sel = dir.uri)
    cellcontainer[:children] = cells
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
    proj_window = div(name, width = 500, height = 500)
    style!(proj_window, "display" => "inline-block",
    "overflow-y" => "scroll !important", "min-width" => 40percent)
    proj_window[:children] = retvs
    proj_window::Component{:div}
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
