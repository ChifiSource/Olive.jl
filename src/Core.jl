

# bar, file, style, cell, project
abstract type OliveExtension <: Toolips.Servable end

mutable struct OliveCore <: ServerExtension
    pages::Vector{AbstractRoute}
    type::Symbol
    sessions::Dict{String, Pair{Vector{Cell}, Pair{String, Module}}}
    extensions::Vector{OliveExtension}
    users::Dict{String, Vector{Servable}}
    function OliveCore()
        pages = [main, fourofour, explorer]
        sessions = Dict{String, Pair{Vector{Cell}, String}}()
        users = Dict{String, Vector{Servable}}()
        extensions = Vector{OliveExtension}()
        new(pages, :connection, sessions, extensions, users)
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

function evaluate(c::Connection, cell::Cell{:code}, cm::ComponentModifier)
    rawcode = unhighlight(cm["cell$(cell.n)"]["text"])
    execcode = replace(rawcode, "\n" => ";", "</br>" => ";",
    "\n" => ";", "\n        " => ";")
    cell.source = rawcode
    print(execcode)
    sinfo = c[:OliveCore].sessions[getip(c)]
    ret = ""
    i = IOBuffer()
    try
        ret = sinfo[2][2].evalin(Meta.parse(execcode))
    catch e
        throw(e)
        ret = e
    end
    if isnothing(ret)
        ret = String(i.data)
    end
    b = IOBuffer()
    highlight(b, MIME"text/html"(), rawcode, Highlights.Lexers.JuliaLexer)
    out = replace(String(b.data), "\n" => "", "        " => "\n        ",
    "end" => "\nend")
    set_text!(cm, "cell$(cell.n)", out)
    od = OliveDisplay()
    display( od,MIME"nothing"(), ret)
    set_text!(cm, "cell$(cell.n)out", String(od.io.data))
end

function evaluate(c::Connection, cell::Cell{:md}, cm::ComponentModifier)
    activemd = replace(cm["cell$(cell.n)"]["text"], "<div>" => "\n")
    newtmd = tmd("cell$(cell.n)tmd", activemd)
    set_children!(cm, "cell$(cell.n)", [newtmd])
    cm["cell$(cell.n)"] = "contenteditable" => "false"
end
