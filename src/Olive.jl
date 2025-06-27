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
using Toolips.ParametricProcesses: @spawnat
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
    Base.eval(Main, ex)
end
selected_mod = nothing
baremodule OliveBase
import Base
import Base: names, in, contains, Meta, string, join, eval

disabled = [:pwd, :println, :print, :read, :cd, :open, :touch, :cp, :rm, 
:mv, :rmdir]

for name in names(Base)
    if name in disabled
        continue
    end
    if contains(string(name), "#")
        continue
    end
    try
        eval(OliveBase, Meta.parse("import Base: $name"))
        eval(OliveBase, Meta.parse("export $name"))
    catch
        try
            eval(OliveBase, Meta.parse("import Base: ($name)"))
        catch
        end
    end
end

println(STDO::String = "", x::Any ...) = begin
    STDO * join(string(x) for x in x) * "</br>"
end

print(STDO::String = "", x::Any ...) = begin
    STDO * join(string(x) for x in x)
end

read(path::AbstractString, wd::AbstractString, args ...; keyargs ...) = Base.read(wd * "/$path", args ...; keyargs ...)

cd(current_path::AbstractString, to::AbstractString)::String = begin
    if to == ".."
        direc = join(split(current_path, "/")[1:end - 1], "/")
        if isdir(direc)
            return(direc)
        end
    end
    current_path * "/$to"
end

rm(current_path::AbstractString, path::AbstractString; keyargs ...) = Base.rm(current_path * "/$path"; keyargs ...)

cp(current_path::AbstractString, path1::AbstractString, path2::AbstractString; keyargs ...) = Base.cp(current_path * "/$path1", 
    current_path * "/$path2", keyargs ...)

rmdir(current_path::AbstractString, name::AbstractString; args ...) = Base.rmdir(current_path * "/$name"; args ...)

touch(current_path::AbstractString, name::AbstractString) = Base.touch(current_path * "/$name")

mv(current_path::AbstractString, path1::AbstractString, path2::AbstractString; keyargs ...) = Base.mv(current_path * "/$path1", 
    current_path * "/$path2", keyargs ...)

open(current_path::AbstractString, path::AbstractString, args ...; keyargs ...) = Base.open(current_path * "/$path", args ...; keyargs ...)

disabled = nothing
end

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
    using Olive.OliveBase
    const Base = OliveBase
    global STDO::String = ""
    WD = ""
    Main = nothing
    Olive = nothing
    eval(e::Any) = Core.eval($(modname), e)
    function evalin(ex::Any)
        Pkg.activate("$environment")
        ret = eval(ex)
    end
    pwd() = WD
    println(x::Any ...) = begin
        $modname.STDO = OliveBase.println($modname.STDO, x)
        return(nothing)::Nothing
    end
    print(x::Any ...) = begin
        $modname.STDO = OliveBase.print($modname.STDO, x)
        return(nothing)::Nothing
    end
    read(path::AbstractString, args ...; keyargs ...) = OliveBase.read(path, $modname.WD, args ...; keyargs ...)
    cd(path::AbstractString) = $modname.WD = OliveBase.cd($modname.WD, path)
    readdir(path::AbstractString = $modname.WD) = OliveBase.readdir(path)
    open(path::AbstractString, args ...; keyargs ...) = OliveBase.open($modname.WD * "/" * path, args ...; keyargs ...)
    touch(name::AbstractString) = OliveBase.touch($modname.WD, name)
    rmdir(name::AbstractString; args ...) = OliveBase.rmdir($modname.WD, name, args ...)
    mv(name::AbstractString, to::AbstractString; keyargs ...) = OliveBase.mv($modname.WD, name, to)
    cp(name::AbstractString, to::AbstractString; keyargs ...) = OliveBase.cp($modname.WD, name, to)
    end
    """
end

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

function build_key_screen(c::AbstractConnection, message::String = "welcome to olive")
    key_input = Components.textdiv("keyinp", text = "")
    ToolipsSession.bind(c, key_input, "Enter", prevent_default = true) do cm::ComponentModifier
        txt = cm["keyinp"]["text"]
        redirect!(cm, "/?key=$txt")
    end
    style!(key_input, "color" => "#1e1e1e", "border" => "1px solid #1e1e1e", "padding" => 5px, 
    "background-color" => "white", "font-size" => 16pt, "border-radius" => 3px)
    header = h3("-", text = message)
    style!(header, "color" => "white", "font-size" => 22pt)
    message = p("-", text = "Please provide your access key:")
    style!(message, "color" => "#1e1e1e", "font-weight" => "bold", "font-size" => 14pt)
    olivecover = div("-",  children = [header, message, key_input])
    style!(olivecover, "padding" => 10percent)
    mainbod = body(children = [olivecover])
    style!(mainbod, "background-color" => "C16AAD")
    mainbod::Component{:body}
end

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
        write!(c, build_key_screen(c))
        return("dead", args)
    end
    if ~(args[:key] in keys(c[:OliveCore].client_keys))
        write!(c, build_key_screen(c, "bad key"))
        return("dead", args)
    end
    uname = c[:OliveCore].client_keys[args[:key]]
    if ~(ip in keys(c[:OliveCore].names))
        push!(c[:OliveCore].names, ip => uname)
    end
    return(uname, args)
end

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
- See also: `make_session`, `Olive`, `build`
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
    on(pane_container_one, "click") do cm::ClientModifier
        cm[olivemain] = "pane" => "1"
    end
    pane_two::Component{:section} = section("pane_two")
    on(pane_container_two, "click") do cm::ClientModifier
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
    bod = body("mainbody")
    style!(bod, "overflow" => "hidden")
    push!(bod, notifier,  ui_explorer, ui_topbar, ui_settings, olivemain)
    return(bod, loadicondiv, olmod)
end

"""
```julia
make_session(c::Connection; key::Bool = true, default::Function = load_default_project!, icon::AbstractComponent = olive_loadicon(), 
    sheet = DEFAULT_SHEET) -> ::Nothing
```
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
```
"""
function make_session(c::Connection; key::Bool = true, default::Function = load_default_project!, icon::AbstractComponent = olive_loadicon(), 
    sheet = DEFAULT_SHEET)
    if get_method(c) == "post"
        return
    end
    write!(c, Components.DOCTYPE())
    uname = ""
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
        push!(c[:OliveCore].open, env)
    else
        env = c[:OliveCore].open[getname(c)]
    end
     # setup base UI
    bod, loadicondiv, olmod::Module = build(c, env, icon = icon, sheet = sheet)
    on(c, 5) do cm
        load_extensions!(c, cm, olmod)
        style!(cm, "olive-loader", "opacity" => 0percent)
        next!(load_projects, c, cm, "olive-loader")
    end
    write!(c, bod)
    envsearch = nothing
    bod = nothing
    loadicondiv = nothing
    uname = nothing
end

function load_projects(c::AbstractConnection, cm2::ComponentModifier)
    remove!(cm2, "loaddiv")
    env = CORE.open[getname(c)]
    olmod = CORE.olmod
    for proj in env.projects
        projpane = proj.data[:pane]
        append!(cm2, "pane_$(projpane)_tabs", build_tab(c, proj))
        if proj.id != env.projects[1].id
            style_tab_closed!(cm2, proj)
        end
    end
    if length(env.projects) > 0
        window::Component{:div} = olmod.build(c, cm2, env.projects[1])
        append!(cm2, "pane_$(env.projects[1].data[:pane])", window)
        p2i = findfirst(proj -> proj[:pane] == "two", env.projects)
        if ~(isnothing(p2i))
            style!(cm2, "pane_container_two", "width" => 100percent, "opacity" => 100percent)
            append!(cm2,"pane_two", olmod.build(c, cm2, env.projects[p2i]))
        end
    else
        CORE.open[getname(c)] = default(c)
        for proj in env.projects
            projpane = proj.data[:pane]
            append!(cm2, "pane_$(projpane)_tabs", build_tab(c, proj))
            if proj.id != env.projects[1].id
                style_tab_closed!(cm2, proj)
            end
        end
        window = olmod.build(c, cm2, env.projects[1])
        append!(cm2, "pane_$(env.projects[1].data[:pane])", window)
    end
end

main::Route{Connection} = route(make_session, "/")

fourofour::Route{Connection} = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end

icons::Route{Connection} = route("/MaterialIcons.otf") do c::Connection
    srcdir = @__DIR__
    write!(c, Toolips.File(srcdir * "/fonts/MaterialIcons.otf"))
end

mainicon::Route{Connection} = route("/favicon.ico") do c::Connection
    srcdir = @__DIR__
    write!(c, Toolips.File(srcdir * "/images/favicon.ico"))
end

CORE::OliveCore = OliveCore("olive")

function read_config(path::String, wd::String, ollogger::Toolips.Logger)
    config::Dict{String, <:Any} = TOML.parse(read("$path/olive/Project.toml", String))
    Pkg.activate("$path/olive")
    CORE.data = config["olive"]
    rootname = CORE.data["root"]
    CORE.client_data = config["oliveusers"]
    if ~haskey(CORE.data, "home")
        push!(CORE.data, "home" => path * "/olive")
    end
    groups::Vector{Group} = Vector{Group}()
    push!(CORE.data, "wd" => wd, "groups" => groups)
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
end

"""
```julia
start(IP::Toolips.IP4 = "127.0.0.1":8000; path::String = replace(homedir(), "\\" => "/"), wd::String = pwd()) -> ::ParametricProcesses.ProcessManager
```
Starts your `Olive` server! `path` will be the path of the `olive` home -- `Olive` requires this to function in its current state, 
this is how it loads extensions. `wd` will become the default `:pwd` directory inside of `Olive`.
```julia
using Olive

olive_server = Olive.start()

olive_server = Olive.start("127.0.0.1", 8001, warm = false, path = pwd())
```
"""
function start(IP::Toolips.IP4 = "127.0.0.1":8000; path::String = replace(homedir(), "\\" => "/"), wd::String = replace(pwd(), "\\" => "/"), 
    threads::Int64 = 0, headless::Bool = false)
    ollogger::Toolips.Logger = LOGGER
    path = replace(path, "\\" => "/")
    if path[end] == '/'
        path = path[path:end - 1]
    end
    rootname::String = ""
    if ~(isdir("$path/olive"))
        setup_olive(ollogger, path)
    end
    rootname = ""
    if ~(headless)
        try
            read_config(path, wd, ollogger)
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
    else
        push!(CORE.data, "root" => "olive user", "wd" => wd, 
            "groups" => [Group("root")], "headless" => true)
        source_module!(CORE)
        push!(CORE.client_data, "olive user" => Dict{String, Any}("group" => "root"))
    end
    procs::Toolips.ProcessManager = start!(Olive, IP, threads = threads, router_threads = 0:0)
    if threads > 1
        push!(CORE.data, "threads" => threads)
            Main.eval(Meta.parse("""using Toolips: @everywhere; @everywhere begin
            using Olive.Toolips
            using Olive.ToolipsSession
            using Dates
            using Olive
        end"""))
    end
    rootname = CORE.data["root"]
    if rootname != ""
        key::String = ToolipsSession.gen_ref(16)
        push!(CORE.client_keys, key => rootname)
        log(ollogger,
            "\nlink for $(rootname): http://$(string(IP))/?key=$key", 2)
    end
    procs
end

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

function showerror(io::IO, err::StartError{<:Any})
    println(io, Toolips.Crayon(foreground = :red), """on $(err.on).\n$(err.message)\n$(showerror(io, err.cause))""")
end

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
    Pkg.activate("$path/olive")
    log(logger, "creating user configuration")
    # users
    users::Dict{String, Any} = Dict{String, Any}(
        username => Dict{String, String}("group" => "root"))
    # groups
    root_group_data = Dict{String, Vector}("cells" => [], "uris" => ["$path/olive"], 
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

export CORE, olive_routes, SES, build, evalin, LOGGER

end # - module