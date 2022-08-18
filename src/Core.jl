#==
Default
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
    st::Style = Style("div.usingcell", border = "0px solid gray", padding = "40px",
    "border-radius" => 5px, "background-color" => "#CCCCFF")
    animate!(st, cell_in()); st::Style
end

function cell_style()
    st::Style = Style("div.cell", border = "2px solid gray", padding = "20px",
    st["background-color"] = "white")
    animate!(st, cell_in())
    st::Style
end

function inputcell_style()
    st = Style("div.input_cell", border = "2px solid gray", padding = "20px",
    "bordier-radius" => 30px, "margin-top" => 30px)
    animate!(st, cell_in())
    st::Style
end

function outputcell_style()
    st = Style("div.output_cell", border = "2px solid pink", padding = "10px",
    "margin-top" => 20px, "margin-right" => 200px, "border-radius" => 30px)
    animate!(st, cell_in())
    st::Style
end

hdeps_style() = Style("h1.deps", color = "white")

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

function olivesheet()
    st = sheet()
    push!(st, cell_in(), iconstyle(), cellnumber_style(), hdeps_style(),
    usingcell_style(), outputcell_style(), inputcell_style())
end

mutable struct OliveExtension <: Servable

end

mutable struct OliveCore <: ServerExtension
    pages::Vector{Servable}
    sessions::Dict{String, Pair{Vector{Cell}, String}}
    pages::Dict{String, Function}
    extensions::Vector{OliveExtension}
    users::Dict{String, String}
    function OliveCore()
        pages = ["login" => div("login")]
    end
end
