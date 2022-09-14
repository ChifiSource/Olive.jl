mutable struct OliveCore <: ServerExtension
    name::String
    data::Dict{Symbol, Any}
    projects::Vector{Project{<:Any}}
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

mutable struct Project{name <: Any} <: Servable
    f::Function
    dir::String
    permissions::Vector{UserGroup{<:Any}}()
    Project(type::String, uri::String, group::UserGroup{<:Any}) = begin
        permissions::Vector{Pair{UserGroup, String}} = Vector{Pair{UserGroup{<:Any}, String}}()
        f(c::Connection) = begin

        end
        new{Symbol(type)}(f, dir, group, permissions)
    end
end

function is_project(proj::Project{<:Any})
    if contains(read(uri, String), "Toolips")
        new{}
    end
end

build(f::Function, m::Module) = build(f, string(m))::OliveCore

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
