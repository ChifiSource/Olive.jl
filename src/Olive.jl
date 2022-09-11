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
    if ~(isdir(homedir * olivedir))
        try
            cd(homedir)
            Toolips.new_webapp("Olive")
        catch
            throw("Unable to access your applications directory.")
        end
        nano("")
        rs = routes(setup)

    end
    extensions::Vector{ServerExtension} = [Logger(), Session(["/", "/session"]), OliveCore()]
    rs = routes(main, fourofour, explorer)
    server = ServerTemplate(IP, PORT, rs, extensions = extensions)
    server.start()
end

OliveServer() = ServerTemplate(ip, port, [setup],
extensions = [Logger(), Session(["/", "/session"]), OliveCore()])::ServerTemplate
OliveSetup(ip::String, port::Int64) = ServerTemplate(ip, port)

function create(name::String)
    Toolips.new_webapp(name)
    Pkg.add(url = "https://github.com/ChifiSource/Olive.jl")
end
end # - module
