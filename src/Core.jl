"""
### OliveExtension{P <: Any}
The OliveExtension is a symbolic type that is used by the `build` function in
order to create extensions using an OliveModifier. This is used to alter
the OliveUI as it is loaded!
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
##### field info

------------------
##### constructors

"""
mutable struct OliveExtension{P <: Any} end


mutable struct OliveModifier <: ToolipsSession.AbstractComponentModifier
    rootc::Dict{String, AbstractComponent}
    changes::Vector{String}
    data::Dict{Symbol, Any}
    function OliveModifier(c::Connection, cm::ComponentModifier)
        new(cm.rootc, cm.changes, c[:OliveCore].client_data[getip(c)])
    end
end

getindex(om::OliveModifier, symb::Symbol) = om.data[symb]

setindex!(om::OliveModifier, o::Any, symb::Symbol) = setindex!(om.data, o, smb)

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
function build(om::OliveModifier, oe::OliveExtension{<:Any})

end

"""
### Directory{T <: Any}
- uri::String
- access::Dict{String, Vector{String}}
- cells::Vector{Cell}
The directory type holds Directory information and file cells on startup. It
is build with the `Olive.build(c::Connection, dir::Directory{<:Any})` method. `T`
represents the type of directory to render. By default, this is :olive, which
gives the directory name and creates a collapsable.
##### example
```
```
------------------
##### constructors
- Directory(uri::String, access::Pair{String, String} ...; type::Symbol = :olive)
"""
mutable struct Directory{T <: Any}
    uri::String
    access::Dict{String, String}
    cells::Vector{Cell}
    dirs::Vector{Directory}
    function Directory(uri::String, access::Pair{String, String} ...; type::Symbol = :olive)
        file_cells, dirs = directory_cells(uri, access ...)
        new{type}(uri, Dict(access ...), file_cells)
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
module MyDirectories
    import Olive: build
    build(c::Connection, dir::Directory{:mydir}) = begin

    end
    # we will replace the directories with ours
    build(om::OliveModifier, oe::OliveExtension{:loadmydir})
        set_children!()
    end
end

using  MyDirectories
```
"""
build(c::Connection, cm, dir::Directory{<:Any}, m::Module) = begin
    container = section("$(dir.uri)", align = "left")
    dirtop = h("heading$(dir.uri)", 3, text = dir.uri)
    cells = Vector{Servable}()
    push!(cells, dirtop)
    for cell in dir.cells
        push!(cells, Base.invokelatest(m.build, c, cm, cell))
    end
    container[:children] = cells
    on(c, container, "click") do cm::ComponentModifier
        cm["olivemain"] = "selected" => dir.uri
    end
    return(container)
end

mutable struct Project{name <: Any} <: Servable
    name::String
    dir::String
    environment::String
    open::Dict{String, Vector{Cell}}
    mod::Module
    groups::Dict{String, String}
    function Project(name::String, dir::String; environment::String = "")
        open::Dict{String, Pair{Module, Vector{Cell}}} = Dict{String, Pair{Module, Vector{Cell}}}()
        groups::Dict{String, String} = Dict("root" => "rw")
        modstr = """module $(name)
        using Pkg

        function evalin(ex::Any)
                Pkg.activate("$environment")
                eval(Meta.parse(ex))
        end
        end"""
        mod::Module = eval(Meta.parse(modstr))
        if environment == ""
            environment = dir
        end
        new{Symbol(name)}(name, dir, environment, open, mod, groups)::Project{<:Any}
    end
    Project{T}(name::String, dir::String; environment::String = dir) where {T <: Any} = begin
        open::Dict{String, Pair{Module, Vector{Cell}}} = Dict{String, Pair{Module, Vector{Cell}}}()
        groups::Dict{String, String} = Dict("root" => "rw")
        modstr = """module $(name)
        using Pkg

        function evalin(ex::Any)
                Pkg.activate("$environment")
                eval(Meta.parse(ex))
        end
        end"""
        mod::Module = eval(Meta.parse(modstr))
        if environment == ""
            environment = dir
        end
        new{T}(name, dir, environment, open, mod, groups)::Project{<:Any}
    end
end

function build(c::AbstractConnection, cm::ComponentModifier, p::Project{<:Any})
    m = eval(Meta.parse(read(c[:OliveCore].data[:home] * "/src/olive.jl", String)))
    push!(c[:OliveCore].open[getip(c)], p)
    frstcells::Vector{Cell} = first(p.open)[2]
    Vector{Servable}([Base.invokelatest(m.build, c, cm, cell) for cell in frstcells])::Vector{Servable}
end

can_read(c::Connection, p::Project{<:Any}) = group(c) in values(p.group)
can_evaluate(c::Connection, p::Project{<:Any}) = contains("e", p.groups[group(c)])
can_write(c::Connection, p::Project{<:Any}) = contains("w", p.groups[group(c)])

function load_extensions!(c::Connection, cm::ComponentModifier, olmod::Module)
    mod = OliveModifier(c, cm)
    Base.invokelatest(olmod.build, mod, OliveExtension{:invoker}())
    signatures = [m.sig.parameters[3] for m in methods(olmod.build, [Modifier, OliveExtension])]
    for sig in signatures
        if sig == OliveExtension{<:Any}
            continue
        end
        Base.invokelatest(olmod.build, mod, sig())
    end
end

mutable struct OliveCore <: ServerExtension
    type::Vector{Symbol}
    data::Dict{Symbol, Any}
    client_data::Dict{String, Dict{Symbol, Any}}
    open::Dict{String, Vector{Project{<:Any}}}
    f::Function
    function OliveCore(mod::String)
        data = Dict{Symbol, Any}()
        data[:home] = homedir() * "/olive"
        data[:public] = homedir() * "/olive/public"
        projopen = Dict{String, Vector{Project{<:Any}}}()
        client_data = Dict{String, Dict{Symbol, Any}}()
        f(c::Connection) = begin
            if ~(getip(c) in keys(client_data))
                push!(client_data, getip(c) => Dict{Symbol, Any}())
            end
        end
        new([:connection, :func], data, client_data, projopen, f)
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

function bind!(c::Connection, cm::ComponentModifier, comp::Component{<:Any},
    cell::Cell{<:Any})
    if ~(:keybindings in keys(c[:OliveCore].client_data[getip(c)]))
        c[:OliveCore].client_data[getip(c)][:keybindings] = Dict(
        :evaluate => ("Enter", :shift),
        :delete => ("Delete", :ctrl, :shift),
        :up => ("ArrowUp", :ctrl, :shift),
        :down => ("ArrowDown", :ctrl, :shift),
        :copy => ("C", :ctrl, :shift),
        :paste => ("V", :ctrl, :shift),
        :cut => ("X", :ctrl, :shift)
        )
    end
    keybindings = c[:OliveCore].client_data[getip(c)][:keybindings]
    bind!(c, cm, comp, keybindings[:evaluate] ...) do cm3::ComponentModifier
        evaluate(c, cell, cm3)
#       append!(cm3, "olivemain", build(c, cm2, Cell(100, "code", "")))
    end
end
