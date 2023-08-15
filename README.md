<div align = "center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/newoliveover.png" width="350">
<h6>| 0.0.9 |</h6>
</div>

Welcome to olive! Olive is a **pure julia** notebook editor built on the back of multiple dispatch. Through multiple dispatch, olive is able to change functionality entirely by simply having new methods. Using extensions, olive can edit **any** file. Among other things, olive features ...
- regular **julia modules**
- unparalleled **extensibility**
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

Keep in mind this version of Olive (while functional) is still a **work in progress** build. Thank you for reporting bugs to the issues page!

###### map
- [get started](#get-started)
   - [setup](#setup)
   - [user interface](#user-interface)
   - [directories](#directories)
   - [cells](#cells)
   - [projects](#projects)
- [extensions](#extensions)
   - [installing extensions](#installing-extensions)
   - [common extensions](#common-extensions)
   - [creating extensions](#creating-extensions)
- [deploying olive](#deploying-olive)
   - [`0.0.9`deployment status](#status)
   - [creating an olive server](#creating-a-server)
   - [OliveSession](#session)
- [contributing](#contributing)
    - [guidelines](#guidelines)
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
- `devmode`**::Bool** = `false`
- `path`**::String** = `homedirec()`

Providing `devmode` will start `Olive` in developer mode. This just makes it easier to test things when working on `Olive` itself. More will eventually come to `devmode`, as of right now this option is **not recommended**. Providing a `path` will search for an `olive` home at the provided directory. If there is no `olive` directory, this will start the `setup` inside of this directory. This can be useful for developing extensions, deploying olive, or having multiple profiles with different sets of extensions.
#### setup
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/cccccsa.png"></img>
When first starting Olive, you will arrive at the `setup` route. This screen will ask you to select a home directory. After picking your directory, press `confirm` and you will be greeted with the second portion of setup which will ask you for your name and if you would like to add OliveDefaults. Respond -- you'll definitely want to pick your username! OliveDefaults is an entirely optional extension that will get added -- not loaded -- to your Olive Pkg environment. After confirming, your `olive` home directory will be setup. This home directory is important because it is used in order to extend Olive. After the setup completes, you will automatically be redirected to your new Olive homepage! This page requires a key to enter. The directories here will be your olive home and working directories. Files can be opened by clicking the menu in the top left.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/Screenshot%20from%202023-08-11%2015-44-55.png"></img>

This is where extensions and changes can be written on top of olive from the outside in. Double clicking a file in the directory will yield a loading of the `/session` route. This route contains the actual editor, as well as the project explorer. The project explorer can be opened by clicking the top left. Client settings can be altered by clicking the top right settings icon. These settings are saved whenever the settings menu is closed.

#### directories
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/pexplorer.png"></img>
Directories are the final piece of the puzzle. When arriving at the main explorer screen, you will be greeted with two different directories: these are your `olive` home directory and project, and then your working directory. These directories contain file cells inside of them, as well as some controls to make new files or folders inside of the tab for the cells. Double clicking a file will open that file inside of session.
#### cells 

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/alpha9sc/Screenshot%20from%202023-08-15%2007-20-26.png"></img>

The repl cells include `pkgrepl`, `helprepl`, and `shell`. These three cells are all accessible from a `code` cell, or can be created on their own from a creator cell. The `pkgrepl` cell takes simple Pkg commands, and is meant to work pretty similarly to its Julia equivalent. The same can be said for the `shell` REPL cell. The `helprepl` will take a name of something you want documentation for. There are more plans for these cells in the future, and many bugs with them that are going to need to be ironed out. The final cell type that olive includes is the `tomlvalues` cell. This is a cell which can evaluate TOML into a dictionary, and can also be written to Julia or TOML.
#### projects
Projects are what holds your olive session together. Whenever a project is built, it will present itself in your session as a window with a tab. Clicking the tab will yield some controls, these are... (from left to right)
- collapse
- save
- save as
- new
- resource
- run all
- close

This is the portion of Olive that is the most under development, so there is not much to say -- but these are definitely something to be aware of.

### extensions


#### installing extensions


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
2. The issue does not currently exist.
3. **Pull Request TO UNSTABLE**
4. This is an issue with Olive, not a dependency; if there is a problem with highlighting, please report that issue to [ToolipsMarkdown](https://github.com/ChifiSource/ToolipsMarkdown.jl). If there is an issue with Cell reading/writing, report that issue to [IPyCells](https://github.com/ChifiSource/IPyCells.jl)
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
