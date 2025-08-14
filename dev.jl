#==
dev.jl is an environment file. This file loads and starts servers, and
defines environmental variables. Use this file to customize your own development case for `Olive`.
==#
using Pkg; Pkg.activate(".")
using Toolips
using ToolipsSession
using Revise
using Olive

IP = "127.0.0.1"
PORT = 8000

OliveDevServer = Olive.start(IP:PORT, headless = true)
