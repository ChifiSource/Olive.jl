<div align = "center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/newoliveover.png" width="350">
<h6>🩷| 0.0.92 | (pre-release II)|🩷</h6>
</div>

Welcome to olive! Olive is a **pure julia** notebook editor built on the back of multiple dispatch. Through multiple dispatch, olive is able to change functionality entirely by simply having new methods. Using extensions, olive can edit **any** file. Among other things, olive features ...
- regular **julia modules**
- unparalleled **extensibility**
- **modular** design
- **tabbing** notebooks
- its own **julia** ecosystem
- **customizable** settings
- reading of pluto, julia, olive, **and** ipython notebooks
- exporting to **multiple** formats
- a full **file-browser**
- julia **repl cells**
- module and include cells for **software development**
- **deployability**
- **shared variables** between multiple cell-types
- a **two-pane** design
- **loadable** directories as **profiles**
- **flexible** and modern design
- the ability to edit **any** file

Keep in mind this version of Olive (while functional) is still a **work in progress** build. Thank you for reporting bugs to the issues page!

###### map
- [get started](#get-started)
   - [user interface](#user-interface)
     - [session](#session)
     - [keybindings](#keybindings)
     - [project explorer](#project-explorer)
     - [settings](#settings)
- [extensions](#extensions)
   - [installing extensions](#installing-extensions)
   - [common extensions](#common-extensions)
- [creating extensions](#creating-extensions)
   - [documentation](#documentation)
- [deploying olive](#deploying-olive)
   - [`0.0.9`deployment status](#status)
   - [creating an olive server](#creating-a-server)
   - [olive servers](#olive-servers)
   - [OliveSession](#olive-session)
- [contributing](#contributing)
   - [guidelines](#guidelines)
   - [tech stack](#tech-stack)
---
### get started
- this overview corresponds to `Olive` **0.0.92**, subsequent versions may vary slightly.
# get started 1
Getting started with Olive starts by installing this package via Pkg. **Press ] to enter your pkg REPL**, or use the `Pkg.add` `Function` to add `Olive`.
```julia
julia> using Pkg; Pkg.add("Olive")
```
```julia
julia> ]

pkg> add Olive
```
Alternatively, you could also grab `Unstable`, this will give you the latest developments (`0.0.9`), but some features might be intermittently broken.
```julia
julia> ]
pkg> add Olive#Unstable
```
```julia
using Olive; Olive.start()
```
To change the IP or PORT, use the positional arguments `IP` (**1**, `String`) and `PORT` (**2**, `Int64`). There are also the key-word arguments
- `path`**::String** = `homedirec()` -- Provides a path from which to setup or start `Olive`.
- `warm`**::Bool** = `true` -- determines whether or not `Olive` should precompile `olive` and "warm" the `Toolips` server. This helps reduce initial latency when starting `Olive`.

If there is no `olive` setup inside of `path`, `start` will ask us for a root name to create a new `olive` home at that path. Providing `path` allows us to setup multiple `Olive` environments across our filesystem.
# get started 2

```julia
IP = "127.0.0.1" # same as default (see ?(Olive.start))
PORT = 8000
startpath = "/home/dev/notebooks"
using Olive

Olive.start(IP, PORT, path = startpath)
```
The `Olive.start` method also returns a `Toolips.WebServer`, this being the server that contains your entire `Olive` session. This provides an easy avenue to introspect and work with `Olive`, especially if you know what you are doing. There is more information on working with this server type in the [deploying olive](#deploying-olive) portion of this `README`.
#### user interface
Olive's user-interface is relatively straightforward. When starting olive, you will be greeted with a `get started` `Project`. A `Project` in `Olive` is represented by a tab and the project's cells. This consumes the majority of the UI. These projects are contained within two separate panes, the **left pane** and the **right pane** respectively. The left pane **can** be open without the right pane, but the right pane **cannot** be open without the left pane. The project can be switched using the pane switcher button on the top of the project. At the top of the window will be the **topbar**. The **topbar** has two buttons on it, on the left this is a folder with an arrow. Clicking this button will open the **project explorer**. This is the menu to the left of your `Olive` session. The **project explorer** contains a (*green*) working directory, as well as any other saved user directories. Additionally, the project explorer holds a `home` directory if the current user is root.
# ui 1
The main window is called **session**. This contains two panes which will be filled with your projects. Projects are denoted by a tab and a window which contains cells. This tab can be double clicked for a range of different project options.
##### session
**Session** is the colloquial name for the main editor which comprises `Olive` -- this being the `Project` and `Cell` combination. Inside of **session** there are two panes, `pane_one` and `pane_two` respectively. These panes houses projects, their tabs being contained within a tab container above them. Clicking these tabs will yield project focus. Double clicking will add the tab's controls to the tab. These are, from left to right, `decollapse controls`, `new cell`, `switch pane`, `re-source`,`step evaluate`, and `close project`. Other than this, the hotkeys in [keybindings](https://github.com/ChifiSource/Olive.jl#keybindings) are the primary method `Olive` uses for input. Files are open from the **project explorer** and then edited inside of this session, before being saved via `ctrl` + `S` or the **inspector**. 
# ui 2

###### keybindings
# ui 3
Using cells is simple. By default, olive bindings use `ctrl` alone for window features, `ctrl` + `shift` to do things inside of `Cell`, and `shift` to work with the `Project`. Here is the keymap reflecting this:
- **window bindings**
  - `ctrl` + `C` **copy**
  - `ctrl` + `X` **cut**
  - `ctrl` + `V` **paste**
  - `ctrl` + `S` **save selected project**
  - `ctrl` + `z` **undo**
  - `ctrl` + `y` **redo**
  - `ctrl` + `F` **search** `TODO (but has default)`
  - `ctrl` + `O`  **open** `TODO `
  - `ctrl` + `N` **new** `TODO`
- **project bindings**
  - `ctrl` + `shift` + `C` **copy selected cell** `TODO`
  - `ctrl` + `shift` + `X` **cut selected cell** `TODO`
  - `ctrl` + `shift` + `V` **paste selected cell** `TODO`
  - `ctrl` + `Shift` + `S` **save project as**
  - `ctrl` + `shift` + `Delete` **delete selected cell**
  - `ctrl` + `shift` + `Enter` **new cell**
  - `ctrl` + `shift` + `↑` **move selected cell up**
  - `ctrl` + `shift` + `↓` **move selected cell down**
  - `ctrl` + `shift` + `O` **open** `TODO`

- **cell bindings**
  - `shift` + `Enter` **run cell**
  - `shift` + `↑` **shift focus up**
  - `shift` + `↑` **shift focus down**

These keybindings can be edited inside of the [settings](https://github.com/ChifiSource/Olive.jl#settings)
##### project explorer
# pexplore1

The **project explorer** is a crucial component to your `Olive` session because it manages the entire underlying filesystem running in your `Environment`. At the top of the **project explorer** will be the **inspector**. Once expanded, this section contains a file browser and previews of directories and projects in your `Environment` currently. Beneath this are the currently loaded directories. New directories can be added from the inspector by clicking the arrow next to the current working directory. Once added, we can open files from a given directory by double clicking.

# pexplore2

This will also be where other file operations take place, such as `save as` and `create file`. Below this will be your directories with **file cells** inside. On the top, there is a button to update the `Directory` and a button to `cd` to the directory. If this directory is your `olive` home root, this is added if the client is root, then there will also be a red run button, this button sources your `olive` home module. Whenever a new file is created, our directory will not be updated until we hit the refresh button. All file creation happens through the **inspector** inside of the **project explorer**. After creating the file in an added `Directory`, refresh the `Directory` to open the file in `Olive`. The **file cells** inside of your **directories** are the main way `Olive` interacts with files aside from the file browser in the **inspector**. In order to update our directory with new file changes, we will need to hit its refresh button.

# pexplore3

#### settings
The final component of the Olive UI we might want to familiarize ourselves with is the **settings** menu. Using [load extensions](#load-extensions), everything in `Olive` becomes a customizable setting. This menu is pretty straightforward, press the cog in the **top bar** to open or close the settings. Settings are organized into different menus by extension. These menus can be collapsed and decollapsed and contain editable settings for `Olive`. Note that in some cases, the page may need to be refreshed for new settings to be applied. There are more nuanced examples to this, as well. For example, changing your highlighter's style will yield no changes until a cell is typed into (or another cell is built.) Changing the key-bindings will only apply to newly built cells. 
#### parametric methodology
Olive uses **parameters** and **multiple dispatch** to load new features with the creation of method definitions. This technique is used comprehensively for `Olive`'s `Directory` and `Project` types, as well as [IPyCell's](https://github.com/ChifiSource/IPyCells.jl) `Cell`. This allows for a `Symbol` to be provided as a parameter. With this, `Olive` either reads the methods for its own functions or provides them as arguments to alter the nature of UI components. `Project`, `Directory`, and `Cell` are all **julia types**. These are translated into the `Olive` web-based UI using `build` methods. For example, the `creator` cell will list out all of the methods that `Olive` has defined for `build(::Toolips.AbstractConnection, ::Toolips.Modifier, ::Cell{<:Any}, ::Vector{Cell}, proj::Project{<:Any})`. In order to name such a cell, simply label the parameter in the `Cell` using a `Symbol`.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/creatorcell.png"></img>

This is the defining characteristic of `Olive`, and also how the base `Olive` features are built. This is why `Olive` is a **multiple dispatch notebook**, not just that but a **parametric** multiple dispatch notebook. As a result, a lot of what `Projects`, `Cells`, and `Directories` do is pretty open-ended -- anything is possible. This is also how extensions for `Olive` work. While this might not be that important to know if you are not extending `Olive` on your own, it is helpful to know this going into `Olive` and the rest of this `README`.
## extensions
`Olive` is not `Olive` without extensions. While the base `Olive` features are pretty cool, `Olive`'s base is intentionally built with a minimalist mindset. The idea is that **nothing is everyone's cup of tea**, so why use someone else's computer to load things for people who do not even want those things to begin with? With the `Olive` (and frankly, **Julia**) approach new features are added by adding new methods to existing `Olive` functions. With this, `Olive` becomes a notebook centralized on multiple dispatch! Olive extensions work off of `Olive`'s [parametric multiple dispatch methodology](#parametric-methodology) for loading extensions. A parameter is used to denote the existence of a new function, and each method of a given function becomes representative of that cell's action. 
#### installing extensions
As a result of this design choice, extensions are loaded by merely having such method definitions loaded into memory. As a result, installing extensions is incredibly easy. The first step is to add the package, for this example we will be adding `OliveDefaults`. This module provides some pretty awesome default things many users might want for an editor like this -- `AutoComplete`, `Themes`, `DocBrowser`, and some other useful things. We can add this package with `Pkg` in the REPL or through `Olive`. If you are root, the active `olive` home directory will be added to the **project explorer** initially. From here, we could either use a separate file or use our `olive.jl` home file. Inside of this file, we may create a new `pkgrepl` cell with `ctrl` + `shift` + `Enter` then `]`. 


<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/addolivedefaults.png"></img>
</div>

This works like a normal Julia REPL. This may also be done through the julia REPL. After this package is added, we need to add `using` to our source file. In some cases, an `Olive` extension might consist of multiple modules. This is the case with `OliveDefaults`, which means that we can grab each extension individually as we want it by merely using imports... For example, I only want the documentation browser:
```julia
using OliveDefaults: DocBrowser
```
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/addeddbrowser.png"></img>

Now we simply save this. The `olive` directory has a run button that is used to resource the module. Press this button, if you do not get an error message (which means there is an error in your code, or with `Olive` forming a module with your code) you have installed the extension. There should be an `Olive` notification that drops down and denotes the success of the operation.

Extensions for `Olive` can be as small as an icon, or as large as a new programming language loaded from a new file format. `Olive` can edit anything however it wants to with the only limitation really being [Toolips](https://github.com/ChifiSource/Toolips.jl) and the web itself -- it's **great!**
#### common extensions`
**note** that a lot of extensions for `Olive` are waiting on this initial `0.0.9` (if this is on `master` it is here) release to be released. That being said, there might not be that much done yet depending on when this is being read. There is a full list of [chifi](https:github.com/ChifiSource)-made extensions [here](https://github.com/ChifiSource#olive)
#### creating extensions
As has been touched on quite extensively in this `README`, `Olive` loads extensions by checking for new methods of its functions. There are several different types of extensions that can be created for `Olive`, so let's get familiar with the what each function is for. The most essential function on this front is the `build` function. Though `Olive` is written in one language with both frontend and backend under the same hood, it is still written with a frontend and a backend. The only thing that is different on that front is that the translation between the two is done seemlessly through [Toolips](https://github.com/ChifiSource/Toolips.jl)' API. This `build` function is used to translate the Julia objects from the backend into GUI interface components. In fact we may view all of the functions for our cells by calling `methods` on it.
```julia
julia> using Olive; import Olive: build
🩷
julia> methods(Olive.build)
# 26 methods for generic function "build" from Olive:
  [1] build(c::Toolips.AbstractConnection, cm::ComponentModifier, p::Olive.Project)
     @ ~/dev/packages/olive/Olive.jl/src/Core.jl:507
  [2] build(c::Connection, dir::Olive.Directory, m::Module)
     @ ~/dev/packages/olive/Olive.jl/src/Core.jl:360
  [3] build(c::Connection, cell::Cell{:ipynb}, d::Olive.Directory)
     @ ~/dev/packages/olive/Olive.jl/src/Cells.jl:368
  [4] build(c::Connection, cell::Cell{:setup})
     @ ~/dev/packages/olive/Olive.jl/src/Cells.jl:1716
  [5] build(c::Connection, cell::Cell{:dir}, d::Olive.Directory)
     @ ~/dev/packages/olive/Olive.jl/src/Cells.jl:334
  [6] build(c::Connection, cm::ComponentModifier, cell::Cell{:markdown}, proj::Olive.Project)
     @ ~/dev/packages/olive/Olive.jl/src/Cells.jl:930
...
 [18] build(c::Connection, cm::ComponentModifier, cell::Cell, proj::Olive.Project)
     @ ~/dev/packages/olive/Olive.jl/src/Cells.jl:506
 [19] build(c::Connection, om::OliveModifier, oe::OliveExtension{:highlightstyler})
     @ ~/dev/packages/olive/Olive.jl/src/Core.jl:220
 [20] build(c::Connection, om::OliveModifier, oe::OliveExtension{:creatorkeys})
     @ ~/dev/packages/olive/Olive.jl/src/Core.jl:157
 [21] build(c::Connection, om::OliveModifier, oe::OliveExtension{:keybinds})
     @ ~/dev/packages/olive/Olive.jl/src/Core.jl:99
```
Here we begin to see the different dispatches and what they do. The first method listed above is the build function for `Project{<:Any}`. This creates the regular projects that we are used to seeing inside of `Olive` that we are used to seeing, with the tab on top. The function responsible for creating these tabs is actually `build_tab`, just for fun let's look at the methods...

#### documentation
With the upcoming release of `0.1.0`, [chifi](https://github.com/ChifiSource) will also be releasing [OliveCreator](https://github.com/ChifiSource/OliveCreator.jl), this will be a website which hosts `Olive`. Along with this there will be interactive examples, notebooks, and most importantly -- documentation (for all chifi stuff, really awesome olive-based documentation). The problem is that this still requires a lot of work to `Olive` and its sister projects. In its current state the two best tools to learn `Olive` are
- this `README`
- or the [OliveDefaults](https://github.com/ChifiSource/OliveDefaults.jl) documentation browser.

  I would recommend the latter. For the most part, this documentation is only needed if you are writing extensions for `Olive`. I could see knowledge of how the thing works being beneficial in these early pre-releases, however. In other instances, this `README` should suffice.
### deploying olive
Olive has a goal to be very deployable, but it is recommended to wait for `0.1.0` to deploy `Olive`. It is also recommended to add `OliveSession`; this provides a number of great features for multiple users, including better directory management, login screens, and sharable sessions.
   - [`0.0.9`deployment status](#status)
   - [creating an olive server](#creating-a-server)
   - [OliveSession](#session)
#### status
In its current form, `Olive` would certainly need some things to be deployable. The main concern on this front is that the Julia session is active. There are simple ways to get around this -- removing portions of `Base` and `Main` from the scope of the module they have access to. As of the release of `0.0.9`, [OliveSession](#olive-session) has not yet been completed, so this type of secure module is not really supported yet. That being said, `Olive` will be deployable, and for anyone wanting to create a server, the most optimal approach to doing so is probably using `OliveSession`. The project is certainly planned to fill this application, though -- so deployment will be very feasible in the near future. However, the goal is for this package to focus on the single-user experience while `OliveSession` focuses on the multi-user experience.
#### creating a server
Unless you are only sharing your `olive` with a limited number of people, you probably do not want this server to load from your home `olive`. That being said, it is really easy to create an `olive` at any path on your machine using the `path` key-word argument on `start`.
```julia
using Olive; Olive.start(path = ".")
```
This will give us an `olive` home directory inside of the provided URI. Inside of this directory, we can begin developing our module. From there, it is simply extending your `Olive` and manipulating it into being server-ready. Alternatively, `start` does not have to be used and you can load `Olive` by manually creating the olive server yourself. This is not entirely recommended, especially not for new users, primarily because there is no documentation on doing this. However, there is more information and a small write-up on this in [olive servers](#olive-servers)
#### olive servers
The `Olive.start` function actually does not return `Nothing`, it returns a `Toolips.WebServer`.
```julia
help?> Toolips.WebServer
  WebServer <: ToolipsServer
  ––––––––––––––––––––––––––––

    •  host::String

    •  routes::Dict

    •  extensions::Dict

    •  server::Any

    •  add::Function

    •  remove::Function

    •  start::Function

  A web-server is given as a return from a ServerTemplate whenever ServerTemplate.start() is ran. It can be rerouted with route! and indexed similarly to
  the Connection, with Symbols representing extensions and Strings representing routes.

  example
  ⋅⋅⋅⋅⋅⋅⋅⋅⋅

  st = ServerTemplate()
  ws = st.start()
  routes(ws)
  ...
  extensions(ws)
  ...
  route!(ws, "/") do c::Connection
      write!(c, "hello")
  end

```
This is an introspectable server type that holds **all** of the data for your `Olive` session. From your Julia REPL, this can easily be introspected by accessing the extensions and routes.
```julia
oliveserver = Olive.start()

oliveserver[:OliveCore]
```
This also means that the routes of an `Olive` server could be changed, or rerouted in anyway -- really. All of the projects are stored within the `OliveCore.open` field, a `Vector{Olive.Environment}`. Our client data is stored inside of `OliveCore.client_data` and open projects are in `OliveCore.open`.
#### olive session
A crucial project you are probably going to want to be aware of if you are planning to deploy `Olive` is [OliveSession](https://github.com/ChifiSource/OliveSession.jl). This is an `Olive` extension provided to make `Olive` far more deployable and multi-user friendly. This project is still in the works, it is not recommended to deploy this current state of `Olive`. The modules need to limit access to `Base` functions, something base `Olive` is not intended to offer. This build of `Olive` is intended to primarily be focused on the single-computer experience, while still making `Olive` apply to that type of context in deployment and customized.
### contributing
Olive is a complicated project, and there is a lot going on from merely Olive itself to the entire ecosystem that supports olive. That being said, community support is essential to improving this project. You may contribute to Olive by
- simply using olive 🫒
- creating extensions for olive 🚀
- sharing olive with your friends! 🩷
- starring olive ⭐
- forking olive [contributing guidelines](#guidelines)
- submitting issues [issue guidelines](#issue-guidelines)
- participating in the community 🔴🟢🟣

I thank you for all of your help with our project, or just for considering contributing! I want to stress further that we are not picky -- allowing us all to express ourselves in different ways is part of the key methodology behind the entire [chifi](https://github.com/ChifiSource) ecosystem. Feel free to contribute, we would **love** to see your art! Issues marked with `good first issue` might be a great place to start!
#### guidelines
When submitting issues or pull-requests for Olive, it is important to make sure of a few things. We are not super strict, but making sure of these few things will be helpful for maintainers!
1. You have replicated the issue on `Olive#Unstable`
2. The issue does not currently exist... or does not have a planned implementation different to your own. In these cases, please collaborate on the issue, express your idea and we will select the best choice.
3. **Pull Request TO UNSTABLE**
4. This is an issue with Olive, not a dependency; if there is a problem with highlighting, please report that issue to [ToolipsMarkdown](https://github.com/ChifiSource/ToolipsMarkdown.jl). If there is an issue with Cell reading/writing, report that issue to [IPyCells](https://github.com/ChifiSource/IPyCells.jl)
5. Be **specific** about your issue -- if you are experiencing multiple issues, open multiple issues. It is better to have a high quantity of issues that specifically describe things than a low quantity of issues that describe multiple things.
6. If you have a new issue, **open a new issue**. It is not best to comment your issue under an unrelated issue; even a case where you are experiencing that issue, if you want to mention **another issue**, open a **new issue**.
7. Questions are fine, but **not** questions answered inside of this `README`.
### tech stack
I appreciate those who are interested to take some time to look into the tech-stack used to create this project. I created a lot of these, and it took a lot of time.

**toolips packages**
- [Toolips](https://github.com/ChifiSource/Toolips.jl) - Base web-development framework.
- [ToolipsSession](https://github.com/ChifiSource/ToolipsSession.jl) - Fullstack callbacks.
- [ToolipsMarkdown](https://github.com/ChifiSource/ToolipsMarkdown.jl) - Markdown interpolation, syntax highlighting.
- [ToolipsDefaults](https://github.com/ChifiSource/ToolipsDefaults.jl) - Default Components.
- [ToolipsBase64](https://github.com/ChifiSource/ToolipsBase64.jl) - Image types into Components -- for Olive display.

**other packages**
- [IPyCells](https://github.com/ChifiSource/IPyCells.jl) Provides the parametric cell structures for the back-end, as well as the Julia/IPython readers/writers
- [Pkg]() Used to manage Julia dependencies and virtual environments.
- [TOML]() Used to manage environment information, save settings, and read TOML into cells.
