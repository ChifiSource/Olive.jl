module Olive
using Toolips
using ToolipsSession
using ToolipsMarkdown: tmd, @tmd_str
# using IpyJL
using Revise

include("Settings.jl")
include("Components.jl")
sampleusingcell = usingcell("myusingcell")
samplemdcell = mdcell("samplemdcell")
samplemd = tmd"""# This is an example
This is an example cell. It is made of markdown.
"""
"""
main(c::Connection) -> _
--------------------

"""
function main(c::Connection)
    current_settings = OliveSettings()
    olivebody = body("olivebody")
    style!(olivebody, "transition" => "1s")
    main = divider("olivemain", d = "0", cell = "1", s = "0", ex = "0")
    style!(main, "transition" => "margin-left .8s")
    push!(samplemdcell, samplemd)
    push!(main, topbar(c), sampleusingcell, samplemdcell)
    samplecell = inputcell("myinput")
    write!(c, current_settings)
    on_keydown(c, "Enter") do cm::ComponentModifier
        alert!(cm, "you pressed enter, yo!")
    end
    push!(olivebody, projectexplorer(), main)
    write!(c, olivebody)
end

fourofour = route("404") do c
    write!(c, p("404message", text = "404, not found!"))
end

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
