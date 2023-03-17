<div align = "center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/newoliveover.png" width="350">
<h6>| 0.0.8 |</h6>
</div>

#### welcome to olive
Olive.jl is a customizable Integrated Development Environment for Julia programming in a notebook-like environment. Executable blocks of code are surrounded by Markdown in a far more reproducible form than ever before. Olive features
- Extensibility
- Deployability
- Customization

###### map
- [get started]()
- [basic olive]()
    - setup
    - cells
    - session
- [extending olive]()
    - the `build` function
    - extension basics
    - creating directories
    - creating file cells
    - creating session cells
    - creating projects
    - server extensions/routes
    - adding a new format
- [deploying olive]()
    - `0.0.8` deployment status
    - the `create` function
    - customizing servers
- [contributing]()
    - how to contribute
    - issues
    - chifi
- [tech stack]()
    - toolips
    - other

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
### basic olive
When first starting Olive, you will arrive at the `setup` route. This screen will ask you to select a home directory. After picking your directory, press `confirm` and you will be greeted with the second portion of setup which will ask you for your name and if you would like to add OliveDefaults. Respond -- you'll definitely want to pick your username! OliveDefaults is an entirely optional extension that will get added -- not loaded -- to your Olive Pkg environment. After confirming, your `olive` home directory will be setup. This home directory is important because it is used in order to extend Olive. After the setup completes, you will automatically be redirected to your new Olive homepage, also known as `explorer` at route `/`. This page requires a key to enter. The directories here will be your olive home and working directories. The home directory will contain a `Project.toml` file with your Olive data, as well as a moduule source file for a module called `olive`. This is where extensions and changes can be written on top of olive from the outside in. Double clicking a file in the directory will yield a loading of the `/session` route. This route contains the actual editor, as well as the project explorer.
##### cells
### extending olive
### deploying olive
Olive has been built with deployability in mind, but we should keep in mind that `0.0.8` is still an early version of Olive. It is not recommended

### contributing

#### tech stack
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
