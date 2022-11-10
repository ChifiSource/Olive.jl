<div align = "center">
<img src = https://github.com/ChifiSource/image_dump/blob/main/toolips/olive/olivefullcover.png width = 500>
<h6>| 0.0.2 |</h6>
</div>

##### welcome to olive
Olive.jl is a customizable Integrated Development Environment for Julia programming in a notebook-like environment. Executable blocks of code are surrounded by Markdown in a far more reproducible form than ever before. Olive features
- Extensibility
- Deployability
- Customization
- Interactive capabilities
- Toolips bonuses -- there will be more of these as time goes on

The goal with Olive is to replace the conventional IDE with a mutable IDE -- allowing creators to create however they like to create with the flexibility of custom cells and extensions!
###### get started
Getting started with Olive starts by installing this package via Pkg. In the future, without the URL. **Press ] to enter your pkg REPL**.
```julia
julia> ]
pkg> add https://github.com/ChifiSource/Olive.jl
```
Alternatively, you could also grab `Unstable`, this will give you the latest developments, but some features might be intermittently broken.
```julia
julia> ]
pkg> add https://github.com/ChifiSource/Olive.jl#Unstable
```
Next, enter
```julia
using Olive; Olive.start()
```
Visiting the link in your REPL will land you on the Olive setup screen, which will just ask a few questions for setup, and wham! You are ready to go! Another option, if you intend to deploy Olive you may use `Olive.create()`, providing a name.
```julia
using Olive
Olive.create("MyOliveServer")
```
###### tech stack
Olive is fueled by a web of other Chifi projects. Olives.jl is [Toolips](https://github.com/ChifiSource#Toolips)-based. Thus, many dependencies are Toolips extensions, here is a look at that list:
- [Toolips](https://github.com/ChifiSource/Toolips.jl)
- [ToolipsSession](https://github.com/ChifiSource/ToolipsSession.jl)
- [ToolipsMarkdown](https://github.com/ChifiSource/ToolipsMarkdown.jl)
- [ToolipsDefaults](https://github.com/ChifiSource/ToolipsDefaults.jl)
- [ToolipsBase64](https://github.com/ChifiSource/ToolipsBase64.jl)
- [ToolipsAuth](https://github.com/ChifiSource/ToolipsAuth.jl)

And there is one package that is used from [odd data](https://github.com/ChifiSource#odddata).
- [IPy](https://github.com/ChifiSource/IPy.jl)
And a few other packages,
- [Pkg]()
- [Highlights]()
