

# bar, file, style, cell, project
abstract type OliveExtension <: Toolips.Servable end

mutable struct OliveSession
    environment::String
    open::Dict{String, Pair{Module, Vector{Cell}}}
    function OliveSession()
        new("", Dict{String, Vector{Cell}}())
    end
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

function evaluate(c::Connection, cell::Cell{:code}, cm::ComponentModifier)
    rawcode = unhighlight(cm["cell$(cell.n)"]["text"])
    execcode = replace(rawcode, "\n" => ";", "</br>" => ";",
    "\n" => ";", "\n        " => ";")
    cell.source = rawcode
    key = cm["olive-token"]["text"]
    fname = cm["olivemain"]["fname"]
    print(execcode)
    sinfo = c[:OliveCore].sessions[key].open[fname]
    ret = ""
    i = IOBuffer()
    try
        #== if we sent `i` through this function, maybe we could observe output?
         for example, if someone adds a package; we could have the percentage
          of the package adding? We also need to start parsing the execcode
             and observing c's permissions.
         actually, with the implementation of the using cell, we will just
           check for using and always make the evaluation of that cell
             multi-threaded. ==#

        ret = sinfo[1].evalin(Meta.parse(execcode))
    catch e
        throw(e)
        ret = e
    end
    if isnothing(ret)
        # spawn load-bar observer?
        ret = "loading"
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
    cell.source = activemd
    newtmd = tmd("cell$(cell.n)tmd", activemd)
    set_children!(cm, "cell$(cell.n)", [newtmd])
    cm["cell$(cell.n)"] = "contenteditable" => "false"
end

function evaluate(c::Connection, cell::Cell{<:Any}, cm::ComponentModifier)

end

function evaluate(c::Connection, cell::Cell{:ipynb}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_ipynb(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function evaluate(c::Connection, cell::Cell{:jl}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_jl(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function load_session(c::Connection, cs::Vector{Cell{<:Any}},
    cm::ComponentModifier, fname::String, fpath::String)
    session = OliveSession()
    key = ToolipsSession.gen_ref()
    modstr = """module Examp
    function evalin(ex::Any)
            eval(ex)
    end
end"""

    mod = eval(Meta.parse(modstr))
    push!(session.open, fname => mod => cs)
    push!(c[:OliveCore].sessions, key => session)
    redirect!(cm, "/session?key=$key")
end
