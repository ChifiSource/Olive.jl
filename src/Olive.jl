"""
Created in February, 2022 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
by team
[toolips](https://github.com/orgs/ChifiSource/teams/toolips)
This software is MIT-licensed.
#### | olive | - | custom developer |
Welcome to olive! olive is an integrated development environment written in
julia and for other languages and data editing. Crucially, olive is abstract
    in definition and allows for the creation of unique types for names.
##### Module Composition
- [**Toolips**](https://github.com/ChifiSource/Toolips.jl)
"""
module Olive
import Base: write, display
using IPy
using IPy: Cell
using Highlights
using Pkg
using Toolips
import Toolips: AbstractRoute, AbstractConnection, AbstractComponent
using ToolipsSession
import ToolipsSession: Modifier
using ToolipsDefaults
using ToolipsMarkdown: tmd, @tmd_str
using ToolipsBase64
using Revise

#==olive filemap
An Olive.jl filemap for everyone to help develop this project easier! Thanks
for considering helping with the development of Olive.jl. If you care to join
the chifi organization, you may fill out a form [here]().
- [Olive.jl](./src/Olive.jl)
-- deps/includes
-- default routes
-- extension loader
-- Server Defaults
- [Core.jl](./src/Core.jl)
-- server extension
-- display
-- filetracker
- [UI.jl](./src/UI.jl)
-- styles
- [Extensions.jl](./src/Extensions.jl)
==#

include("Core.jl")
include("UI.jl")
include("Extensions.jl")

"""
main(c::Connection) -> _
--------------------
This function is temporarily being used to test Olive.

"""
main = route("/session") do c::Connection
    # styles
    styles = olivesheet()
    write!(c, julia_style())
    write!(c, styles)
    # args
    args = getargs(c)
    key = args[:key]
    session = c[:OliveCore].sessions[key]
    token = Component("olive-token", "token")
    style!(token, "display" => "none")
    token[:text] = key
    write!(c, token)

    # main
    olivebody = body("olivebody")

    fname = first(session.open)[1])

    push!(main, topbar(c))
    cont = div("testcontainer")
    on_keydown(c, "ArrowRight") do cm::ComponentModifier
        cellc = parse(Int64, cm[main]["cell"])
        activefile = cm["olivemain"]["fname"]
        println(c[:OliveCore].sessions)
        newcell = session.open[activefile][2][cellc]
        evaluate(c, newcell, cm)
    end
    current_file = first(session.open)
    println(current_file)
    cells::Vector{Servable} = [build(c, cell) for cell in current_file[2][2]]
    cont[:children] = cells
    push!(main, cont)
    push!(olivebody, pe, main)
    write!(c, olivebody)
end

#==output
Toolips.Route("/", #1)
==#

dev = route("/") do c::Connection
    # styles
    styles = olivesheet()
    write!(c, julia_style())
    write!(c, styles)

    # make dev project
    cells = Vector{Cell}(Cell(1, ))
    plabel =
    project = Project("olive", pwd(), )
    style!(main, "overflow-x" => "hidden")
    style!(main, "transition" => ".8s")
    cont = div("testcontainer", align = "center")
    cellcont::Vector{Servable} = [build(c, cell) for cell in cells]
    cont[:children] = cellcont
    push!(main, cont)
    push!(olivebody,  main)
    write!(c, olivebody)

end

explorer = route("/") do c::Connection
     styles = olivesheet()
     write!(c, julia_style())
     write!(c, styles)
     olivebody = body("olivebody")
     main = divider("olivemain", cell = "1", ex = "0")
     cells::Vector{Cell} = directory_cells(c)
     on_keydown(c, "ArrowRight") do cm::ComponentModifier
         cellc = parse(Int64, cm[main]["cell"])
         evaluate(c, cells[cellc], cm)
     end
     style!(main, "overflow-x" => "hidden")
     style!(main, "transition" => ".8s")
     cont = div("testcontainer", align = "center")
     testcell = Cell{:code}(length(cells) + 1)
     push!(cells, testcell)
     cellcont::Vector{Servable} = [build(c, cell) for cell in cells]
     cont[:children] = cellcont
     push!(main, cont)
     push!(olivebody,  main)
     write!(c, olivebody)
end
#==output
Toolips.Route("/", #1)
==#

setup = route("/") do c::Connection

end
#==output
Toolips.Route("/", #1)
==#

fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end

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
        @info "welcome to olive! we will generate your base project directory."
        try
            cd(homedir)
            Toolips.new_webapp(olivedir)
        catch
            throw("unable to access your applications directory.")
        end
        open("$homedir/$olivedir/src/olive.jl", "w") do o
            write(o, """
            module $olivedir
            using Toolips
            using ToolipsSession
            using Olive
            #==Olive try:
            using Olive: Extensions
            ==#
            \"\"\"
            ### build(group::UserGroup{<:Any}) -> ::OliveCore
            the `build` function serves to assemble any named type. Our `build`
            function can be changed
            "\"\"
            function build(m::Module, group::UserGroup{<:Any})
                myolive = OliveCore()
                OliveSetupServer(myolive)::WebServer
            end

            function start(ip::String, port::Int64)
                server = build()
                uri::String = ip * ":" * port
                link::String = authlink!(server)
                c[:Logger].log("server started | " * link)
            end
            end # module""")
        end
        @info "olive files created!"
    end

    rs = routes(main, fourofour, explorer, viewer)
    server = ServerTemplate(IP, PORT, rs, extensions = extensions)
    server.start()::Toolips.WebServer
end

OliveSetupServer(oc::OliveCore) = WebServer()

OliveServer(oc::OliveCore) = WebServer(extensions = [oc, OliveLogger()])

OliveDevServer(oc::OliveCore) = begin
    rs = routes(dev, fourofour, main)
    WebServer(extensions = [oc, OliveLogger(), Session(["/", "/session"])],
    routes = rs)
end

function start(;devmode::Bool)
    OliveDevServer(OliveCore("Dev")).start()
end

OliveSetupServer(oc::OliveCore) = ServerTemplate(ip, port, [setup],
extensions = [Logger(), Session(["/", "/session"]), oc])::ServerTemplate
OliveServer() =
OliveSetup(ip::String, port::Int64) = ServerTemplate(ip, port)

function create(name::String)
    Toolips.new_webapp(name)
    Pkg.add(url = "https://github.com/ChifiSource/Olive.jl")
end
end # - module
