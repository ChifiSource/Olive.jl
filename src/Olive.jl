 """
Created in February, 2022 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
by team
[toolips](https://github.com/orgs/ChifiSource/teams/toolips)
This software is MIT-licensed.
#### | olive | - | pure julia parametric notebook IDE
Welcome to olive! olive is an *integrated notebook development environment* for Julia with unparalleled extensibility.
```julia
using Olive; Olive.start()
```
"""
module Olive
import Base: write, display, getindex, setindex!, string, showerror, push!
using Toolips
using Toolips.Components
using Toolips: WebServer
import Toolips.Components: Servable
import Toolips: AbstractRoute, AbstractConnection, AbstractComponent, Crayon, write!, Modifier, AbstractComponentModifier, on_start, Route
using ToolipsSession
import ToolipsSession: KeyMap
using IPyCells
import IPyCells: Cell
using Pkg
using OliveHighlighters
using TOML

"""
```julia
build(c::AbstractConnection, ...) -> ::AbstractComponent
```
The `build` function is used as the translation layer between the
    `Olive` back-end and front-end. The client is HTML, these functions build 
    an HTML representation of a given parametric type. New cells, directories, 
    and projects can easily be created by extending this function with new methods.
```julia
# extensible methods for build:

build(c::Connection, om::OliveModifier, oe::OliveExtension{<:Any}) # load extensions

build(c::Connection, env::Environment{<:Any}) # environment extensions

build(c::Connection, dir::Directory{<:Any}) # directory extensions

build(c::AbstractConnection, cm::ComponentModifier, p::Project{<:Any}) # project extensions

build(c::Connection, cell::Cell{:dir}, d::Directory{<:Any}; bind::Bool = true) # file cells

build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any}, proj::Project{<:Any}) # code cells
```
For example, the `:code` cell is added to `Olive` using the `Method` 
`build(::Connection, ::ComponentModifier, ::Cell{:code}, ::Project{<:Any})`.
- See also: `start`, `on_code_build`, `cell_highlight!`, `cell_bind!`, `evaluate`, `Cell`, `Project`
"""
function build end

global evalin(ex::Any) = begin
    Main.eval(ex)
end
#==
code/none
==#
#--
"""export evalin
```julia
olive_module(modname::String, environment::String) -> ::String
```
Creates a simple, minimalist `Olive` module. This comes in the form of a `String`, 
which is parsed and evaluated to create `Olive` modules for projects. If you want to get a `Module` for 
    your project, it is probably better to use `source_module!`
```example
mod = eval(Meta.parse(olive_module("mymod", "."))) 
```
"""
function olive_module(modname::String, environment::String)
    """
    baremodule $(modname)
    using Pkg
    using Base
    import Base: println, print
    global STDO::String = ""
    WD = ""
    Main = nothing
    Olive = nothing
    eval(e::Any) = Core.eval($(modname), e)
    function evalin(ex::Any)
            Pkg.activate("$environment")
            ret = eval(ex)
    end
    Base.delete_method(methods(println)[3])
    Base.delete_method(methods(print)[29])
    
    println(x::Any ...) = begin
        $modname.STDO=$modname.STDO*join(string(x) for x in x)*"</br>"
        return(nothing)::Nothing
    end
    print(x::Any ...) = begin
        $modname.STDO=$modname.STDO*join(string(x) for x in x)
        return(nothing)::Nothing
    end
    end
    """
end
#==
code/none
==#
#--
"""
```julia
olive_motd() -> ::Component{:div}
```
Creates a markdown component containing the `Olive` message of the day.
```example
using Olive

route("/") do c::Connection
    motd = Olive.olive_motd()
    write!(c, motd)
end
```
"""
function olive_motd()
    recent_str::String = """# olive editor
    ##### $(pkgversion(Olive)) (Beta I)
    - **thank you for using olive beta I !**
    """
    tmd("olivemotd", recent_str)::Component{<:Any}
end

include("Core.jl")

include("UI.jl")

include("extensions.jl")

"""
```julia
verify_client!(c::Connection) -> ::Tuple{String, Dict{Symbol, String}}
```
Verifies an incoming client, registers keys to names. Returns the username of the current `Connection` and 
the current `GET` arguments. This is called at the beginning of `make_session` and will make sure all clients 
have keys.
"""
function verify_client!(c::Connection)
    ip::String = get_ip(c)
    args = get_args(c)
    if ip in keys(c[:OliveCore].names)
        return(c[:OliveCore].names[ip], args)
    end
    if ~(:key in keys(args))
        coverimg::Component{:img} = olive_cover()
        olivecover::Component{:div} = div("topdiv", align = "center")
        logbutt = button("requestaccess", text = "request access")
        on(c, logbutt, "click") do cm::ComponentModifier
            log(c[:Logger], " someone is trying to login to olive! is this you?")
            y = readline()
            if y == "y"
                log(c[:Logger], " okay, logging in as root.")
                key = ToolipsSession.gen_ref(16)
                push!(c[:OliveCore].client_keys, [key] => c[:OliveCore].data["root"])
                redirect!(cm, "/?key=$(key)")
            end
        end
        push!(olivecover, coverimg,
        h2("mustconfirm", text = "request access (no key)"), logbutt)
        write!(c, olivecover)
        return("dead", args)
    end
    if ~(args[:key] in keys(c[:OliveCore].client_keys))
        write!(c, "bad key.")
        return("dead", args)
    end
    uname = c[:OliveCore].client_keys[args[:key]]
    if ~(ip in keys(c[:OliveCore].names))
        push!(c[:OliveCore].names, ip => uname)
    end
    return(uname, args)
end
#==
code/none
==#
#--
"""
```julia
load_default_project!(c::Connection) -> ::Environment
```
Creates the default `Olive` environment with the `getstarted` project. This is the default 
function provided to `make_session` for loading a new environment. The default project can be changed 
    by assembling your own `Environment` and providing this function as `default` to `make_session`. For 
    help in making your own `Environment`, here is how this is done for load_default_project!:
```julia
function load_default_project!(c::Connection)
    name::String = getname(c)
    oc::OliveCore = c[:OliveCore]
    cells = Vector{Cell}([Cell("getstarted", "")])
    env::Environment = Environment(name)
    env.pwd::String = oc.data["wd"]
    env.directories = copy(get_group(c).directories)
    pwd_direc::Directory{:pwd} = Directory(env.pwd, dirtype = "pwd")
    projdict::Dict{Symbol, Any} = Dict{Symbol, Any}(:cells => cells,
    :pane => "one", :env => " ")
    sourced_path::String = " "
    if "home" in keys(oc.data)
        push!(projdict, :env => oc.data["home"])
        sourced_path = oc.data["home"]
    end
    myproj::Project{<:Any} = Project{:olive}("get started", projdict)
    oc.olmod.Olive.source_module!(c, myproj, sourced_path)
    insert!(env.directories, 1, pwd_direc)
    push!(env.projects, myproj)
    push!(oc.open, env)
    env::Environment
end
```
- See also: `make_session`
"""
function load_default_project!(c::Connection)
    name::String = getname(c)
    oc::OliveCore = c[:OliveCore]
    cells = Vector{Cell}([Cell("getstarted", "")])
    env::Environment = Environment(name)
    env.pwd::String = oc.data["wd"]
    env.directories = copy(get_group(c).directories)
    pwd_direc::Directory{:pwd} = Directory(env.pwd, dirtype = "pwd")
    projdict::Dict{Symbol, Any} = Dict{Symbol, Any}(:cells => cells,
    :pane => "one", :env => " ")
    sourced_path::String = " "
    if "home" in keys(oc.data)
        push!(projdict, :env => oc.data["home"])
        sourced_path = oc.data["home"]
    end
    myproj::Project{<:Any} = Project{:olive}("get started", projdict)
    oc.olmod.Olive.source_module!(c, myproj, sourced_path)
    insert!(env.directories, 1, pwd_direc)
    push!(env.projects, myproj)
    push!(oc.open, env)
    env::Environment
end
#==
code/none
==#
#--
"""
```julia
build(c::Connection, env::Environment{<:Any}; icon::AbstractComponent = olive_loadicon(), sheet::AbstractComponent = DEFAULT_SHEET, 
    themes_enabled::Bool = true) -> Tuple{Component, Component, Component}
```
The `build` function for an `Olive` `Environment` assembles the various components 
which compose `Olive` into the `Olive` page. That being said, simply changing the loaded 
environment can alter how `Olive` loads entirely. This function should return 

1. the main body from which the `Olive` is built
2. the loadicondiv, the loadicon loaded into a `Component{:div}`. The loadicon can be whatever you want, 
and can be provided as an argument to the default `Environment` `build` function.
The calling of this function is done on a `Toolips.Route`, we are able to assemble our own `Environment` (`?(Environment)`) or use 
    `load_default_project!(::Connection)`.
```example
myr = route("/") do c::Connection
    uname = Olive.verify_client!(c)
    # check for environment, if none, we load the default.
    envsearch = findfirst(e::Environment -> e.name == uname, c[:OliveCore].open)
    if isnothing(envsearch)
        env::Environment = load_default_project!(c)
    else
        env = c[:OliveCore].open[getname(c)]
    end
    # setup base UI
    bod::Component{:body}, loadicondiv::Component{:div}, olmod::Module = build(c, env)
end
```
From here, we would still need to load the projects from our `Environment` into our olive main. For reference, this is how `session` does this.
```julia
script!(c, "load", ["olivemain"], type = "Timeout", time = 350) do cm::ComponentModifier
    load_extensions!(c, cm, olmod)
    style!(cm, "loaddiv", "opacity" => 0percent)
    next!(c, loadicondiv, cm, ["olivemain"]) do cm2::ComponentModifier
        remove!(cm2, "loaddiv")
        switch_work_dir!(c, cm2, env.pwd)
        [begin
            append!(cm2, "pane_\$(proj.data[:pane])_tabs", build_tab(c, proj))
            if proj.id != env.projects[1].id
                style_tab_closed!(cm2, proj)
            end
        end for proj in env.projects]
        if length(env.projects) > 0
            window::Component{:div} = olmod.build(c, cm2, env.projects[1])
            append!(cm2, "pane_\$(env.projects[1].data[:pane])", window)
            focus!(cm2, "cell\$(env.projects[1].data[:cells][1].id)")
            p2i = findfirst(proj -> proj[:pane] == "two", env.projects)
            if ~(isnothing(p2i))
                style!(cm2, "pane_container_two", "width" => 100percent, "opacity" => 100percent)
                append!(cm2,"pane_two", olmod.build(c, cm2, env.projects[1]))
            end
        end
    end
end
write!(c, bod)
```
###### extending
To extend, we start by creating a new symbolic dispatch, this one I am naming `customenv`
```example
import Olive: build
using Olive

function build(c::Connection, env::Environment{:customenv})
    ui_explorer::Component{:div} = projectexplorer()
    ui_explorer[:children] = Vector{Servable}([begin
        olmod.build(c, d)
    end for d in env.directories])
    olivemain::Component{:div} = olive_main()
    olivemain["pane"] = "1"
    pane_one::Component{:section} = section("pane_one")
    pane_one_tabs::Component{:div} = div("pane_one_tabs")
    ...
end
```
From here, we would need to build out the **entire** `Olive` UI. That being said, 
`Environment` extensions are likely the least approachable extensions, and it might be valuable 
to look at this Function (line 274 of Olive.jl) to get an idea of how it works, and how one might 
extend `Olive` using a new `Environment` type.
- See also: `Project`, `Environment`, `make_session`, `start`, `getname`
"""
function build(c::Connection, env::Environment{<:Any}; icon::AbstractComponent = olive_loadicon(), sheet::AbstractComponent = DEFAULT_SHEET, 
    themes_enabled::Bool = true)
    selected_sheet = sheet
    if themes_enabled
        if haskey(c[:OliveCore].client_data[getname(c)], "theme")
            @info c[:OliveCore].client_data[getname(c)]["theme"]
            theme_name = c[:OliveCore].client_data[getname(c)]["theme"]
            theme_dir = CORE.data["home"] * "/themes"
            fpath = theme_dir * "/$(replace(theme_name, " " => "-")).olivestyle"
            selected_sheet = TOML.parse(read(fpath, String))["COMPOSED"]
        end
    end
    write!(c, selected_sheet)
    olmod::Module = c[:OliveCore].olmod
    notifier::Component{:div} = olive_notific()
    ui_topbar::Component{:div} = topbar(c)
    ui_explorer::Component{:div} = projectexplorer()
    ui_settings::Component{:div} = settings_menu(c)
    ui_explorer[:children] = Vector{Servable}([begin
        comp = olmod.build(c, d)
        compress!(comp)
        comp::Component{:div}
    end for d in env.directories])
    olivemain::Component{:div} = olive_main()
    olivemain["pane"] = "1"
    pane_one::Component{:section} = section("pane_one")
    pane_one_tabs::Component{:div} = div("pane_one_tabs")
    style!(pane_one_tabs, "display" => "inline", "padding" => 0px, "width" => 50percent)
    pane_two_tabs::Component{:div} = div("pane_two_tabs")
    style!(pane_two_tabs, "display" => "inline", "padding" => 0px, "width" => 50percent)
    pane_container_one::Component{:div} = div("pane_container_one")
    style!(pane_container_one, "width" => 100percent, "overflow" => "hidden", "display" => "inline-block",
    "transition" => 1seconds)
    pane_container_two::Component{:div} = div("pane_container_two")
    style!(pane_container_two, "width" => 0percent, "overflow" => "hidden", "display" => "inline-block",
    "opacity" => 0percent, "transition" => 1seconds)
    on(c, pane_container_one, "click") do cm::ComponentModifier
        cm[olivemain] = "pane" => "1"
    end
    pane_two::Component{:section} = section("pane_two")
    on(c, pane_container_two, "click") do cm::ComponentModifier
        cm[olivemain] = "pane" => "2"
    end
    style!(pane_one, "display" => "inline-block", "width" => 100percent, "overflow-y" => "scroll",
    "overflow-x" => "hidden", "padding" => 0px, "max-height" => 95percent, "border-top-left-radius" => 0px, "border-top-right-radius" => 0px, 
    "border-color" => "#333333")
    style!(pane_two, "display" => "inline-block", "width" => 100percent, "overflow-y" => "scroll",
    "overflow-x" => "hidden", "padding" => 0px, "max-height" => 95percent, "border-top-left-radius" => 0px, "border-top-right-radius" => 0px, 
    "border-color" => "#333333")
    push!(pane_container_one, pane_one_tabs, pane_one)
    push!(pane_container_two, pane_two_tabs, pane_two)
    loadicondiv::Component{:div} = div("loaddiv", align = "center")
    style!(loadicondiv, "padding" => 10percent, "transition" => 400ms)
    push!(loadicondiv, icon)
    push!(pane_one, loadicondiv)
    push!(olivemain, pane_container_one, pane_container_two)
    style!(olivemain, "overflow-x" => "hidden", "position" => "relative",
    "width" => 100percent, "overflow-y" => "hidden",
    "height" => 90percent, "display" => "inline-flex")
    bod::Component{:body} = body("mainbody")
    style!(bod, "overflow" => "hidden")
    push!(bod, notifier,  ui_explorer, ui_topbar, ui_settings, olivemain)
    return(bod, loadicondiv, olmod)
end

#==
code/none
==#
#--
"""
### Olive
```julia
session(c::Connection; key::Bool = true, default::Function = load_default_project) -> ::Nothing
```
---
The `session` `Function` is responsible for comprising the initial `Olive` UI as it is served to 
an incoming `Connection`. Providing a `Connection` to this route will create an `Olive` page on that route. 
The `session` route consists of four major steps:
- verifying the client
- loading a default `Environment` for clients without an `Environment`
- build and serve the `Olive` UI
- load projects into the `Olive` UI.

Providing the key-word argument `key` as `false` will remove client verification from `Olive`. Be weary, as this will also remove
name registration. Providing a `default` function allows us to change the default `Environment` that is loaded. In order to use these arguments,
we will need to create a passthrough.
```example
using Olive

function example_function(c::Connection)
    Environment(getname(c))::Environment
end

function customstart()
    ws = Olive.start()
    ws["/"] = c::Connection -> session(c, key = false, default = example_function)
end
````
"""
function make_session(c::Connection; key::Bool = true, default::Function = load_default_project!, icon::AbstractComponent = olive_loadicon(), 
    sheet = DEFAULT_SHEET)
    if get_method(c) == "post"
        return
    end
    write!(c, Components.DOCTYPE())
    uname::String = ""
    args = nothing
    if key
        unameargs = verify_client!(c)
        uname, args = unameargs[1], unameargs[2]
        if uname == "dead"
            return
        end
    else
        if ~(get_ip(c) in keys(c[:OliveCore].names))
            throw("""You have an incorrectly configured `Olive` server... `key` is set to false, 
            but there is no loader loading your users into keys. The reason you would have `key` off is to 
            add your own authentication. You will need to setup the client's IP in `OliveCore.names` before calling `make_session`, 
            this is the exact check you failed; `~(get_ip(c) in keys(c[:OliveCore].names))`. If you are going to disable 
            `Olive` authentication, then you need to setup the client's environment in the route above this one.""")
        end
        uname = getname(c)
    end
    # check for environment, if none load.
    envsearch = findfirst(e::Environment -> e.name == uname, c[:OliveCore].open)
    if isnothing(envsearch)
        env::Environment = default(c)
    else
        env = c[:OliveCore].open[getname(c)]
    end
    navigate_to = nothing
    if haskey(args, :heading)
        navigate_to = args[:heading]
    end
     # setup base UI
    bod::Component{:body}, loadicondiv::Component{:div}, olmod::Module = build(c, env, icon = icon, sheet = sheet)
    on(c, 10) do cm::ComponentModifier
        load_extensions!(c, cm, olmod)
        style!(cm, "loaddiv", "opacity" => 0percent)
        next!(c, cm, loadicondiv) do cm2::ComponentModifier
            remove!(cm2, "loaddiv")
            switch_work_dir!(c, cm2, env.pwd)
            [begin
                append!(cm2, "pane_$(proj.data[:pane])_tabs", build_tab(c, proj))
                if proj.id != env.projects[1].id
                    style_tab_closed!(cm2, proj)
                end
            end for proj in env.projects]
            if length(env.projects) > 0
                p1i = findfirst(proj -> proj[:pane] == "one", env.projects)
                if ~(isnothing(p1i))
                    selected_proj = env.projects[1]
                    window::Component{:div} = olmod.build(c, cm2, env.projects[1])
                    append!(cm2, "pane_$(env.projects[1].data[:pane])", window)
                    if ~(isnothing(navigate_to))
                        @info "navigating to"
                        filtered_mds = filter(cell -> typeof(cell) == Cell{:markdown}, selected_proj[:cells])
                        found = findfirst(cell -> contains(cell.source, "# $navigate_to"), filtered_mds)
                        if ~(isnothing(found))
                            @info "scrolling"
                            cellid = selected_proj[:cells][found]
                            scroll_to!(cm, "cell$cellid")
                        else
                            @info join("$(typeof(c)) $(c.source)" for c in selected_proj[:cells])
                        end
                    end
                end
                p2i = findfirst(proj -> proj[:pane] == "two", env.projects)
                if ~(isnothing(p2i))
                    style!(cm2, "pane_container_two", "width" => 100percent, "opacity" => 100percent)
                    append!(cm2,"pane_two", olmod.build(c, cm2, env.projects[1]))
                end
            else
                # TODO default project here
            end
        end
    end
    write!(c, bod)
end
#==
code/none
==#
#--
main::Route{Connection} = route(make_session, "/")
#==
code/none
==#
#--
fourofour::Route{Connection} = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
#==
code/none
==#
#--
icons::Route{Connection} = route("/MaterialIcons.otf") do c::Connection
    srcdir = @__DIR__
    write!(c, Toolips.File(srcdir * "/fonts/MaterialIcons.otf"))
end
mainicon::Route{Connection} = route("/favicon.ico") do c::Connection
    srcdir = @__DIR__
    write!(c, Toolips.File(srcdir * "/images/favicon.ico"))
end
#==
code/none
==#
#--
CORE::OliveCore = OliveCore("olive")
"""
```julia
start(IP::Toolips.IP4 = "127.0.0.1":8000; path::String = replace(homedir(), "\\" => "/")) -> ::ParametricProcesses.ProcessManager
```
Starts your `Olive` server! This function puts together your `Olive` server and sources your `olive` home.  `path` is used to denote a path to run `Olive` from.
`warm` determines whether or not `Olive` should "warm up" your `Toolips` server by precompiling and invoking it.
```
using Olive

olive_server = Olive.start()

olive_server = Olive.start("127.0.0.1", 8001, warm = false, path = pwd())
```
"""
function start(IP::Toolips.IP4 = "127.0.0.1":8000; path::String = replace(homedir(), "\\" => "/"))
    ollogger::Toolips.Logger = LOGGER
    path = replace(path, "\\" => "/")
    if path[end] == '/'
        path = path[path:end - 1]
    end
    rootname::String = ""
    if ~(isdir("$path/olive"))
        setup_olive(ollogger, path)
    end
    try
        config::Dict{String, <:Any} = TOML.parse(read("$path/olive/Project.toml", String))
        Pkg.activate("$path/olive")
        CORE.data = config["olive"]
        rootname = CORE.data["root"]
        CORE.client_data = config["oliveusers"]
        if ~haskey(CORE.data, "home")
            push!(CORE.data, "home" => path * "/olive")
        end
        groups::Vector{Group} = Vector{Group}()
        push!(CORE.data, "wd" => pwd(), "groups" => groups)
        for group in config["groups"]
            name::String = group[1]
            log(ollogger, "loading group: $name")
            newg = Group(name)
            data = group[2]
            newg.cells = [Symbol(s) for s in data["cells"]]
            newg.load_extensions = [Symbol(s) for s in data["load"]]
            newg.directories = [Directory(uri, dirtype = t) for (uri, t) in zip(data["uris"], data["dirs"])]
            push!(groups, newg)
        end
    catch e
        throw(StartError(e, "configuration load", "Failed to load `Project.toml`"))
        log(ollogger, """If you are unsure why this is happening, the best choice is probably just to start 
        with a fresh Project.toml configuration file. Would you like to recreate your olive configuration file? (y or n)""", 3)
    end
    try
        source_module!(CORE)
    catch e
        throw(StartError(e, "module load", "Failed to source olive home module."))
            log(ollogger, """If you are unsure why this is happening, the best choice is probably just to start 
        with a fresh olive.jl source file.""", 2)
    end
    try
        load_extensions!(CORE)
    catch e
        log(ollogger, "olive extensions failed to load.", 3)
        showerror(stdout, e)
    end
    start!(Olive, IP)
    if rootname != ""
        key::String = ToolipsSession.gen_ref(16)
        push!(CORE.client_keys, key => rootname)
        log(ollogger,
            "\nlink for $(rootname): http://$(string(IP))/?key=$key", 2)
    end
end
#==
code/none
==#
#--
"""
```julia
StartError{E <: Exception} <: Exception
```
- on::**String**
- cause**::E**
- message**::String**

The `StartError` is used to articulate problems with `Olive` starting, such as bad configurations or home 
modules.
```example
try
    source_module!(oc)
catch e
    throw(StartError(e, " module load", "Failed to source olive home module."))
end
```
```julia
StartError(cause::Exception, on::String, message::String = "")
```
"""
struct StartError{E <: Exception} <: Exception
    on::String
    cause::E
    message::String
    function StartError(cause::Exception, on::String, message::String = "")
        new{typeof(cause)}(on, cause, message)
    end
end
#==
code/none
==#
#--
function showerror(io::IO, err::StartError{<:Any})
    println(io, Toolips.Crayon(foreground = :red), """on $(err.on).\n$(err.message)\n$(showerror(io, err.cause))""")
end
#==
code/none
==#
#--
"""
```julia
restore_defaults!(server::Toolips.WebServer) -> ::Nothing
```
Restores `Olive` server and client settings to defaults.
```
using Olive

olive_server = Olive.start()

Olive.restore_defaults!(olive_server)
```
"""
function restore_defaults!(server)
    path::String = server[:OliveCore].data["home"]
    root_name::String = server[:OliveCore].data["root"]
    rm("$path/Project.toml"); rm("$path/Manifest.toml")
    Pkg.activate(path)
    Pkg.add("Pkg")
    Pkg.add("Olive")
    config::Dict{String, Any} = TOML.parse(read(
    "$path/Project.toml",String))
    users::Dict{String, Any} = Dict{String, Any}(
        username => Dict{String, Vector{String}}(
        "group" => "root"))
    push!(config,
        "olive" => Dict{String, String}("root" => username),
        "oliveusers" => users)
    open("$path/olive/Project.toml", "w") do io
        TOML.print(io, config)
    end
    server[:Logger].log("restored olive settings to defaults!")
end

"""
```julia
setup_olive(logger::Toolips.Logger, path::String) -> ::Nothing
```
Creates the default `olive` home environment and `olive` home.
```
using Olive

olive_server = Olive.start()

Olive.restore_defaults!(olive_server)
```
"""
function setup_olive(logger::Toolips.Logger, path::String)
    log(logger, "welcome to olive! to set up olive, please provide a name.")
    print("name yourself: ")
    username::String = readline()
    log(logger, "creating $username's `olive` ...")
    create_project(path)
    config::Dict{String, Any} = TOML.parse(read(
        "$path/olive/Project.toml",String))
    log(logger, "creating user configuration")
    # users
    users::Dict{String, Any} = Dict{String, Any}(
        username => Dict{String, String}("group" => "root"))
    # groups
    root_group_data = Dict{String, Vector}("cells" => ["code", "markdown"], "uris" => ["$path/olive"], 
    "dirs" => ["home"], "load" => ["olivebase"])
    groups = Dict{String, Dict{String, Vector}}("root" => root_group_data)
    push!(config,
    "olive" => Dict{String, String}("home" => "$path/olive", "root" => username, "defaultgroup" => "all"),
    "oliveusers" => users, "groups" => groups)
    open("$path/olive/Project.toml", "w") do io
        TOML.print(io, config)
    end
    log(logger, "installing `olive` dependencies.")
    Pkg.activate("$path/olive")
    Pkg.add("Pkg")
    Pkg.add("Olive")
    log(logger, "olive setup completed successfully")
end
SES = ToolipsSession.Session()
LOGGER = OliveLogger()
olive_routes = Vector{Toolips.AbstractRoute}([main, icons, mainicon])

"""
```julia
create(t::Type{<:Any}, name::String, args ...) -> ::Nothing
```
The `create` function is used to create `Olive` projects from templates. 
    This includes deployable `Olive` servers and `Olive` extensions.
```julia
create(t::Type{Toolips.ServerTemplate}, name::String)
create(t::Type{OliveExtension}, name::String)
```
The two dispatches provided by `Olive` take `Olive.WebServer` or `Olive.OliveExtension`.
    Providing `Olive.WebServer` will create a new public-facing `Olive` server, intended to 
    be modified to serve users. The `OliveExtension` dispatch will create a new `OliveExtension` 
    template.
```julia
using Olive
create_new(Olive.WebServer, "MyOliveServer")
create_new(Olive.OliveExtension, "OliveAdvancedCells")
```
- See also: `start`, `Toolips`, `Olive`, `OliveCore`
"""
function create(t::Type{Toolips.WebServer}, name::String)
    Toolips.Pkg.generate(name)
    open("$name/src/$name.jl", "w") do o::IOStream
        write(o, """module $name
        using Olive
        using Olive.Toolips
        using Olive.Toolips.Components

        home = route("/") do c::AbstractConnection
            # ?(make_session) for more customization options
            Olive.make_session(c, key = false)
        end

        function start(; ip::Toolips.IP4 = "127.0.0.1":8000)
            Olive.routes["/"] = home
            Olive.start()
        end
        end""")
    end
    Olive.start(path = name)
end

function create(t::Type{OliveExtension}, name::String)
    Toolips.Pkg.generate(name)
    open("$name/src/$name.jl", "w") do o::IOStream
        write(o, """module $name
        # the web-development framework that powers `Olive`:
        using Olive.Toolips
        # Component HTML, CSS, and JavaScript templating:
        using Olive.Toolips.Components
        import Olive: build, OliveExtension, Cell, olive_notify!
        
        end""")
    end
end

#==
code/none
==#
#--
export CORE, olive_routes, SES, build, evalin, LOGGER
#==
code/none
==#
#--
end # - module
#==output[module]
Olive
==#
#==|||==#
