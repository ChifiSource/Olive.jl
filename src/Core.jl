

# bar, file, style, cell, project
abstract type OliveExtension <: Toolips.Servable end

mutable struct OliveCore <: ServerExtension
    pages::Vector{AbstractRoute}
    type::Symbol
    sessions::Dict{String, Pair{Vector{Cell}, Pair{String, Module}}}
    extensions::Vector{OliveExtension}
    users::Dict{String, Vector{Servable}}
    function OliveCore()
        pages = [main, fourofour]
        sessions = Dict{String, Pair{Vector{Cell}, String}}()
        users = Dict{String, Vector{Servable}}()
        extensions = Vector{OliveExtension}()
        new(pages, :connection, sessions, extensions, users)
    end
end
#==
function extension_load(ext::OliveExtension{:bar})

end

function extension_load(ext::OliveExtension{:file})

end

function extension_load(ext::OliveExtension{:style})

end

function extension_load(ext::OliveExtension{:project})

end

function extension_load(ext::OliveExtension{:settings})

end
==#
mutable struct OliveDisplay <: AbstractDisplay
    io::IO
end

function evaluate(c::Connection, cell::Cell{:md}, cm::ComponentModifier)
    activemd = replace(cm["cell$(cell.n)"]["text"], "<div>" => "\n")
    newtmd = tmd("cell$(cell.n)tmd", activemd)
    set_children!(cm, "cell$(cell.n)", [newtmd])
    cm["cell$(cell.n)"] = "contenteditable" => "false"
end

function evaluate(c::Connection, cell::Cell{:code}, cm::ComponentModifier)
    rawcode = replace(cm["cell$(cell.n)"]["text"],
    "<pre class=\"hljl\">" => "", "</pre>" => "", "</span>" => "",
    "<span class=\"hljl-k\">" => "", "<span class=\"hljl-p\">" => "",
    "<span class=\"hljl-t\">" => "", "<span class=\"hljl-cs\">" => "",
    "<span class=\"hljl-oB\">" => "", "<span class=\"hljl-nf\">" => "",
    "<span class=\"hljl-n\">" => "", "<span class=\"hljl-s\">" => "",
    "<span class=\"hljl-ni\">" => "", "<b>" => "", "</b>" => "",
    "<font color=\"#ff0000\">" => "", "</font>" => "", "<div>" => "\n",
    "</div>" => "")
    execcode = replace(rawcode, "\n" => ";", "</br>" => ";")
    cell.source = rawcode
    sinfo = c[:OliveCore].sessions[getip(c)]
    ret = ""
    try
        ret = sinfo[2][2].evalin(Meta.parse(execcode))
    catch e
        throw(e)
        ret = e
    end
    set_text!(cm, "cell$(cell.n)out", string(ret))
    b = IOBuffer()
    highlight(b, MIME"text/html"(), rawcode, Highlights.Lexers.JuliaLexer)
    out = rawcode = replace(String(b.data), "\n" => "</br>")
    set_text!(cm, "cell$(cell.n)", out)
end
