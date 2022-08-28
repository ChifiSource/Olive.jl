<div align = "center">
<img src = https://github.com/ChifiSource/image_dump/blob/main/olive/default.png width = 400>
<h5>📓| pure julia notebooks |📓</h5>
</div>

### quickstart
Olive.jl is not currently released, and it is recommended that users wait until the alpha (0.0.1) release before actually getting started with Olive.jl. However, you can still play around with what is available, and possibly work with the code yourself by getting a clone of this project:
```bash

```
As of right now, adding Olive as a Julia package will give a missing directory error, but in the future, you will be able to add Olive.jl with Pkg:
```julia
using Pkg; Pkg.add(url = "https://github.com/ChifiSource/Olive.jl")
```
Finally, you will be able to `wget` a compiled binary of Olive.jl for your system beginning with the release of 0.0.1.
### what is olive?

<img src = https://github.com/ChifiSource/image_dump/blob/main/olive/screenshots/ferferferferf.png>

Olive.jl is an explicitly reactive notebook for Julia. Current options available in Julia are
- IJulia/Jupyter: non-reactive explicit notebook (cell execution is controlled by the user, but the user is also the sole maintainer of state.)
- Pluto.jl: reactive implicit notebook (cell execution is controlled b the user only intermittently, and the notebook itself maintains state for you.) \
There are of course advantages to both of these. With Pluto.jl we get the benefit of writing more reproducible code with little to no effort. However, implicit things are also problematic because they can do things wrong implicitly, leading to results that can sometimes be a little surprising and unpredictable. With Pluto.jl, you might run into an " I want to reorder this but cannot," or " why did that cell just randomly run?" issue. Jupyter is the other side of this spectrum. While it is easy to make code that is not reproducible, the user is also given full control over the state -- perhaps even a bit to much. \
The gap between these two extremes is actually quite large, and Olive.jl hopes to fill this niche! Explicitly reactive means that the notebook still reacts how it would in Pluto.jl, however things are handled by the end-user, rather than the reactive feature itself. For example, we have the following cells:
##### cell 1
```julia
x += 5
```
##### cell 2
```julia
x = 1
```
Olive will realize that cell 1 cannot be ran without cell 2 first being ran. However, instead of just reordering them implicitly, the end-user is presented with a hot-key to quickly fix the state by changing these cells, though this still remains optional!
### more advantages
- Regular Julia projects (even more pure julia than Pluto.jl)
- (customizable) HOTKEYS
- Extensibility
- Broader range of development (we are not just limited to regular Julia files, IPython noteboooks, but can in fact develop modules and more. Given that this is done via extensions, it will be easy for anyone to implement their own cells, project types, and more!
- Modern UI
- Supports Olive (regular julia with commented outputs and markdown Strings), Ipynb, and Pluto notebooks
