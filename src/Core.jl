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
build(c::Connection, dir::Directory{<:Any}) = begin
    container = div("$(dir.uri)", align = "left")
    dirtop = h("heading$(dir.uri)", 3, text = dir.uri)
    cells = Vector{Servable}()
    push!(cells, dirtop)
    for cell in dir.cells
        push!(cells, build(c, cell))
    end
    container[:children] = cells
    on(c, container, "focusenter") do cm::ComponentModifier
        cm["olivemain"] = "selected" => dir.uri
    end
    return(container)
end

mutable struct OliveExtension{P <: Any} end


mutable struct OliveModifier <: ToolipsSession.AbstractComponentModifier
    rootc::Dict{String, AbstractComponent}
    changes::Vector{String}
    data::Dict{Symbol, Any}
    function OliveModifier(c::Connection, cm::ComponentModifier)
        new(cm.rootc, Vector{String}(), c[:OliveCore].client_data[getip(c)])
    end
end

function build(om::OliveModifier, oe::OliveExtension{<:Any})
    @warn "The extension $(typeof(oe)) tried to load, but has no build function."
end

mutable struct Project{name <: Any} <: Servable
    user::String
    clipboard::String
    name::String
    dir::String
    environment::String
    open::Dict{String, Vector{Cell}}
    mod::Module
    groups::Dict{String, String}
    function Project(name::String, dir::String)
        open::Dict{String, Pair{Module, Vector{Cell}}} = Dict{String, Pair{Module, Vector{Cell}}}()
        groups::Dict{String, String} = Dict("root" => "rw")
        modstr = """module $(p.name)
        function evalin(ex::Any)
                eval(ex)
        end
        end"""
        mod::Module = eval(modstr)
        new{Symbol(name)}(name, dir, open, mod, groups)::Project{<:Any}
    end
    Project{T}(name::String, dir::String) where {T <: Any} = begin
        open::Dict{String, Pair{Module, Vector{Cell}}} = Dict{String, Pair{Module, Vector{Cell}}}()
        groups::Dict{String, String} = Dict("root" => "rw")
        modstr = """module $(p.name)
        function evalin(ex::Any)
                eval(ex)
        end
        end"""
        mod::Module = eval(modstr)
        new{T}(name, dir, open, mod, groups)::Project{<:Any}
    end
end

function build(c::AbstractConnection, p::Project{<:Any})
    push!(c[:OliveCore].open[getip(c)], p)
    frstcells::Vector{Cell} = first(p.open)[2]
    Vector{Servable}([build(c, cell) for cell in frstcells])::Vector{Servable}
end

can_read(c::Connection, p::Project{<:Any}) = group(c) in values(p.group)
can_evaluate(c::Connection, p::Project{<:Any}) = contains("e", p.groups[group(c)])
can_write(c::Connection, p::Project{<:Any}) = contains("w", p.groups[group(c)])

function load_extensions!(c::Connection, cm::ComponentModifier)
    signatures = [m.sig.parameters[3] for m in methods(build, [Modifier, OliveExtension])]
    mod = OliveModifier(c, cm)
    for sig in signatures
        if sig == OliveExtension{<:Any}
            continue
        end
        build(mod, sig())
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
    display(d.io, correctm(), o)
end

function display(d::OliveDisplay, m::MIME"text/html", o::Any)
    show(d.io, correctm(), o)
end

function display(d::OliveDisplay, m::MIME"image/png", o::Any)
    show(d.io, correctm(), o)
end

function display(d::OliveDisplay, m::MIME"image/png")

end

display(d::OliveDisplay, o::Any) = display(d, MIME{:olive}(), o)
