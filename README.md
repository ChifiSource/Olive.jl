<div align = "center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/newoliveover.png" width="350">
<h6>| 0.0.9 |</h6>
</div>

#### welcome to olive
Olive.jl is an Extensible Notebook Integrated Development Environment (ENIDE) written in the Julia programming language. Olive notebooks feature markdown and more 
- Extensibility
- Deployability
- Endless Customization
- Regular Julia Files
- 

Keep in mind this version of Olive (while functional) is still a **work in progress** build. Thank you for reporting bugs to the issues page!
###### map
- [olive?](#olive?)
- [get started](#get-started)
- [basic olive](#basic-olive)
- [extending olive](#extending-olive)
- [deploying olive](#deploying-olive)
- [contributing](#contributing)
- [tech stack](#tech-stack)

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/olsc/thethetherthgfhtrj.png"></img>


### olive?

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

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/olsc/jtyjtyjtyjdfdjdhgj.png?raw=true"></img>

### basic olive
When first starting Olive, you will arrive at the `setup` route. This screen will ask you to select a home directory. After picking your directory, press `confirm` and you will be greeted with the second portion of setup which will ask you for your name and if you would like to add OliveDefaults. Respond -- you'll definitely want to pick your username! OliveDefaults is an entirely optional extension that will get added -- not loaded -- to your Olive Pkg environment. After confirming, your `olive` home directory will be setup. This home directory is important because it is used in order to extend Olive. After the setup completes, you will automatically be redirected to your new Olive homepage! This page requires a key to enter. The directories here will be your olive home and working directories. Files can be opened by clicking the menu in the top left.


**TODO** explorer image here.

This is where extensions and changes can be written on top of olive from the outside in. Double clicking a file in the directory will yield a loading of the `/session` route. This route contains the actual editor, as well as the project explorer. The project explorer can be opened by clicking the top left. Client settings can be altered by clicking the top right settings icon. These settings are saved whenever the settings menu is closed.
##### cells 
There are several types of cells that come with Olive, and adding cells is as easy as using modules. The main cell that one will interact with in this regard is the `code` cell. This is your standard Julia input and output. Pressing `;` in a `code` cell will yield a `shell` cell, pressing `]` will yield a `pkgrepl` cell, and `?` will yield a `helprepl` cell. It should also be noted that `#=TODO` and `#=NOTE` also create their own respective comment cells. The default cell bindings are as follows
- `ctrl` + `shift` + `Enter` runs current cell.
- `ctrl` + `shift` + `Q` Adds new creator cell.
- `ctrl` + `shift` + `Delete` Deletes the current cell
- `ctrl` + `shift` + `ArrowUp` Moves the current cell up
- `ctrl` + `shift` + `ArrowDown` moves cells down.

These bindings are editable inside of the settings menu. `creator` cells are used to create new cells with creator keys. These bindings may also be changed inside of the settings menu, and allow you to create many different cell types with different key-bindings for the `creator` cell.

<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/olsc/eththethehhethh.png?raw=true"></img>

The repl cells include `pkgrepl`, `helprepl`, and `shell`. These three cells are all accessible from a `code` cell, or can be created on their own from a creator cell. The `pkgrepl` cell takes simple Pkg commands, and is meant to work pretty similarly to its Julia equivalent. The same can be said for the `shell` REPL cell. The `helprepl` will take a name of something you want documentation for. There are more plans for these cells in the future, and many bugs with them that are going to need to be ironed out. The final cell type that olive includes is the `tomlvalues` cell. This is a cell which can evaluate TOML into a dictionary, and can also be written to Julia or TOML.
##### projects
Projects are what holds your olive session together. Whenever a project is built, it will present itself in your session as a window with a tab. Clicking the tab will yield some controls, these are... (from left to right)
- collapse
- save
- save as
- new
- resource
- run all
- close

This is the portion of Olive that is the most under development, so there is not much to say -- but these are definitely something to be aware of.
##### directories
Directories are the final piece of the puzzle. When arriving at the main explorer screen, you will be greeted with two different directories: these are your `olive` home directory and project, and then your working directory. These directories contain file cells inside of them, as well as some controls to make new files or folders inside of the tab for the cells. Double clicking a file will open that file inside of session.
### extending olive
If there is one thing that Olive has built its methodology on, this would be extensibility. The primary extension focus for `0.0.8` is on cells, but there will be even more extension capabilities coming to Olive in the near future. Projects and Directories are both able to be extended, there just is not much convenience to doing so at the moment -- so this is currently not recommended. If you would like to attempt to create your own extensions with this current iteration of Olive, it is sensible to look into the documentation for
- `build`
- `evaluate`
- `build_base_cell`
- `cell_bind!`
- `olive_save`
- `cell_highlight!`


<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/olsc/rthtrhrtjrjy.png?raw=true"></img>

[Here](https://chifi.dev/adding-python-cells-to-olive-3d564633dc04?source=your_stories_page-------------------------------------) is an article where I go about creating a Python extension for Olive, and [here](https://github.com/ChifiSource/OlivePy.jl) is a link to that project so you may see it for yourself
### deploying olive
Olive has been built with deployability in mind, but we should keep in mind that `0.0.8` is still an early version of Olive. It is not recommended to deploy this version as there is insufficient memory management and permission management on the back-end. This cuurrent form of Olive is certainly recommended to be used personally, and locally, but this is set to change by `0.1.0` :)

### contributing
Olive is a complicated project, and there is a lot going on from merely Olive itself to the entire ecosystem that supports olive. That being said, community support is essential to improving this project. You may contribute to Olive by
- simply using olive
- sharing olive with your friends!
- starring olive
- forking olive
- submitting issues
- sponsoring ChifiSource creators (in each repo's sponsors section)

I thank you for all of your help with our project, or just for considering contributing!
#### issues
When submitting issues for Olive, it is important to make sure of a few things.
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
