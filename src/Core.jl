mutable struct OliveSession
    environment::String
    open::Dict{String, Pair{Module, Vector{Cell}}}
    function OliveSession()
        new("", Dict{String, Vector{Cell}}())
    end
end

OliveLogger() = Logger()
function OliveServer(oc::OliveCore)

end

mutable struct OliveCore <: ServerExtension
    pages::Vector{AbstractRoute}
    type::Symbol
    sessions::Dict{String, OliveSession}
    extensions::Vector{OliveExtension}
    function OliveCore()
        pages = [main, fourofour, explorer]
        sessions = Dict{String, OliveSession}()
        extensions = Vector{OliveExtension}()
        new(pages, :connection, sessions, extensions)
    end
end

mutable struct OliveDisplay <: AbstractDisplay
    io::IOBuffer
    OliveDisplay() = new(IOBuffer())::OliveDisplay
end

function display(d::OliveDisplay, m::MIME{<:Any}, o::Any)
    T::Type = typeof(o)
    mymimes = [MIME"text/html", MIME"text/svg", MIME"text/plain"]
    mmimes = [m.sig.parameters[3] for m in methods(show, [IO, Any, T])]
    correctm = nothing
    for m in mymimes
        if m in mmimes
            correctm = m
            break
        end
    end
    show(d.io, correctm(), o)
end

display(d::OliveDisplay, o::Any) = display(d, MIME{:nothing}(), o)
