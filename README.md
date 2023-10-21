<div align = "center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/newoliveover.png" width="350">
<h6>🩷| 0.0.9 |🩷</h6>
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
- edit **any** file
<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/Screenshot%20from%202023-08-15%2006-44-12.png" width = "300"></img><img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/Screenshot%20from%202023-08-11%2015-45-25.png" width = "300"></img>
</div>
<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/Screenshot%20from%202023-08-11%2015-39-39.png" width = "300"></img>
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/cccccsa.png" width = "300"></img>
</div>

Keep in mind this version of Olive (while functional) is still a **work in progress** build. Thank you for reporting bugs to the issues page!

###### map
- [get started](#get-started)
   - [setup](#setup)
   - [documentation](#documentation)
   - [user interface](#user-interface)
     - [topbar](#topbar)
     - [session](#session)
     - [project explorer](#project-explorer)
     - [keybindings](#keybindings)
     - [settings](#settings)
   - [methodology](#parametric-methodology)
- [extensions](#extensions)
   - [installing extensions](#installing-extensions)
   - [common extensions](#common-extensions)
     - [functionality extensions](#functionality-extensions)
     - [language extensions](#language-extensions)
   - [creating extensions](#creating-extensions)
     - [Toolips](#toolips-basics)
     - [load extensions](#load-extensions)
     - [code cell extensions](#code-cell-extensions)
     - [directory extensions](#directory-extensions)
     - [cell extensions](#cell-extensions)
     - [project extensions](#project-extensions)
  - [extensible function reference](#function-reference)
     - [code cell methods]()
     - [load methods]()
     - [cell methods]()
     - [project methods]()
     - [directory]()
  - [UI reference](#ui-reference)
  - [extension examples](#examples)
- [deploying olive](#deploying-olive)
   - [`0.0.9`deployment status](#status)
   - [creating an olive server](#creating-a-server)
   - [olive servers](#olive-servers)
   - [OliveSession](#olive-session)
- [contributing](#contributing)
   - [guidelines](#guidelines)
   - [known issues](#known-issues)
   - [roadmap](#roadmap)
   - [tech stack](#tech-stack)
---
### get started
<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/sessionui.png"></img>
</div>

Getting started with Olive starts by installing this package via Pkg. **Press ] to enter your pkg REPL**.
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
Next, use `Olive.start()`:
```julia
using Olive; Olive.start()
```
This should provide you with a link to get started with Olive! 

To change the IP or PORT, use the positional arguments `IP` (1, `String`) and `PORT` (2, `Int64`). There are also the key-word arguments
- `path`**::String** = `homedirec()`
- `free`**::Bool** = `false`
- `devmode`**::Bool** = `false`

```julia
IP = "127.0.0.1" # same as default (see ?(Olive.start))
PORT = 8000
startpath = "/home/dev/notebooks"
using Olive

Olive.start(IP, PORT, devmode = false, path = startpath)
```
Providing `devmode` as `true` will start `Olive` in developer mode. This just makes it easier to test things when working on `Olive` itself. More will eventually come to `devmode`, as of right now this option will simply **disable authentication**. Providing a `path` will search for an `olive` home at the provided directory. If there is no `olive` directory, this will start the `setup` inside of this directory. This can be useful for developing extensions, deploying olive, or having multiple profiles with different sets of extensions. Providing `free` as `true` will start the `Olive` server in **global mode**. This means that instead of using an `olive` home file, `olive` will use your default Julia environment.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/termsc.png"></img>

The `Olive.start` method also returns a `Toolips.WebServer`, this being the server that contains your entire `Olive` session. This provides an easy avenue to introspect and work with `Olive`, especially if you know what you are doing. There is more information on working with this server type in the [olive servers](#olive-servers) portion of this `README`.
##### setup

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/setupsc.png"></img>


When you start `Olive` for the first time, you will be greeted with a new link to your olive setup. This screen also holds a directory selector. The currently selected directory is indicated by the label at the top. In this directory, a new Julia project will be created. This will be your `olive` home environment inside of this directory. This includes the folder `olive`, the `Project.toml environment and its `Manifest.toml` counter-part, the contained `src` directory and correstponding source file `src/olive.jl`. After selecting a directory, the setup will then move to a second screen.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/setup2sc.png"></img>

This portion of the setup will ask for a name and if you want to add [OliveDefaults](https://github.com/ChifiSource/OliveDefaults.jl). This package provides `Olive` with some default extensions that many developers would likely prefer. This includes
- The `Styler` extension.
- The `DocBrowser` extension.
- The `AutoComplete` extension
- And the `Themes` extension.

These extensions can be loaded individually; the setup will only add `OliveDefaults` with `Pkg`. The name is also pretty important, though certainly not necessary. Any name will work, including the default `root`. After pressing continue, a loadbar will appear and `Olive` will begin setting up your `olive` environment. After this loadbar finishes (so long as the setup completes successfully), you will be redirected to a new `Olive` session!
#### documentation
With the upcoming release of `0.1.0`, [chifi](https://github.com/ChifiSource) will also be releasing [OliveCreator](https://github.com/ChifiSource/OliveCreator.jl), this will be a website which hosts `Olive`. Along with this there will be interactive examples, notebooks, and most importantly -- documentation (for all chifi stuff, really awesome olive-based documentation). The problem is that this still requires a lot of work to `Olive` and its sister projects. In its current state the two best tools to learn `Olive` are
- this `README`
- or the [OliveDefaults](https://github.com/ChifiSource/OliveDefaults.jl) documentation browser.

  I would recommend the latter. For the most part, this documentation is only needed if you are writing extensions for `Olive`. I could see knowledge of how the thing works being beneficial in these early pre-releases, however. In other instances, this `README` should suffice.
#### user interface
Olive's user-interface is relatively straightforward. When starting olive, you will be greeted with a `get started` `Project`. A `Project` in `Olive` is represented by a tab and the project's cells. This consumes the majority of the UI. These projects are contained within two separate panes, the **left pane** and the **right pane** respectively. The left pane **can** be open without the right pane, but the right pane **cannot** be open without the left pane. The project can be switched using the pane switcher button on the top of the project. At the top of the window will be the **topbar**. The **topbar** has two buttons on it, on the left this is a folder with an arrow. Clicking this button will open the **project explorer**. This is the menu to the left of your `Olive` session.  At the top of this menu, there is the **inspector**, and below this is where every `Directory` is placed. When a `Project` is added to the session, it will also add a preview into the inspector. In the top right there is a cog, this button will reveal the **settings menu**. All settings in `Olive` are added via extensions, so these will be your extension settings, such as key-bindings and syntax highlighting. Adding more extensions will often add new settings to this menu.
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/uiui.png"></img>

The main window is called **session**. This contains two panes which will be filled with your projects. Projects are denoted by a tab and a window and contain cells.
##### topbar
The **top bar** is responsible for holding extension controls, settings, and the **project explorer**. Inside of the **settings** there will be an editable configuration for all of the loaded `Olive` extensions. Inside of the **project explorer** is access to file operations and the **inspector**. The top bar is composed of three main sections: `leftmenu`, `rightmenu` and `centermenu`. These sections are where some types of extensions may appear. With this, the **topbar** becomes the main control for `Olive`. From here we access both files to edit and our `Olive` settings. The primary usage of this `Component` is opening different menus within `Olive`.
##### session
**Session** is the colloquial name for the main editor which comprises `Olive` -- this being the `Project` and `Cell` combination. Inside of **session** there are two panes, `pane_one` and `pane_two` respectively. These panes houses projects, their tabs being contained within a tab container above them. Clicking these tabs will yield project focus. Double clicking will add the tab's controls to the tab. These are, from left to right, `decollapse controls`, `new cell`, `switch pane`, `re-source`,`step evaluate`, and `close project`. Other than this, the hotkeys in [keybindings](https://github.com/ChifiSource/Olive.jl#keybindings) are the primary method `Olive` uses for input. Files are open from the **project explorer** and then edited inside of this session, before being saved via `ctrl` + `S` or the **inspector**. 
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/sessionui.png"></img>
##### project explorer
<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/pexplorer.png"></img>
</div>

The **project explorer** is a crucial component to your `Olive` session because it manages the entire underlying filesystem running in your `Environment`. At the top of the **project explorer** will be the **inspector**. Once expanded, this section contains a file browser and previews of directories and projects in your `Environment` currently. Beneath this are the currently loaded directories. New directories can be added from the inspector by clicking the arrow next to the current working directory. Once added, we can open files from a given directory by double clicking.

<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/inspectorui.png" width="300"></img>
</div>

This will also be where other file operations take place, such as `save as` and `create file`. Below this will be your directories with **file cells** inside. On the top, there is a button to update the `Directory` and a button to `cd` to the directory. If this directory is your `olive` home root, this is added if the client is root, then there will also be a red run button, this button sources your `olive` home module. Whenever a new file is created, our directory will not be updated until we hit the refresh button. All file creation happens through the **inspector** inside of the **project explorer**. After creating the file in an added `Directory`, refresh the `Directory` to open the file in `Olive`. The **file cells** inside of your **directories** are the main way `Olive` interacts with files aside from the file browser in the **inspector**. In order to update our directory with new file changes, we will need to hit its refresh button.

<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/scdirs.png" width="300"></img>
</div>

###### keybindings
<img 
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
#### settings
The final component of the Olive UI we might want to familiarize ourselves with is the **settings** menu. Using [load extensions](#load-extensions), everything in `Olive` becomes a customizable setting. This menu is pretty straightforward, press the cog in the **top bar** to open or close the settings. Settings are organized into different menus by extension. These menus can be collapsed and decollapsed and contain editable settings for `Olive`. Note that in some cases, the page may need to be refreshed for new settings to be applied. There are more nuanced examples to this, as well. For example, changing your highlighter's style will yield no changes until a cell is typed into (or another cell is built.) Changing the key-bindings will only apply to newly built cells. 
#### parametric methodology
Olive uses **parameters** and **multiple dispatch** to load new features with the creation of method definitions. This technique is used comprehensively for `Olive`'s `Directory` and `Project` types, as well as [IPyCell's](https://github.com/ChifiSource/IPyCells.jl) `Cell`. This allows for a `Symbol` to be provided as a parameter. With this, `Olive` either reads the methods for its own functions or provides them as arguments to alter the nature of UI components. `Project`, `Directory`, and `Cell` are all **julia types**. These are translated into the `Olive` web-based UI using `build` methods. For example, the `creator` cell will list out all of the methods that `Olive` has defined for `build(::Toolips.AbstractConnection, ::Toolips.Modifier, ::Cell{<:Any}, ::Vector{Cell}, proj::Project{<:Any})`. In order to name such a cell, simply label the parameter in the `Cell` using a `Symbol`.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/creatorcell.png"></img>

This is the defining characteristic of `Olive`, and also how the base `Olive` features are built. This is why `Olive` is a **multiple dispatch notebook**, not just that but a **parametric** multiple dispatch notebook. As a result, a lot of what `Projects`, `Cells`, and `Directories` do is pretty open-ended -- anything is possible. This is also how extensions for `Olive` work. While this might not be that important to know if you are not extending `Olive` on your own, it is helpful to know this going into `Olive` and the rest of this `README`.
### extensions
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

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/Screenshot%20from%202023-08-15%2007-25-26.png"></img>

```julia
julia> methods(Olive.build_tab)
# 3 methods for generic function "build_tab" from Olive:
 [1] build_tab(c::Connection, p::Olive.Project{:include}; hidden)
     @ ~/dev/packages/olive/Olive.jl/src/UI.jl:702
 [2] build_tab(c::Connection, p::Olive.Project{:module}; hidden)
     @ ~/dev/packages/olive/Olive.jl/src/UI.jl:733
 [3] build_tab(c::Connection, p::Olive.Project; hidden)
     @ ~/dev/packages/olive/Olive.jl/src/UI.jl:763
```

Below this, # 2 is the `Directory`, then is the `ipynb` file cell. Notice how the parameter is dispatched to `ipynb`, this symbolic representation denotes the existence of this cell. We also see that yes -- even `Olive`'s key-bindings are loaded in as an extension using this method. The `build` function is one that transcends across most `Olive` types, not every function is this complicated or has this many methods. There are several different types of extensions we might want to write...
- load extensions
- `code` cell extensions
- `Directory` extensions
- `Cell` extensions
- `Project` extensions

Creating extensions will require two prerequisites from the creator. Firstly, there will need to be knowledge of these dispatches and what they do and secondly familiarity with toolips. Toolips is the web-development framework used to build `Olive`.
###### toolips
The most essential package to understand in order to work with `Olive` is [toolips](https://github.com/ChifiSouce/Toolips.jl). This is the web-development used to turn `Olive's` backend into a user-friendly UI. In this `README`, we will go through a very basic overview of how to use `Toolips`. Here are some other links to help get familiar with different aspects of toolips:

- [Toolips tutorial videos](https://www.youtube.com/watch?v=_VqSM-mHBes&list=PLCXbkShHt01s3kd2ZA62KoKhWBFfKXNTd)
###### development environment
There is no one way to develop extensions for `Olive`. Extensions can be developed both inside of `Olive` and outside of `Olive`. The root user will be provided with the `olive` home directory, which has a red run button on it. Clicking this will load the extensions contained in `olive.jl`. The best workflow for this is probably to create a new `olive` home using the `path` key-word argument. There are usage instructions for this argument in [get started](#get-started). After which till generate a new `Olive` directory. This is helpful to not break or alter your home `olive` while developing extensions.
```julia
using Olive; Olive.start(path = "~/dev/olive_extensions")
```
Within this new `Olive`, we can create our new extension file, and then include it from our home file. This is a much safer way to develop and work with this home extensions file; reserving it for `using` and `includes` rather than coding directly into the `olive.jl` home file. An easy way to do this is to open `olive.jl` in `Olive`, create your file and use an `include` cell to include it. This will present the best possible workflow for developing an `Olive` extension -- as now you can write something, press the play button and refresh -- it is that simple.

Alternatively, you could use another IDE and include the files later, or test in a different way -- how this is done is pretty open-ended, but doing it in `Olive` is pretty fast.
###### load extensions
Load extensions are the most basic form of `Olive` extension. These are extensions that are used whenever `Olive` loads up. In base `Olive`, load extensions are primarily used to add settings to the setting menu. For any UI component that you want to add that is not already in `Olive`, however, this is how it is done. Creating a load extension is really easy with the prerequesite toolips knowledge. The only dispatch for these extensions is
```julia
build(c::Connection, om::OliveModifier, oe::OliveExtension{<:Any})
```
In order to create a new extension, we simply `import` and add a `Method`.
```julia
using Olive
import Olive: build

function build(c::Connection, om::OliveModifier, oe::OliveExtension{:example})

end
```
For this example, I will use the `Olive.olive_notfiy!` function. There are a lot of different functions which work off of the `Connection` and a `ComponentModifier`, like the `OliveModifier`. Some of these functions come from `Olive` and others come from the various [toolips](#toolips) extensions which support this project. For a reference of `Olive's` functions for this, please refer to [important functions](#important-functions).
```julia
using Olive
import Olive: build

build(c::Olive.Toolips.Connection, om::Olive.OliveModifier, oe::Olive.OliveExtension{:myextension}) = begin
    Olive.olive_notify!(om, "hello!")
end
```

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/loadextem.png"></img>

Now if we save and source our `olive` home module, refreshing the page will yield our notification! The common workflow for this is to design components and then insert them into the editor. For a reference on where to insert, refer to the [UI reference](#UI-reference). Olive's dedicated area for these types of extensions is usually designated to topbar icons. This is done by using the `append!` method on your `Component` to put it into one of the menus. The most common type of element this will be is a topbar icon, so let's do an extension using that. Refer to the [function reference important functions]() for a full list of default UI component functions within `Olive`.
```julia
```

The first thing I am going to do for this is set my working directory to my `olive/src` directory. Setting your working directory is done by navigating the **inspector**'s file browser. From the **inspector**, I will select the `file` button under `create`. This will initiate the naming of my new file. I will name this `OliveExtension.jl`

##### code cell extensions
A very approachable form of `Olive` extensions are `code` cell extensions. These are extensions that extend the capabilities of `Olive`'s base `code` cell. There are three different ways that we can extend the `code` cell:
- run the function on evaluation with `on_code_evaluate`
- run the function each time the cell is typed into with `on_code_highlight`
- run the function when the cell is created with `on_code_build`. 
```julia
on_code_evaluate(c::Connection, cm::ComponentModifier, oe::OliveExtension{<:Any}, cell::Cell{:code}, proj::Project{<:Any})

on_code_highlight(c::Connection, cm::ComponentModifier, oe::OliveExtension{<:Any}, cell::Cell{:code}, proj::Project{<:Any})

on_code_build(c::Connection, cm::ComponentModifier, oe::OliveExtension{<:Any}, cell::Cell{:code}, proj::Project{<:Any})
```
In order to make this dispatch, we simply rename `OliveExtension`'s parameter.
```julia
import Olive: on_code_evaluate, on_code_highlight, on_code_build

function on_code_evaluate(c::Olive.Toolips.Connection, cm::Olive.ToolipsSession.ComponentModifier, oe::Olive.OliveExtension{:myeval},
 cell::Cell{:code}, proj::Olive.Project{<:Any})
    Olive.olive_notify!(cm, "hello")
end
```
Now everytime a cell is evaluated, we will receive a " hello" message. The inlets for this are clear -- for example, if I wanted to make a word suggestor I would check the current word `on_code_highlight`. Likewise, if I wanted to add a new button to the code cells I would do this with `on_code_build`. If I wanted to determine the names added when the cell evaluates, I would do so with `on_code_evaluate`.
##### directory extensions
The next type of extension is the `Directory` extension. Directories are one of the few extension types that `Olive` does not use in its `Base`. The only real bindings for the `Directory` on this front are `build`.
```julia
build(c::Connection, dir::Directory{<:Any}, m::Module)
```
To create a directory, the main thing we are going to need to provide is the `Cell` representation of files. Other than this, things are pretty open-ended and controls can be laid essentially however one might want them to be. The only other important dispatch for directories is `work_preview`.
```julia
work_preview(d::Directory{<:Any})
```
##### cell extensions
Cell extensions are probably the most complicated type of `Olive` extension -- aside from taking `Olive` apart and putting it back together again. There are two main types of `Cell` in `Olive`, these are **file cells** and **session cells**. The most essential of the functions to extend for cells is, as usual, `build`. A `session` Cell's dispatch takes a `Connection`, `ComponentModifier`, the `Cell`, and the `Project`. 
```julia
build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any}, proj::Project{<:Any})
```
In these **session cell** dispatches, we have the ability to create a new method based on both the `Project` and the `Cell`. Here is an example from [OlivePy](https://github.com/ChifiSource/OlivePy.jl), the `python` `Cell`. This `build` function is a great example because it builds a standard type of cell for code, with highlighting.
```julia
using Olive
using Olive.Toolips
using Olive.ToolipsSession
using Olive.ToolipsDefaults
using Olive.ToolipsMarkdown
using Olive.IPyCells
using PyCall
import Olive: build, evaluate, cell_highlight!, getname, olive_save, ProjectExport
import Base: string
using Olive: Project, Directory

function build(c::Connection, cm::ComponentModifier, cell::Cell{:python}, proj::Project{<:Any})
    tm = c[:OliveCore].client_data[getname(c)]["highlighters"]["python"]
    ToolipsMarkdown.clear!(tm)
    mark_python!(tm)
    builtcell::Component{:div} = Olive.build_base_cell(c, cm, cell,
    proj, sidebox = true, highlight = true)
    km = Olive.cell_bind!(c, cell, proj)
    interior = builtcell[:children]["cellinterior$(cell.id)"]
    sideb = interior[:children]["cellside$(cell.id)"]
    style!(sideb, "background-color" => "green")
    inp = interior[:children]["cellinput$(cell.id)"]
    inp[:children]["cellhighlight$(cell.id)"][:text] = string(tm)
    bind!(c, cm, inp[:children]["cell$(cell.id)"], km)
    builtcell::Component{:div}
end
```
Here I also use `build_base_cell` and `cell_bind!` to assist with building the cell. These give nice `Olive` base templates that are incredibly easy to work from. In addition to `build`, there are several other functions that can also be extended to change the functionality of the `Cell`. A full list of these is in the [function reference](#session-cell-reference). The main others we should worry about are `evaluate`, `string`, and `cell_highlight`. However, there are certainly some examples where `cell_bind!` has come in handy, such as this example from the `Collaborators` extension in [OliveSession](https://github.com/ChifiSource/OliveSession.jl):
```julia
function cell_bind!(c::Connection, cell::Cell{<:Any}, 
    cells::Vector{Cell}, proj::Project{:rpc})
    keybindings = c[:OliveCore].client_data[Olive.getname(c)]["keybindings"]
    km = ToolipsSession.KeyMap()
    bind!(km, keybindings["save"], prevent_default = true) do cm::ComponentModifier
        Olive.save_project(c, cm, proj)
        rpc!(c, cm)
    end
    bind!(km, keybindings["up"]) do cm2::ComponentModifier
        Olive.cell_up!(c, cm2, cell, cells, proj)
        rpc!(c, cm2)
    end
    bind!(km, keybindings["down"]) do cm2::ComponentModifier
        Olive.cell_down!(c, cm2, cell, cells, proj)
        rpc!(c, cm2)
    end
    bind!(km, keybindings["delete"]) do cm2::ComponentModifier
        Olive.cell_delete!(c, cm2, cell, cells)
        rpc!(c, cm2)
    end
    bind!(km, keybindings["evaluate"]) do cm2::ComponentModifier
        Olive.evaluate(c, cm2, cell, cells, proj)
        rpc!(c, cm2)
    end
    bind!(km, keybindings["new"]) do cm2::ComponentModifier
        Olive.cell_new!(c, cm2, cell, cells, proj)
    end
    bind!(km, keybindings["focusup"]) do cm::ComponentModifier
        Olive.focus_up!(c, cm, cell, cells, proj)
    end
    bind!(km, keybindings["focusdown"]) do cm::ComponentModifier
        Olive.focus_down!(c, cm, cell, cells, proj)
    end
    km::KeyMap
end
```
In this case, I rewrote the default cell bind to work with `rpc!`, and this is as easy as writing one method -- also of note is that the `Project` dispatch is used to facilitate this. This means that this will change for every cell under that `Project`. The `evaluate` function does precisely that -- evaluates the cell. These are usually the most complicated functions in an extension. 
##### project extensions

##### format extensions
One thing we are probably going to want for our project is the ability to read and write files. In some cases with `Olive`, this might an entirely new file type being read in an entirely new way. Adding new formats in `Olive` revolves primarily around the `olive_save` and `olive_read` functions. The first of these is `olive_read`, which takes only a **file cell** and returns a `Vector{IPyCells.Cell}`. `olive_save`, on the other hand, utilizes the `ProjectExport{<:Any}`. For example, here is the `olive_save` function in base `Olive` which denotes the standard Julia `IPyCells` `Cell` export:
```julia
function olive_save(cells::Vector{<:IPyCells.AbstractCell}, p::Project{<:Any}, 
    pe::ProjectExport{:jl})
    IPyCells.save(cells, p.data[:path])
    nothing
end
```
Note that, like in the case of **session cells** this may also be done with both the `Project` and the `ProjectExport`, so we could have a different type of project export completely differently in this way.
#### function reference
A crucial component to the
###### session cell reference
- `on_code_evaluate`
- `on_code_highlight`
- `on_code_build`
- `cell_bind!`
- `build_base_cell`
- `evaluate`
- `bind!`
- `cell_highlight!`
- `olive_save`
- `string`
###### file cell reference
- `build_base_cell`
- `evaluate`
- `olive_save`
- `olive_read`
###### project reference
- `source_module!`
- `check!`
- `work_preview`
- `open_project`
- `close_project`
- `save_project`
- `save_project_as`
- `olive_save`
- `build_tab`
- `style_tab_closed!`
- `tab_controls`
- `switch_pane!`
- `step_evaluate`
###### Directory functions
- `work_preview(d::Directory{<:Any})`
- `build(c::Connection, dir::Directory{<:Any}, m::Module)`
###### OliveExtension functions
- `build`
- `create_new`
###### ProjectExport functions
- `olive_save(cells::Vector{<:IPyCells.AbstractCell}, p::Project{<:Any}, pe::ProjectExport{<:Any})`
###### important functions
- `containersection` builds a container with an expander.
- `switch_work_dir!` changes the workind directory of an environment.
- `olive_notify!` sends an `Olive` notification.
#### UI reference
Olive is changed primarily by using `ComponentModifiers` to make changes to the Olive UI. For this, the pre-requisite knowledge is to know the IDs of different things you are working with. That being said, in order to work with all portions of Olive we will want to know how the UI is composed together.
###### session reference
###### topbar reference
###### explorer reference
###### cell reference
###### project reference

###### directory reference
- create_new!
- work_preview
#### Server reference
The thing about `Olive` is that the concept is very open. With Olive, we could effectively completely rebuild the main session ourselves in order to customize our `Olive`. This would be done by creating a new `route` with `Toolips` and 
#### examples
With so much information in the development of `Olive` extensions, it might be helpful to look at code from some examples. The most basic of these examples that might give a pretty idea of how extensions are built is OlivePy. This project provides `Olive` with `Python` cells and the ability to read `.py` files. This includes a **file cell** extension, a **load extension**, a **session cell** extension, and an **olive_save** extension.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/olsc/rthtrhrtjrjy.png?raw=true"></img>

Here is a link to several extensions. which are helpful for demonstrating writing them:
- [OlivePy](https://github.com/ChifiSource/OlivePy.jl) `load` `session cell`, `olive_save`, `file cell`
- [OliveSession](https://github.com/ChifiSource/OliveSession.jl) `load` `Project`, `olive_save`, `session cell`, `Directory`
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
This also means that the routes of an `Olive` server could be changed, or rerouted in anyway -- really.
#### olive session
A crucial project you are probably going to want to be aware of if you are planning to deploy `Olive` is [OliveSession](https://github.com/ChifiSource/OliveSession.jl). This is an `Olive` extension provided to make `Olive` far more deployable and multi-user friendly.
### contributing
Olive is a complicated project, and there is a lot going on from merely Olive itself to the entire ecosystem that supports olive. That being said, community support is essential to improving this project. You may contribute to Olive by
- simply using olive
- creating extensions for olive
- sharing olive with your friends!
- starring olive
- forking olive
- submitting issues
- sponsoring ChifiSource creators (in each repo's sponsors section)
- participating in the community

I thank you for all of your help with our project, or just for considering contributing!
#### guidelines
When submitting issues or pull-requests for Olive, it is important to make sure of a few things. We are not super strict, but making sure of these few things will be helpful for maintainers!
1. You have replicated the issue on `Olive#Unstable`
2. The issue does not currently exist... or does not have a planned implementation different to your own. In these cases, please collaborate on the issue, express your idea and we will select the best choice.
3. **Pull Request TO UNSTABLE**
4. This is an issue with Olive, not a dependency; if there is a problem with highlighting, please report that issue to [ToolipsMarkdown](https://github.com/ChifiSource/ToolipsMarkdown.jl). If there is an issue with Cell reading/writing, report that issue to [IPyCells](https://github.com/ChifiSource/IPyCells.jl)
### known issues
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
