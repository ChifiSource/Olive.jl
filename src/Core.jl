mutable struct Project{name <: Any} <: Servable
    name::String
    dir::String
    mod::Module
    groups::Dict{String, String}
    Project(type::String, uri::String,
    permisssions::Dict{String, String} = Dict("host" => "we") = begin
        new{Symbol(type)}(type, dir, mod, permissions)
    end
end

function new_project(name::String, dir::String,
    groups::Dict{String, String} = Dict("host" => "we"))

end

function build(c::Connection, p::Project{<:Any}, cells::Vector{Cell{<:Any}})
    newcells::Vector{Servable} = [build(cell) for cell in cells]
    gr = group(c)
    if ~(canread(c, p))
        return
    end
    if can_evaluate(c, p)

    end
    if can_write(c, p)
        
    end
end

can_read(c::Connection, p::Project{<:Any}) = group(c) in values(p.group)
can_evaluate(c::Connection, p::Project{<:Any}) = contains("e", p.groups[group(c)])
can_write(c::Connection, p::Project{<:Any}) = contains("w", p.groups[group(c)])

mutable struct OliveCore <: ServerExtension
    name::String
    data::Dict{Symbol, Any}
    open::Vector{Pair{String, AbstractVector}}
    type::Symbol
    function OliveCore(mod::String)
        projects = UserGroup(projects)
        root = UserGroup(mod)
        data = Dict{Symbol, Any}()
        data[:home] = "~/.olive"
        data[:public] = "public/"
        data[:projects] = Vector{String}("julia")
        data[:wd] = pwd()
        data
        data[:macros] = Vector{String}(["#==olive"])
        new(mod, data, :connection)
    end
end

build(f::Function, s::String) = f(OliveCore(s))

is_cell(cell::Cell{<:Any}, s::String) = begin

end

function getindex(oc::OliveCore, s::String)

end

function setindex!(oc::OliveCore)

end

OliveLogger() = Logger(Dict(1 => Crayon(foreground = :magenta, bold = true))
        prefix = "olive ! >")

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
