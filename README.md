<div align = "center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/0.1/olivesave.png" width="250">

 [![version](https://juliahub.com/docs/General/Olive/stable/version.svg)](https://juliahub.com/ui/Packages/General/Olive) **|** [![deps](https://juliahub.com/docs/General/Olive/stable/deps.svg)](https://juliahub.com/ui/Packages/General/Olive?t=2) 

🩷 [documentation](https://chifidocs.com/olive/Olive) 🩷

</div>

Welcome to olive! Olive is a **pure julia**, **parametric** notebook editor built on the back of Julia's **multiple dispatch**. `Olive` is able to load new features by loading new methods for its functions.
- regular **julia modules** (instead of kernels)
- **extensible** *parametric* multiple-dispatch design philosophy
- **tabbing** notebooks
- **customizable** *everything* (styles, key-bindings, syntax highlighting, environment ...)
- reading of pluto, julia, olive, **and** ipython notebooks -- saving to `Olive`, raw Julia, and IPython notebooks.
- a full **file-browser**
- **deployable**
- and a **two-pane** design.

###### map
- [get started](#get-started)
   - [getting olive](#getting-olive)
   - [documentation](#docs)
   - [explanation](#explanation)
- [user interface](#user-interface)
   - [session](#session)
   - [keybindings](#keybindings)
   - [project explorer](#project-explorer)
   - [settings](#settings)
- [extensions](#extensions)
   - [installing extensions](#installing-extensions)
- [deploying olive](#deploying-olive)
   - [creating an olive server](#creating-a-server)
- [contributing](#contributing)
   - [guidelines](#guidelines)
   - [tech stack](#tech-stack)
---
### get started
- this overview corresponds to `Olive` **0.1** (beta)

###### getting olive
Getting started with Olive starts by installing this package via Pkg. **Press ] to enter your pkg REPL**, or use the `Pkg.add` `Function` to add `Olive`.
```julia
julia> using Pkg; Pkg.add("Olive")
```
```julia
julia> ]

pkg> add Olive
```
Alternatively, you could also grab `Unstable`, this will give you the latest developments, but some features might be intermittently broken.
```julia
julia> ]
pkg> add Olive#Unstable
```
```julia
using Olive; Olive.start()
```
To change the IP or port, simply provide an `IP4` using **the colon syntax**:
```julia
using Olive; Olive.start("127.0.0.1":9987)
# start(IP::Toolips.IP4 = "127.0.0.1":8000; path::String = replace(homedir(), "\\" => "/"), wd::String = pwd())
```
The following arguments will change the behavior of this start:
- `path`**::String** = `homedirec()` -- The path
- `wd`**::String** = `pwd()`
If there is no `olive` setup inside of `path`, `start` will ask us for a root name to create a new `olive` home at that path. Providing `path` allows us to setup multiple `Olive` environments across our filesystem.
```julia
IP = "127.0.0.1" # same as default (see ?(Olive.start))
PORT = 8000
startpath = "/home/dev/notebooks"
using Olive

Olive.start(IP, PORT, path = startpath)
```
#### docs
This README includes a brief overview of `Olive`'s basic usage; for more information `Olive` ensures that all doc-strings are easily browse-able. All exports are listed in the doc-string for `Olive`. Alteranatively, you could `push!` `Olive.Toolips.make_docroute(Olive)` to `Olive.olive_routes` or use the `OliveDocBrowser` extension to browse documentation more thoroughly. [chifi](https://github.com/ChifiSource) is also working on a new documentation website, which will eventually have `Olive` documentation here:
- [chifidocs](https://chifidocs.com/olive/olive)
---
#### explanation
Olive uses **parameters** and **multiple dispatch** to load new features with the creation of method definitions. This technique is used comprehensively for `Olive`'s `Directory` and `Project` types, as well as [IPyCell's](https://github.com/ChifiSource/IPyCells.jl) `Cell`. This allows for a `Symbol` to be provided as a parameter. With this, `Olive` either reads the methods for its own functions or provides them as arguments to alter the nature of UI components. `Project`, `Directory`, and `Cell` are all **julia types**. These are translated into the `Olive` web-based UI using `build` methods. For example, the `creator` cell will list out all of the methods that `Olive` has defined for `build(::Toolips.AbstractConnection, ::Toolips.Modifier, ::Cell{<:Any}, ::Vector{Cell}, proj::Project{<:Any})`. In order to name such a cell, simply label the parameter in the `Cell` using a `Symbol`.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/creatorcell.png"></img>

This is the defining characteristic of `Olive`, and also how the base `Olive` features are built. This is why `Olive` is a **multiple dispatch notebook**, not just that but a **parametric** multiple dispatch notebook. As a result, a lot of what `Projects`, `Cells`, and `Directories` do is pretty open-ended -- anything is possible. This is also how extensions for `Olive` work. While this might not be that important to know if you are not extending `Olive` on your own, it is helpful to know this going into `Olive` and the rest of this `README`.
### user interface
Olive's user-interface is relatively straightforward. When starting olive, you will be greeted with a `get started` `Project`. A `Project` in `Olive` is represented by a tab and the project's cells. This consumes the majority of the UI. These projects are contained within two separate panes, the **left pane** and the **right pane** respectively. The left pane **can** be open without the right pane, but the right pane **cannot** be open without the left pane. The project can be switched using the pane switcher button on the top of the project. At the top of the window will be the **topbar**. The **topbar** has two buttons on it, on the left this is a folder with an arrow. Clicking this button will open the **project explorer**. This is the menu to the left of your `Olive` session. The **project explorer** contains a (*green*) working directory, as well as any other saved user directories. Additionally, the project explorer holds a `home` directory if the current user is root.
<div align="center">
   <img src="https://github.com/ChifiSource/image_dump/blob/main/olive/doc92sc/ui1.png"></img>
</div>

The main window is called **session**. This contains two panes which will be filled with your projects. Projects are denoted by a tab and a window which contains cells. This tab can be double clicked for a range of different project options.
#### session
**session** is the colloquial name for the central editor which comprises `Olive` -- this being the `Project` and `Cell` combination. Inside of **session** there are two panes, `pane_one` and `pane_two` respectively. These panes houses projects, their tabs being contained within a tab container above them. Clicking these tabs will yield project focus. Double clicking will add the tab's controls to the tab. These are, from left to right, `decollapse controls`, `new cell`, `switch pane`, `re-source`,`step evaluate`, and `close project`. Other than this, the hotkeys in [keybindings](https://github.com/ChifiSource/Olive.jl#keybindings) are the primary method `Olive` uses for input. Files are open from the **project explorer** and then edited inside of this session, before being saved. 

<div align="center">
   <img src="https://github.com/ChifiSource/image_dump/blob/main/olive/doc92sc/ui2.png"></img>
</div>


###### keybindings
Using cells is simple. By default, olive bindings use `ctrl` alone for window features, `ctrl` + `shift` to do things inside of `Cell`, and `shift` to work with the `Project`. Here is the keymap reflecting this:
- **window bindings**
  - `ctrl` + `S` **save selected project**
  - `ctrl` + `z` cell **undo**
  - `ctrl` + `y` cell **redo**
  - `ctrl` `shift` + `E` **explorer**
- **cell bindings**
  - `ctrl` + `Shift` + `S` **save project as**
  - `ctrl` + `shift` + `Delete` **delete selected cell**
  - `ctrl` + `shift` + `Enter` **new cell**
  - `ctrl` + `shift` + `↑` **move cell up**
  - `ctrl` + `shift` + `↓` **move cell down**
  - `ctrl` + `Shift` + `F` cell **search** 
  - `ctrl` + `Shift` + `O`  cell **open** (open-ended binding, used for extensions -- doesn't do anything for base `Olive` cells)
  - `ctrl` + `Shift` + `A` cell **select**
  - `ctrl` + `C` cell **copy**
  - `ctrl` + `V` cell **paste**
- **cell text bindings**
  - `shift` + `Enter` **run cell**
  - `shift` + `↑` **shift focus up**
  - `shift` + `↑` **shift focus down**
  - `ctrl` + `C` **cell undo**
  - `ctrl` + `Y` **cell redo**
  - `ctrl` + `C` **cell copy**
  - `ctrl` + `V` **cell paste**
  - `ctrl` + `X` **cell cut**

These keybindings can be edited inside of the [settings](https://github.com/ChifiSource/Olive.jl#settings)
#### settings
The final component of the Olive UI we might want to familiarize ourselves with is the **settings** menu. Using [load extensions](#load-extensions), everything in `Olive` becomes a customizable setting. This menu is pretty straightforward, press the cog in the **top bar** to open or close the settings. Settings are organized into different menus by extension. These menus can be collapsed and decollapsed and contain editable settings for `Olive`. Note that in some cases, the page may need to be refreshed for new settings to be applied. There are more nuanced examples to this, as well. For example, changing your highlighter's style will yield no changes until a cell is typed into (or another cell is built.) Changing the key-bindings will only apply to newly built cells. 

<div align="center">
   <img src="https://github.com/ChifiSource/image_dump/blob/main/olive/doc92sc/ui3.png"></img>
</div>

#### project explorer

<div align="center">
   <img src="https://github.com/ChifiSource/image_dump/blob/main/olive/doc92sc/pexplore1.png"></img>
</div>


The **project explorer** is a crucial component to your `Olive` session because it manages the entire underlying filesystem running in your `Environment`. Directories, like cells and projects, are parametric types -- so `Olive` has different directory types. Base `Olive` comes with the following directory types:
- `home` (**pink**) is the home directory used to change `Olive`, which is added only for root.
- `pwd` (**green**) is the current `Environment` working directory.
- `{<:Any}` (**black**) is the catchall directory, in practice this usually represents an unsaved directory in `Olive`.
- `saved` (**purple**) is a saved directory.

New directories and files are created through the `pwd` directory, where all file operations take place. This directory is essentially our file browser. The bookmark indicator on directories in this menu will add a directory to your saved directories, which may then be permanently saved using the save button.

<div align="center">
   <img src="https://github.com/ChifiSource/image_dump/blob/main/olive/doc92sc/pexplore2.png"></img>
</div>

Clicking the `+` icon next to the `pwd` directory will create a new project, file, or directory from a selected template. Clicking the `+` next to the `home` directory will add a new `Olive` extension by name or by URL.

<div align="center">
   <img src="https://github.com/ChifiSource/image_dump/blob/main/olive/doc92sc/pexplore3.png"></img>
</div>

### extensions
`Olive` is not `Olive` without extensions. While the base `Olive` features are pretty cool, `Olive`'s base is intentionally built with a minimalist mindset. The idea is that **nothing is everyone's cup of tea**, so why use someone else's computer to load things for people who do not even want those things to begin with? With the `Olive` (and frankly, **Julia**) approach new features are added by adding new methods to existing `Olive` functions. With this, `Olive` becomes a notebook centralized on multiple dispatch! Olive extensions work off of `Olive`'s [parametric multiple dispatch methodology](#parametric-methodology) for loading extensions. A parameter is used to denote the existence of a new function, and each method of a given function becomes representative of that cell's action. 
#### installing extensions

<div align="center">
   <img src="https://github.com/ChifiSource/image_dump/blob/main/olive/doc92sc/ext.png"></img>
</div>

Extensions can be added to `Olive` by first clicking the `+` button by your `home` directory in `Olive`, then typing the extension's URL into the name box before pressing *add*. This will add the package to your Pkg environment, and add a new `using` entry for the package to your `olive.jl` home file. This could also be done manually. In `0.1.5`**+**, to use extensions with *headless* `Olive` simply load them before loading `Olive`.
### deploying olive
   - [`beta` deployment status](#status)
   - [creating an olive server](#creating-a-server)
#### status
In its current form, `Olive` *still* needs a few more small things for deployment. Of course, all of this could be added in your own server using extensions, but eventually the base will better support deployment. It is definitely possible to deploy `Olive` publicly in its current state, but it isn't recommended and would likely require some pretty significant modifications to `Olive`.
#### creating a server
`Olive` now features the `create` bindings, for creating both a new `Olive`-based server and an `Olive` extension from a template.
```julia
create(t::Type{Toolips.ServerTemplate}, name::String)
create(t::Type{OliveExtension}, name::String)
```
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
- [ToolipsServables](https://github.com/ChifiSource/ToolipsServables.jl) - Templating framework for web-development.
- [Toolips](https://github.com/ChifiSource/Toolips.jl) - Base web-development framework.
- [ToolipsSession](https://github.com/ChifiSource/ToolipsSession.jl) - Fullstack callbacks for the `Toolips` framework.

**other packages**
- [OliveHighlighters](https://github.com/OliveHighlighters.jl) Provides `ToolipsServables`-based syntax highlighting.
- [IPyCells](https://github.com/ChifiSource/IPyCells.jl) Provides the parametric cell structures for the back-end, as well as the Julia/IPython readers/writers
- [Pkg](https://github.com/JuliaLang/Pkg.jl) Used to manage Julia dependencies and virtual environments.
- [TOML](https://github.com/JuliaLang/TOML.jl) Used to manage environment information, save settings, and read TOML into cells.
