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
#==output[code]
==#
#==|||==#
import Base: write, display, getindex, setindex!
using IPyCells
using IPyCells: Cell
using Pkg
using Toolips
import Toolips: AbstractRoute, AbstractConnection, AbstractComponent, Crayon, write!, Modifier
using ToolipsSession
import ToolipsSession: bind!, AbstractComponentModifier
using ToolipsDefaults
using ToolipsMarkdown
using ToolipsBase64
using Highlights
using TOML
using Revise
#==output[code]
==#
#==|||==#

#==
- Olive.jl./src/Olive.jl
-- deps/includes  (you are here)
-- default routes
-- extension loader
-- Server Defaults
- [Core.jl](./src/Core.jl)
-- OliveExtensions
-- OliveModifiers
-- Directories
-- Projects
-- server extension
-- display
-- filetracker
- [UI.jl](./src/UI.jl)
-- styles
- [Extensions.jl](./src/Extensions.jl)
==#

include("Core.jl")
include("UI.jl")
#==output[code]
==#
#==|||==#
"""
### route ("/session") (main)
--------------------
This is the function/Route which runs olive's "session" page, the main editor
    for olive. If you are providing this to a server directly with olive
functionality. Note that by  simply providing any server with the `OliveCore`
extension, this route, and also  ways to  populate directories...

It's  pretty smart because with `create` you could  very easily build  a whole
system out of this. I **am** putting this  in  the documentation so you may check
it out. Endemic of future projects? **definitely**
##### example
```
```
"""
main = route("/session") do c::Connection
    # setup base env
    write!(c, olivesheet())
    c[:OliveCore].client_data[getname(c)]["selected"] = "session"
    olmod::Module = c[:OliveCore].olmod
    proj_open::Project{<:Any} = c[:OliveCore].open[getname(c)]
    # setup base UI
    notifier::Component{:div} = olive_notific()
    ui_topbar::Component{:div} = topbar(c)
    style!(ui_topbar, "position" => "sticky")
    ui_explorer::Component{:div} = projectexplorer()
    ui_settings::Component{:section} = settings_menu(c)
    sticky::Component{:div} = div("olive-sticky")
    ui_explorer[:children] = Vector{Servable}([begin
   Base.invokelatest(olmod.build, c, d, olmod, exp = true)
    end for d in proj_open.directories])
    olivemain::Component{:div} = olive_main(first(proj_open.open)[1])
    mainpane = div("olivemain-pane")
    style!(mainpane, "display" => "flex", "overflow-x" => "scroll", "padding" => 0px)
    push!(olivemain, ui_settings, mainpane)
    bod = body("mainbody")
    push!(bod, notifier,  ui_explorer, ui_topbar, olivemain)
    script!(c, "load", type = "Timeout", time = 100) do cm::ComponentModifier
        load_extensions!(c, cm, olmod)
        window::Component{:div} = Base.invokelatest(olmod.build, c,
        cm, proj_open)
        append!(cm, "olivemain-pane", window)
    end
    write!(c, bod)
end

explorer = route("/") do c::Connection
    args = getargs(c)
    notifier::Component{:div} = olive_notific()
    loader_body = div("loaderbody", align = "center")
    style!(loader_body, "margin-top" => 10percent)
    write!(c, olivesheet())
    icon = olive_loadicon()
    bod = body("mainbody")
    if :key in keys(args)
        if ~(args[:key] in keys(c[:OliveCore].client_keys))
            write!(c, "bad key.")
            return
        end
        uname = c[:OliveCore].client_keys[args[:key]]
        if ~(getip(c) in keys(c[:OliveCore].names))
            push!(c[:OliveCore].names, getip(c) => uname)
        end
        c[:OliveCore].names[getip(c)] = uname
        c[:OliveCore].client_data[getname(c)]["selected"] = "files"
        on(c, bod, "load") do cm::ComponentModifier
            olmod = c[:OliveCore].olmod
            homeproj = Directory(c[:OliveCore].data["home"], "root" => "rw")
            workdir = Directory(c[:OliveCore].data["wd"], "all" => "rw")
            dirs = [homeproj, workdir]
            main = olive_main("files")
            for dir in dirs
                push!(main[:children], build(c, dir, olmod))
            end
            script!(c, cm, "loadcallback") do cm
                style!(cm, icon, "opacity" => 0percent)
                set_children!(cm, bod, [olivesheet(), notifier, main])
            end
            load_extensions!(c, cm, olmod)
        end
        push!(loader_body, icon)
        push!(bod, loader_body)
        write!(c, bod)
        return
    end
    coverimg::Component{:img} = olive_cover()
    olivecover = div("topdiv", align = "center")
    logbutt = button("requestaccess", text = "request access")
    on(c, logbutt, "click") do cm::ComponentModifier
        c[:Logger].log(" someone is trying to login to olive! is this you?")
        y = readline()
        if y == "y"
            c[:Logger].log(" okay, logging in as root.")
            key = ToolipsSession.gen_ref(16)
            push!(c[:OliveCore].client_keys[key] => c[:OliveCore].data["root"])
            redirect!(cm, "/?key=$(key)")
        end
    end
    push!(olivecover, coverimg,
    h("mustconfirm", 2, text = "request access (no key)"), logbutt)
    push!(bod, olivecover)
    write!(c, bod)
end
 #==output[code]
 ==#
 #==|||==#
 """
 ### devmode ("/") (devmode)
 --------------------
This is a route that autoloads an active Olive sourceable module -- in addition
to offering some examples.
 ##### example
 ```
 ```
 """
devmode = route("/") do c::Connection
    explorer.page(c)
end
#==output[code]
==#
#==|||==#
#==output[TODO]
I would love for the doc browser to be completed..
I want it to work primarily off of just requests, and client functions.
Other than the search of course. There is a lot more
==#
#==|||==#
docbrowser = route("/doc") do c::Connection
    notifier::Component{:div} = olive_notific()
    write!(c, DOCTYPE())
    write!(c, olivesheet())
    write!(c, notifier)
    if ~(getname(c) in keys(c[:OliveCore].open))~
        # TODO doc for OLMOD
        push!(c[:OliveCore].open, getname(c) => Project{:doc}())
        return
    end
    p::Project{<:Any} = c[:OliveCore].open[getname(c)]
    mod = getarg(c, :mod, first(p.open)[1])
    getdoc = getarg(c, :get, "$(p.name)")
    docs = p.open[mod][:mod].evalin(Meta.parse("@doc($(getdoc))"))
    T = p.open[mod][:mod].evalin(Meta.parse("$(getdoc)"))
    if typeof(T) == Module
        write!(c, h("mod", 1, text = "module"))
    end
    write!(c, h("T", 2, text = string(typeof(T))))
    write!(c, tmd(ToolipsSession.gen_ref(), string(docs)))
end
#==output[code]
==#
#==|||==#
setup = route("/") do c::Connection
    write!(c, olivesheet())
    bod = body("mainbody")
    cells = [Cell(1, "setup", "welcome to olive"),
    Cell(2, "dirselect", c[:OliveCore].data["home"])]
    built_cells = Vector{Servable}([build(c, cell) for cell in cells])
    bod[:children] = built_cells
    confirm_button = button("confirm", text = "confirm")
    questions = section("questions")
    style!(questions, "opacity" => 0percent, "transition" => 2seconds,
    "transform" => "translateY(50%)")
    push!(questions, h("questions-heading", 2, text = "a few more things ..."))
    opts = [button("yes", text = "yes"), button("no", text = "no")]
    push!(questions, h("questions-defaults", 4, text = "would you like to add OliveDefaults?"))
    push!(questions, p("defaults-explain", text = """this extension will give the
    capability to add custom styles, adds more cells, and more!"""))
    defaults_q = ToolipsDefaults.button_select(c, "defaults_q", opts)
    push!(questions, defaults_q)
    push!(questions, h("questions-download", 4,
     text = "would you like to download olive icons?"))
     push!(questions, p("download-explain", text = """this will download
     a CSS file that provides Olive's material icons, meaning you will still
     have icons while offline, and they will load faster. (requires an internet connection)"""))
    opts2 = [button("yesd", text = "yes"), button("nod", text = "no")]
    download_q = ToolipsDefaults.button_select(c, "download_q", opts2)
    push!(questions, download_q)
    push!(questions, h("questions-name", 2,
    text = "lastly, can we get your name?"))
    namebox::Component{:div} = ToolipsDefaults.textdiv("namesetup",
    text = "root")
    on(namebox, "click") do cl::ClientModifier
        set_text!(cl, "namesetup", "")
    end
    push!(questions, namebox)
    confirm_questions = button("conf-q", text = "confirm")
    on(c, confirm_questions, "click") do cm::ComponentModifier
        dfaults = cm[defaults_q]["value"]
        dload = cm[download_q]["value"]
        statindicator = a("statind", text = "okay! i'll get this set up for you.")
        loadbar = ToolipsDefaults.progress("oliveprogress", value = "0")
        style!(loadbar, "webkit-progreess-value" => "pink", "background-color" => "orange",
         "radius" => 4px, "transition" => 1seconds, "width" => 0percent,
         "opacity" => 0percent)
         append!(cm, bod, loadbar)
         append!(cm, questions, br())
         append!(cm, questions, statindicator)
         style!(cm, questions, "border-radius" => 0px)
         next!(c, questions, cm) do cm2
             set_text!(cm2, statindicator, "setting up olive ...")
             style!(cm2, loadbar, "opacity" => 100percent, "width" => 100percent)
             next!(c, loadbar, cm2) do cm3
                 if ~(isdir(cm["selector"]["text"] * "/olive"))
                     if cm["selector"]["text"] != homedir()
                         srcdir = @__DIR__
                         touch("$srcdir/home.txt")
                         open("$srcdir/home.txt", "w") do o
                             write(o, cm["selector"]["text"])
                         end
                     end
                     create_project(cm["selector"]["text"])
                     config = TOML.parse(read(
                     "$(cm["selector"]["text"])/olive/Project.toml",String))
                     username::String = replace(cm3[namebox]["text"],
                     " " => "_")
                     users = Dict{String, Any}(
                     username => Dict{String, Vector{String}}(
                     "group" => ["all", "root"])
                     )
                     push!(config,
                     "olive" => Dict{String, String}("root" => username),
                     "oliveusers" => users)
                     open("$(cm["selector"]["text"])/olive/Project.toml", "w") do io
                         TOML.print(io, config)
                     end
                 end
                 set_text!(cm3, statindicator, "project created !")
                 cm3[loadbar] = "value" => ".50"
                 style!(cm3, loadbar, "opacity" => 99percent)
                 next!(c, loadbar, cm3) do cm4
                     txt = ""
                     if dfaults == "yes"
                         alert!(cm4, "defaults not yet implemented")
                         txt = txt * "defaults loaded! "
                     end
                     if dload == "yes"
                         alert!(cm4, "download not yet implemented")
                         txt = txt * "downloaded icons!"
                     end
                     set_text!(cm4, statindicator, txt)
                     cm4[loadbar] = "value" => "1"
                     style!(cm4, loadbar, "opacity" => 100percent)
                     next!(c, loadbar, cm4) do cm5
                         deleteat!(c.routes, 1)
                         deleteat!(c.routes, 1)
                         oc = c[:OliveCore]
                         direc = cm["selector"]["text"]
                         oc.data["home"] = "$direc/olive"
                         source_module!(oc)
                         push!(c.routes, fourofour, main, explorer)
                         unamekey = ToolipsSession.gen_ref(16)
                         push!(c[:OliveCore].client_keys, unamekey => username)
                         redirect!(cm5, "/?key=$(unamekey)")
                     end
                 end
             end
         end
    end
    push!(questions, confirm_questions)
    on(c, confirm_button, "click") do cm::ComponentModifier
        selected = cm["selector"]["text"]
        insert!(questions[:children], 1, h("selector", 1, text = selected))
        [style!(cm, b_cell, "transform" => "translateX(-110%)", "transition" => 2seconds) for b_cell in built_cells]
        style!(cm, confirm_button, "transform" => "translateX(-120%)", "transition" => 2seconds)
        append!(cm, bod, questions)
        next!(c, confirm_button, cm) do cm2
            [remove!(cm2, b_cell) for b_cell in built_cells]
            style!(cm2, questions, "transform" => "translateY(0%)", "opacity" => 100percent)
        end
        #
    end
    push!(bod, confirm_button)
    write!(c, bod)
end
#==output[code]
==#
#==|||==#
fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
#==output[code]
==#
#==|||==#
function create_project(homedir::String = homedir(), olivedir::String = "olive")
        try
            cd(homedir)
            Pkg.generate("olive")
        catch
            throw("unable to access your applications directory.")
        end
        open("$homedir/$olivedir/src/olive.jl", "w") do o
            write(o,
            """\"""
            ## welcome to olive!
            Welcome to olive: the extensible notebook application for Julia.
            This is  your olive home module's file. This is where extensions
            for olive can be loaded. If you would  like to make your own
            extension, extend `Olive.build` below... `?(Olive.build)` might
            be helpful. Alternatively, simply use `using` to load extensions
            from modules. For example,
            ```julia
            using OliveDefaults.Styler
            using OlivePy
            ```
            Above all, have fun! Thanks for trying olive! Report any issues to
            [our issues page!](https://github.com/ChifiSource/Olive.jl/issues)
            \"""
            #==|||==#
            module olive
            #==output[code]
            this cell starts the module, you probably don't want to run it.
            ==#
            #==|||==#
            using Olive
            using Olive.Toolips: Connection
            import Olive: build
            # add extensions here!
            build(oc::OliveCore) = begin
                oc::OliveCore
            end
            #==output[code]
            olive.build
            ==#
            #==|||==#
            # ?build
            #==output[helprepl]

            ==#
            #==|||==#
            end # module
            #==output[code]
            this cell ends the module, you probably don't want to run it.
            ==#
            #==|||==#
            """)
        end
        @info "olive files created! welcome to olive! "
end
#==output[code]
==#
#==|||==#
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
    srcdir = @__DIR__
    homedirec::String = homedir()
    if isfile("$srcdir/home.txt")
        homedirec = read("$srcdir/home.txt", String)
    end
    oc::OliveCore = OliveCore("olive")
    oc.data["home"] = homedirec
    oc.data["wd"] = pwd()
    rootname::String = ""
    rs::Vector{AbstractRoute} = Vector{AbstractRoute}()
    if ~(isdir("$homedirec/olive"))
        rs = routes(setup, fourofour)
    else
        config = TOML.parse(read("$homedirec/olive/Project.toml", String))
        Pkg.activate("$homedirec/olive")
        oc.data = config["olive"]
        rootname = oc.data["root"]
        oc.client_data = config["oliveusers"]
        oc.data["home"] = homedirec * "/olive"
        oc.data["wd"] = pwd()
        source_module!(oc)
        rs = routes(fourofour, main, explorer, docbrowser)
    end
    server = WebServer(IP, PORT, routes = rs, extensions = [OliveLogger(),
    oc, Session(["/", "/session", "/doc"])])
    if rootname != ""
        key = ToolipsSession.gen_ref(16)
        push!(oc.client_keys, key => rootname)
        server[:Logger].log(2,
            "link for $(rootname): http://$(IP):$(PORT)/?key=$key")
    end
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
#==output[code]
==#
#==|||==#
export OliveCore, build, Pkg, TOML, Toolips, ToolipsSession
export OliveExtension, OliveModifier
#==output[code]
==#
#==|||==#
end # - module
#==output[code]
==#
#==|||==#
