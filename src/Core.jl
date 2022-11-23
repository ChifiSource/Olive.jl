
mutable struct Directory <: Servable
    uri::String
    access::Dict{String, Pair}
    function Directory()

    end
end

mutable struct OliveExtension{P <: Any}
    OliveExtension(f::Function, name::String) = new{name}(f, data)::OliveExtension{<:Any}
    OliveExtension
end

mutable struct OliveModifier <: AbstractComponentModifier
    changes::Vector{String}
    client_data::Dict{Symbol, Any}
    function OliveModifier(html::String)

    end
end

function build(om::ComponentModifier, oe::OliveExtension{<:Any})
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

function load_extensions!(cm::ComponentModifier)
    signatures = [m.sig.parameters[2] for m in methods(build, [Modifier, OliveExtension])]
    for sig in signatures
        build(cm, sig())
    end
end

mutable struct OliveCore <: ServerExtension
    type::Symbol
    directory::Vector{Directory}
    open::Dict{String, Vector{Project{<:Any}}}
    function OliveCore(mod::String)
        data = Dict{Symbol, Any}()
        data[:home] = homedir() * "/olive"
        data[:public] = homedir() * "/olive/public"
        projopen = Dict{String, Vector{Project{<:Any}}}()
        data[:macros] = Vector{String}(["#==olive"])
        new(:connection, data, projopen)
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
