#==
Cell
    Styles
==#
function cell_in()
    cellin = Animation("cell_in", length = 1.5)
    cellin[:from] = "opacity" => "0%"
    cellin[:from] = "transform" => "translateY(100%)"
    cellin[:to] = "opacity" => "100%"
    cellin[:to] = "transform" =>  "translateY(0%)"
    cellin
end

function usingcell_style()
    st = Style("div.usingcell", border = "0px solid gray", padding = "40px")
    st["background-color"] = "#CCCCFF"
    st["border-radius"] = "5px"
    animate!(st, cell_in())
    st
end

function cell_style()
    st = Style("div.cell", border = "2px solid gray", padding = "20px")
    st["background-color"] = "white"
    animate!(st, cell_in())
    st
end

function inputcell_style()
    st = Style("div.input_cell", border = "2px solid gray", padding = "20px")
    st["border-radius"] = "30px"
    st["margin-top"] = "30px"
    animate!(st, cell_in())
    st
end

function outputcell_style()
    st = Style("div.output_cell", border = "2px solid pink", padding = "10px")
    st["margin-top"] = "20px"
    st["margin-right"] = "200px"
    st["border-radius"] = "30px"
    animate!(st, cell_in())
    st
end

#==
Text
    Styles
==#

hdeps_style() = Style("h1.deps", color = "white")

h1_style() = Style("h1", color = "pink")

h2_style() = Style("h2", color = "lightblue")

h3_style() = Style("h3", color = "orange")

h4_style() = Style("h4", color = "gray")

#==
Icons/Fonts
href="https://fonts.googleapis.com/icon?family=Material+Icons"
==#
google_icons() = link("google-icons",
href = "https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200",
rel = "stylesheet")
function iconstyle()
    s = Style(".material-symbols-outlined", cursor = "pointer")
    s["font-size"] = "100pt"
    s:"hover":["color" => "orange"]
    s
end
function cellnumber_style()
    st = Style("h1.cell_number", color = "lightblue")
    st["font-family"] = "'Rubik', sans-serif"
    st
end

function text_style()
    st = Style("a")
    st["font-family"] = "'Roboto Mono', monospace"
    st
end

mutable struct OliveSettings <: Servable
    f::Function
    styles::Dict
    function OliveSettings(styles::Dict = default_styles())
        f(c::Connection) = begin
            stcpmns = Vector{Servable}([v[2] for v in pairs(styles)])
            write!(c, stcpmns)
        end
        new(f, styles)
    end
end
function default_styles()
    Dict{String, Any}(
        "cell_in" => cell_in(), "usingcell" => usingcell_style(),
        "cell" => cell_style(), "inputcell" => inputcell_style(),
        "outputcell" => outputcell_style() ,"hdeps" => hdeps_style(),
        "h1" => h1_style(), "h2" => h2_style(), "h3" => h3_style(),
        "h4" => h4_style(), "icons" => google_icons(),
        "iconstyle" => iconstyle())
    end
