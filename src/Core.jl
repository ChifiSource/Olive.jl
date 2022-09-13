mutable struct OliveCore <: ServerExtension
    name::String
    data::Dict{Symbol, Any}
    type::Symbol
    function OliveCore(mod::String)
        data = Dict{Symbol, Any}()
        data[:public] = "public/"
        data[:home] = "~/.olive"
        data[:wd] = pwd()
        data[:macros] = Vector{String}(["#==olive"])
        new(mod, data, :connection)
    end
end

build(f::Function, m::Module) = build(f, string(m))::OliveCore

build(f::Function, s::String) = f(OliveCore(s))

build(cell::Cell{<:Any}, s::String = "code") = begin

end

is_cell(cell::Cell{<:Any}, s::String) = begin

end

function getindex(oc::OliveCore, s::String)

end

function setindex!(oc::OliveCore)

end

OliveLogger() = Logger()

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
