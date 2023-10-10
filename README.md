<div align = "center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/newoliveover.png" width="350">
<h6>| 0.0.9 |</h6>
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
     - [environments](#environments)
     - [methodology](#parametric-methodology)
     - [directories](#directories)
     - [projects](#projects)
     - [cells](#cells)
     - [keybindings](#keybindings)
   - [base](#base)
     - [cells](#base-cells)
     - [projects](#base-projects)
     - [directories](#base-directories)
     - [settings](#settings)
- [extensions](#extensions)
   - [installing extensions](#installing-extensions)
   - [common extensions](#common-extensions)
     - [functionality extensions]()
     - [language extensions]()
   - [creating extensions](#creating-extensions)
     - [Toolips](#toolips-basics)
     - [extensible functions](#extensible-functions)
     - [general extensions]()
     - [cell extensions]()
     - [project extensions]()
     - [directory extensions]()
  - [extension examples](#examples)
- [deploying olive](#deploying-olive)
   - [`0.0.9`deployment status](#status)
   - [OliveSession](#session)
   - [creating an olive server](#creating-a-server)
- [contributing](#contributing)
   - [guidelines](#guidelines)
   - [known issues](#known-issues)
   - [tech stack](#tech-stack)
---
### get started
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
Providing `devmode` as `true` will start `Olive` in developer mode. This just makes it easier to test things when working on `Olive` itself. More will eventually come to `devmode`, as of right now this option will simply **disable authentication**. Providing a `path` will search for an `olive` home at the provided directory. If there is no `olive` directory, this will start the `setup` inside of this directory. This can be useful for developing extensions, deploying olive, or having multiple profiles with different sets of extensions. Providing `free` as `true` will start the `Olive` server in **global mode**. This means that instead of using an `olive` home file, `olive` will use your default Julia environment. **In the future** (`0.1.0`), this will also scan your julia environment for extensions and load them. However, project settings will not be loaded.
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/termsc.png"></img>

#### setup

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/setupsc.png"></img>


When you start `Olive` for the first time, you will be greeted with a new link to your olive setup. This screen also holds a directory selector. The currently selected directory is indicated by the label at the top. In this directory, a new Julia project will be created. This will be your `olive` home environment inside of this directory. This includes the folder `olive`, the `Project.toml environment and its `Manifest.toml` counter-part, the contained `src` directory and correstponding source file `src/olive.jl`. After selecting a directory, the setup will then move to a second screen.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/setup2sc.png"></img>

This portion of the setup will ask for a name and if you want to add [OliveDefaults](https://github.com/ChifiSource/OliveDefaults.jl). This package provides `Olive` with some default extensions that many developers would likely prefer. This includes
- The `Styler` extension.
- The `DocBrowser` extension.
- The `AutoComplete` extension
- And the `Themes` extension.

These extensions can be loaded individually; the setup will only add `OliveDefaults` with `Pkg`. The name is also pretty important, though certainly not necessary. Any name will work, including the default `root`. After pressing continue, a loadbar will appear and `Olive` will begin setting up your `olive` environment. After this loadbar finishes (so long as the setup completes successfully), you will be redirected to a new `Olive` session!
#### user interface
Olive's user-interface is relatively straightforward. When starting olive, you will be greeted with a `get started` `Project`. A `Project` in `Olive` is represented by a tab and the project's cells. This consumes the majority of the UI. These projects are contained within two separate panes, the **left pane** and the **right pane** respectively. The left pane **can** be open without the right pane, but the right pane **cannot** be open without the left pane. The project can be switched using the pane switcher button on the top of the project. At the top of the window will be the topbar. The topbar has two buttons on it, on the left this is a folder with an arrow. Clicking this button will open the **project explorer**. This is the menu to the left of your `Olive` session.  At the top of this menu, there is the **inspector**, and below this is where every `Directory` is placed. When a `Project` is added to the session, it will also add a preview into the inspector. In the top right there is a cog, this button will reveal the **settings menu**. All settings in `Olive` are added via extensions, so these will be your extension settings, such as key-bindings and syntax highlighting. Adding more extensions will often add new settings to this menu.
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/uiui.png"></img>

The **top bar** is responsible for holding extension controls, settings, and the **project explorer**. Inside of the **settings** there will be an editable configuration for all of the loaded `Olive` extensions. Inside of the **project explorer** is access to file operations and the **inspector**.

<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/pexplorer.png"></img>
</div>

The **project explorer** is a crucial component to your `Olive` session because it manages the entire underlying filesystem running in your `Environment`. At the top of the **project explorer** will be the **inspector**. Once expanded, this section contains a file browser and previews of directories and projects in your `Environment` currently. Beneath this are the currently loaded directories. New directories can be added from the inspector by clicking the arrow next to the current working directory. Once added, we can open files from a given directory by double clicking.

<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/inspectorui.png" width="300"></img>
</div>

This will also be where other file operations take place, such as `save as` and `create file`. Below this will be your directories with **file cells** inside. On the top, there is a button to update the `Directory` and a button to `cd` to the directory. If this directory is your `olive` home root, this is added if the client is root, then there will also be a red run button, this button sources your `olive` home module.
#### documentation
With the upcoming release of `0.1.0`, [chifi](https://github.com/ChifiSource) will also be releasing [OliveCreator](https://github.com/ChifiSource/OliveCreator.jl), this will be a website which hosts `Olive`. Along with this there will be interactive examples, notebooks, and most importantly -- documentation (for all chifi stuff, really awesome olive-based documentation). The problem is that this still requires a lot of work to `Olive` and its sister projects. In its current state the two best tools to learn `Olive` are
- this README
- or the [OliveDefaults](https://github.com/ChifiSource/OliveDefaults.jl) documentation browser.

  I would recommend the latter. For the most part, this documentation is only needed if you are writing extensions for `Olive`. I could see knowledge of how the thing works being beneficial in these early pre-releases, however.
#### environments
Though not always prominent to the end-user, the `Environment` is also a crucial piece of this puzzle. This is the overall structure that encompasses all projects and directories for each user. Also contained within this `Environment` is the currently activated `Pkg` environment and the current working directory. When using the **inspector** to navigate directories, this will change the working directory of your environment. Clicking the lightning bolt next to a `toml` file cell will change the currently activated environment. Your environment holds your `Pkg` environment and your working directory in addition to all of the projects currently open.
#### parametric methodology
Olive uses **parameters** and **multiple dispatch** to load new features with the creation of method definitions. This technique is used comprehensively for `Olive`'s `Directory` and `Project` types, as well as [IPyCell's](https://github.com/ChifiSource/IPyCells.jl) `Cell`. This allows for a `Symbol` to be provided as a parameter. With this, `Olive` either reads the methods for its own functions or provides them as arguments to alter the nature of UI components. `Project`, `Directory`, and `Cell` are all **julia types**. These are translated into the `Olive` web-based UI using `build` methods. For example, the `creator` cell will list out all of the methods that `Olive` has defined for `build(::Toolips.AbstractConnection, ::Toolips.Modifier, ::Cell{<:Any}, ::Vector{Cell}, proj::Project{<:Any})`. In order to name such a cell, simply label the parameter in the `Cell` using a `Symbol`.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/creatorcell.png"></img>

This is the defining characteristic of `Olive`, and also how the base `Olive` features are built. This is why `Olive` is a **multiple dispatch notebook**, not just that but a **parametric** multiple dispatch notebook. As a result, a lot of what `Projects`, `Cells`, and `Directories` do is pretty open-ended -- anything is possible. This is also how extensions for `Olive` work. While this might not be that important to know if you are not extending `Olive` on your own, it is helpful to know this going into `Olive` and the rest of this `README`.
#### directories
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/pexplorer.png"></img>
Directories are used to load `Olive` projects from files. At the top of the standard `Olive` `Directory`, there will be a button to change to the `Directory` inside of the **inspector** and a button to remove that directory from your current `Environment`. Most file actions, such as move and rename, are instead done through the **inspector**.
#### projects
In the same way that directories are containers for **file cells**, projects are containers for **session cells**.
#### cells 
Cells are a general name for the components that compose a given `Olive` project's source file. To elaborate, cells are parametric and read in from files, while in base `Olive` this includes a limited scope of cells for Julia-bourne Data Science and Software Development, `Olive` extensions could easily change this. Cells are rendered inside of `Project` windows and go into **pane one** or **pane two**. 
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/Screenshot%20from%202023-08-15%2007-20-26.png"></img>

There is no one cell, as the capabilities of a cell change with the type of that cell. In the screenshot above, we see several different types of cells. Cells are created using the `creator` cell, which is created by pressing `ctrl` + `Shift` + `Enter` in a cell. This will create a new creator cell, which uses **creator keys** to select a cell type. These keys may be edited inside of the **settings** menu.

<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/creatorcell.png"></img>
</div>

###### keybindings
Using cells is simple. By default, olive bindings use `ctrl` alone for window features, `ctrl` + `shift` to do things inside of projects, and `shift` alone to work with a specific cell. The resulting key-bindings are
- **window bindings**
  - `ctrl` + `C` **copy**
  - `ctrl` + `X` **cut**
  - `ctrl` + `V` **paste**
  - `ctrl` + `S` **save selected project**
  - `ctrl` + `z` **undo**
  - `ctrl` + `y` **redo**
  - `ctrl` + `F` **search**
- **project bindings**
  - `ctrl` + `shift` + `X` **cut selected cell**
  - `ctrl` + `shift` + `V` **paste selected cell**
  - `ctrl` + `Shift` + `S` **save project as**
  - `ctrl` + `shift` + `Delete` **delete selected cell**
  - `ctrl` + `shift` + `Enter` **new cell**
  - `ctrl` + `shift` + `↑` **move selected cell up**
  - `ctrl` + `shift` + `↓` **move selected cell down**

- **cell bindings**
  - `shift` + `Enter` **run cell**
  - `shift` + `↑` **shift focus up**
  - `shift` + `↑` **shift focus down**

#### base
Something unique about `Olive`, and yet another similarity to the Julia language itself, is that `Olive`'s core features are built using the same exact methodology one would use to build `Olive` extensions. In other words, `Olive`'s `code` cells are written into `Olive` as an extension. In its purest form, `Olive` is simply an anything editor that can have anything built on top of it. The base just **happens to** come with tools for **Data Science** and **Software Development** for Julia. That being said, it is worth going through the concept and the base separately. Now that we have a firm understanding of how these different things fit together (`Directories`, `Projects`, `Cells`, `Environments`), we can get a good idea of how the base `Olive` extensions work.
###### base directory
The only directory that comes with `Olive` is the base directory. 
###### base cells
###### base projects

###### settings

### extensions
`Olive` is not `Olive` without extensions. While the base `Olive` features are pretty cool, `Olive`'s base is intentionally built with a minimalist mindset. The idea is that **nothing is everyone's cup of tea**, so why use someone else's computer to load things for people who do not even want those things to begin with? With the `Olive` (and frankly, **Julia**) approach new features are added by adding new methods to existing `Olive` functions. With this, `Olive` becomes a notebook centralized on multiple dispatch! Olive extensions work off of `Olive`'s [parametric multiple dispatch methodology](#parametric-methodology) for loading extensions. A parameter is used to denote the existence of a new function, and each method of a given function becomes representative of that cell's action. As a result, extensions are loaded by merely having such method definitions loaded into memory. As a result, installing extensions is incredibly easy.
#### installing extensions
In order to install an `Olive` extension, we will start by adding that extension as a package to our `olive` home environment. From the Julia REPL running your `Olive` session, you may check the active environment

#### common extensions

<div align = "left">

<table>
<tr>  
 <th><a href = "https://github.com/ChifiSource/OliveSession.jl"><img width = 120 src="https://github.com/ChifiSource/image_dump/blob/main/olive/olivesession.png"></a></th>
   <th><a href = "https://github.com/ChifiSource/OliveDefaults.jl"><img width = 120 src="https://github.com/ChifiSource/image_dump/blob/main/olive/olive2defaults.png" ></a></th>
   <th><a href = "https://github.com/ChifiSource/OliveMarkdown.jl"><img width = 120 src="https://github.com/ChifiSource/image_dump/blob/main/olive/olivemd.png" ></a></th>
   <th><a href = "https://github.com/ChifiSource/OlivePy.jl"><img width = 120 src="https://github.com/ChifiSource/image_dump/blob/main/olive/olivepy.png" ></a></th>
  </tr>
  
  <tr>

<td align = "center">
      
      
      
**unreleased**
      
      
 </td>
 <td align = "center">
      
      
      
**unreleased**
      
      
 </td>
<td align = "center">
      
      
      
**unreleased**
      
      
 </td>
  <td align = "center">
      
      
      
**unreleased**
      
      
 </td>
</tr>
</table>

#### creating extensions
- `build`
- `evaluate`
- `build_base_cell`
- `cell_bind!`
- `olive_save`
- `cell_highlight!`
###### examples
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/olsc/rthtrhrtjrjy.png?raw=true"></img>

[Here](https://chifi.dev/adding-python-cells-to-olive-3d564633dc04?source=your_stories_page-------------------------------------) is an article where I go about creating a Python extension for Olive, and [here](https://github.com/ChifiSource/OlivePy.jl) is a link to that project so you may see it for yourself
### deploying olive
Olive has a goal to be very deployable, but it is recommended to wait for `0.1.0` to deploy `Olive`. It is also recommended to add `OliveSession`; this provides a number of great features for multiple users, including better directory management, login screens, and sharable sessions.
   - [`0.0.9`deployment status](#status)
   - [creating an olive server](#creating-a-server)
   - [OliveSession](#session)
#### status
#### creating a server

#### session
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
