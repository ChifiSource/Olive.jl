mutable struct Project{name <: Any} <: Servable
    name::String
    dir::String
    open::Dict{String, Pair{Module, Vector{Cell}}}
    groups::Dict{String, String}
    function Project(name::String, dir::String)
        open::Dict{String, Pair{Module, Vector{Cell}}} = Dict{String, Pair{Module, Vector{Cell}}}()
        groups::Dict{String, String} = Dict("root" => "rw")
        new{Symbol(name)}(name, dir, open, groups)
    end
    Project{T}(name::String, dir::String) where {T <: Any} = begin
        open::Dict{String, Pair{Module, Vector{Cell}}} = Dict{String, Pair{Module, Vector{Cell}}}()
        groups::Dict{String, String} = Dict("root" => "rw")
        new{T}(name, dir, open, groups)
    end
end

function project_fromfiles(n::String, dir::String)
    cells::Vector{Cell} = directory_cells(dir)
    project::Project{:files} = Project{:files}(n, dir)
    fakemod::Module = Module()
    push!(project.open, "files" => fakemod => cells)
    project::Project{:files}
end

function build(c::AbstractConnection, p::Project{<:Any})
    modstr = """module $(p.name)
    function evalin(ex::Any)
            eval(ex)
    end
    end"""
    [begin n = eval(Meta.parse(modstr)) => n[2]  end for n in values(p.open)]
    push!(c[:OliveCore].open, string(getip(c)) => p)
    [build(c, cell) for cell in first(p.open)[2][2]]
end

function build(c::AbstractConnection, p::Project{:files})
    main = div("olive-main", cell = "1", ex = "0")
    overview = div("file$(p.name)", align = "center")
    style!(overview, "margin-top" => 5percent, "border-style" => "solid",
    "border-width" => 3px, "border-radius" => 10px, "width" => "20%")
    push!(overview, h("heading$(p.name)", 1, text = p.name))
    push!(c[:OliveCore].open, string(getip(c)) => p)
    [push!(overview, build(c, cell)) for cell in first(p.open)[2][2]]
    overview
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
    data::Dict{Symbol, Any}
    open::Vector{Pair{String, Project{<:Any}}}
    function OliveCore(mod::String)
        data = Dict{Symbol, Any}()
        data[:home] = homedir() * "/olive"
        data[:public] = homedir() * "/olive/public"
        data[:wd] = pwd()
        projopen = Vector{Pair{String, Project{<:Any}}}()
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
