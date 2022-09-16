mutable struct Project{name <: Any} <: Servable
    name::String
    dir::String
    open::Dict{String, Pair{Module, Vector{Cell}}}
    groups::Dict{String, String}
    Project(name::String, dir::String;
    groups::Dict{String, String} = "root" => "rw") = begin
        open::Dict{String, Pair{Module, Vector{Cell}}} = Dict{String, Pair{Module, Vector{Cell}}}()
        new{Symbol(name)}(name, dir, open, groups)
    end
end

function build(c::AbstractConnection, p::Project{<:Any})
    modstr = """module $(p.name)
    Pkg.activate("$(p.dir)")
    function evalin(ex::Any)
            eval(ex)
    end
    end"""
    p.open = [begin eval(Meta.parse(modstr)) => n[2]  end for n in values(p.open)]::Vector{Pair{String, Module}}
    push!(c[:OliveCore].open[getip(c)], p)
    cells = [build(c, cell) for cell in first(p.open)[2]]
    pages = olive
end

function build(c::AbstractConnection, p::Project{:root}, pr::String)

end

function build(f::Function, c::Project{:home}, pr::String)

end

function build(c::Connection, p::Project{:files}, pr::String)
    mainoverview = section("projectoverview")
    nmhd = h(3, "projectname", text = p.name)
    subt = a("projectdir")
    cells = directory_cells(c, dir)
    if length(cells) > 0
        filecells = first(open)[1]
    else

    end
    write!(c, proj)
end

function build(c::AbstractConnection, p::Project{:explorer})

end

function write!(c::AbstractConnection, p::Project{<:Any})
    styles = olivesheet()
    write!(c, julia_style())
    write!(c, styles)
    main = div("olive-main", cell = "1", ex = "0")
    write!(c. main)
end

function new_project(name::String, dir::String,
    groups::Dict{String, String} = Dict("host" => "we"))
    pe = projectexplorer()
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
    type::Symbol
    name::String
    data::Dict{Symbol, Any}
    open::Vector{Pair{String, Project{<:Any}}}
    function OliveCore(mod::String)
        data = Dict{Symbol, Any}()
        data[:home] = "~/.olive"
        data[:public] = "projects"
        data[:wd] = pwd()
        projopen = Vector{Pair{String, Project{<:Any}}}()
        data[:macros] = Vector{String}(["#==olive"])
        new(:connection, mod, data, projopen)
    end
end

build(f::Function, s::String) = f(OliveCore(s))

is_cell(cell::Cell{<:Any}, s::String) = begin

end

function getindex(oc::OliveCore, s::String)

end

function setindex!(oc::OliveCore)

end

OliveLogger() = Logger(Dict{Any, Crayon}(
    1 => Crayon(foreground = :magenta, bold = true)),
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
