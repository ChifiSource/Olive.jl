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
import Toolips: AbstractRoute, AbstractConnection, AbstractComponent, Crayon, write!
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

"""
main(c::Connection) -> _
--------------------
This function is temporarily being used to test Olive.

"""
main = route("/session") do c::Connection
    # TODO Keymap bindings here
    write!(c, olivesheet())
    open = c[:OliveCore].open[getip(c)]
    ui_topbar::Component{:div} = topbar(c)
    ui_explorer::Component{:div} = projectexplorer()
    ui_tabs::Vector{Servable} = Vector{Servable}()
    [begin
        if typeof(project) == Project{:files}
            push!(ui_explorer, build(c, project))
        else
            push!(ui_tabs, div(project.name))
        end
    end for project in open]
    olivemain = olive_main()
    projopen = first(values(open))
    insert!(olivemain[:children], 1, ui_topbar)
    olivemain[:children] = build(c, projopen)
    write!(c, [ui_explorer, ui_topbar, olivemain])
end

explorer = route("/") do c::Connection
    loader_body = div("loaderbody", align = "center")
    style!(loader_body, "margin-top" => 10percent)
    write!(c, olivesheet())
    icon = olive_loadicon()
    bod = olive_body(c)
    on(c, bod, "load") do cm::ComponentModifier
        homeproj = Directory(c[:OliveCore].data[:home], "root" => "rw")
        publicproj = Directory(c[:OliveCore].data[:public],
        "public" => "rw")
        dirs = [homeproj, publicproj]
        main = olive_main("files")
        for dir in dirs
            push!(main[:children], build(c, dir))
        end
        script!(c, cm, "loadcallback") do cm
            style!(cm, icon, "opacity" => 0percent)
            set_children!(cm, bod, [olivesheet(), main])
        end
        load_extensions!(c, cm)
    end
    push!(loader_body, icon)
    push!(bod, loader_body)
    write!(c, bod)
 end

dev = route("/") do c::Connection
    explorer.page(c)
end

setup = route("/") do c::Connection

end

fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end

function create_project(homedir::String = homedir(), olivedir::String = ".olive")
        @info "welcome to olive! to use olive, you will need to setup a project directory."
        @info "we can put this at $homedir/$olivedir, is this okay with you?"
        print("y or n: ")
        response = readline()
        if response == "y"
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
            import Olive: build

            build(oc::OliveCore) = begin
                oc::OliveCore
            end

            end # module""")
        end
        @info "olive files created! welcome to olive! "
    end
end

"""
start(IP::String, PORT::Integer, extensions::Vector{Any}) -> ::Toolips.WebServer
--------------------
The start function comprises routes into a Vector{Route} and then constructs
    a ServerTemplate before starting and returning the WebServer.
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000;
    devmode::Bool = false)
    if devmode
        s = OliveDevServer(OliveCore("Dev"))
        s.start()
        s[:Logger].log("started new olive server in devmode.")
        return
    end
    startup_path::String = pwd()
    homedirec::String = homedir()
    olivedir::String = "olive"
    oc::OliveCore = OliveCore("olive")
    rs::Vector{AbstractRoute} = Vector{AbstractRoute}()
    if ~(isdir("$homedirec/$olivedir"))
        proj = create_project(homedirec, olivedir)
        Pkg.activate("$homedirec/$olivedir/.")
        rs = routes(setup, fourofour)
    else
        Pkg.activate("$homedirec/$olivedir")
        olmod = eval(Meta.parse(read("$homedirec/$olivedir/src/olive.jl", String)))
        Base.invokelatest(olmod.build, oc)
        rs = routes(fourofour, main, explorer)
    end
    server = ServerTemplate(IP, PORT, rs, extensions = [OliveLogger(),
    oc, Session(["/", "/session"])])
    server.start(); server::Toolips.ToolipsServer
end

OliveServer(oc::OliveCore) = WebServer(extensions = [oc, OliveLogger(),
Session(["/", "/session"])])

OliveDevServer(oc::OliveCore) = begin
    rs = routes(dev, fourofour, main)
    WebServer(extensions = [oc, OliveLogger(), Session(["/", "/session"])],
    routes = rs)
end

#== TODO Create creates a new server at the current directory, making Olive.jl
deployable!
==#
function create(name::String)
    Toolips.new_webapp(name)
    Pkg.add(url = "https://github.com/ChifiSource/Olive.jl")
    open("$name/src/$name.jl") do io
        write!(io, """
        module $name
        using Toolips
        using ToolipsSession
        using Olive
        import Olive: build

        build(oc::OliveCore) = begin
            oc::OliveCore
        end

        build(om::OliveModifier, oe::OliveExtension{:$name})

        end

        function start()

        end

        end # module
        """)
    end
end

export OliveCore, build
end # - module
