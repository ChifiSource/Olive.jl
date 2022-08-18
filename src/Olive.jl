module Olive
using Toolips
using ToolipsSession
using ToolipsMarkdown: tmd, @tmd_str
using ToolipsDefaults

# using IpyJL
using Revise

include("Core.jl")
include("Components.jl")
include("Pages.jl")

"""
start(IP::String, PORT::Integer, extensions::Vector{Any}) -> ::Toolips.WebServer
--------------------
The start function comprises routes into a Vector{Route} and then constructs
    a ServerTemplate before starting and returning the WebServer.
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000,
    extensions::Vector = [Logger(), Session()])
    rs = routes(route("/", main), fourofour)
    server = ServerTemplate(IP, PORT, rs, extensions = extensions)
    server.start()
end

end # - module
