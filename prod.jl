using Pkg; Pkg.activate(".")
using Toolips
using ToolipsSession
using Olive

IP = "127.0.0.1"
PORT = 8008
extensions = [Logger(), Files("public"), Session()]
OliveServer = Olive.start(IP, PORT, extensions)
