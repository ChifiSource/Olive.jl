module Olive
using Pkg
import Base: write, display
using Highlights
using Toolips
using ToolipsSession
using ToolipsMarkdown: tmd, @tmd_str
using ToolipsDefaults
import Toolips: AbstractRoute, AbstractConnection, AbstractComponent
using IPy
import IPy: Cell
using Crayons
using Revise


include("Core.jl")
include("Cells.jl")
include("UI.jl")
"""
start(IP::String, PORT::Integer, extensions::Vector{Any}) -> ::Toolips.WebServer
--------------------
The start function comprises routes into a Vector{Route} and then constructs
    a ServerTemplate before starting and returning the WebServer.
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000)
    startup_path::String = pwd()
    homedir::String = "~/"
    olivedir::String = ".olive"
    @static if Sys.isapple()
        olivehomedir = "/Applications"
        olivedir = "olive"
    elseif Sys.iswindows()
        olivehomedir = "%SystemDrive%/Program Files/olive"
        olivedir = "olive"
    end
    extensions::Vector{ServerExtension} = [Logger(),
    Session(["/", "/session"]), OliveCore()]
    if ~(isdir("$homedir/$olivedir"))
        try
            cd(homedir)
            Toolips.new_webapp(olivedir)
        catch
            throw("Unable to access your applications directory.")
        end
        open("$homedir/$olivedir/src/olive.jl", "w") do o
            write(o, """
module $olivedir
using Toolips
using ToolipsSession
using Olive

function build(group::UserGroup)
    myolive = OliveCore()
    load!(myolive)
    myolive::OliveCore
end

function start(ip::String, port::Int64)
    server = OliveServer(build())
end
end # module
                     """)
        end
        rs = routes(setup)
        server = ServerTemplate(IP, PORT, rs, extensions = extensions)
        return(st.start())::Toolips.WebServer
    end

    rs = routes(main, fourofour, explorer, viewer)
    server = ServerTemplate(IP, PORT, rs, extensions = extensions)
    server.start()::Toolips.WebServer
end

load!(olivecore::OliveCore, ext::OliveExtension{<:Any} ...) = [load!(olivecore,
ext) for ext in ext]


OliveServer() = ServerTemplate(ip, port, [setup],
extensions = [Logger(), Session(["/", "/session"]), OliveCore()])::ServerTemplate
OliveSetup(ip::String, port::Int64) = ServerTemplate(ip, port)

function create(name::String)
    Toolips.new_webapp(name)
    Pkg.add(url = "https://github.com/ChifiSource/Olive.jl")
end
end # - module
