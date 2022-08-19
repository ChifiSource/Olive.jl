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
    "background-color" => "white")
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
    s = Style(".material-symbols-outlined", cursor = "pointer",
    "font-size" => "100pt")
    s:"hover":["color" => "orange", "transform" => "scale(1.1)"]
    s
end
function cellnumber_style()
    st = Style("h1.cell_number", color = "lightblue")
    st["font-family"] = "'Rubik', sans-serif"
    st
end

function olivesheet()
    st = ToolipsDefaults.sheet("olivestyle", dark = false)
    bdy = Style("body", "background-color" => "white")
    push!(st, google_icons(),
    cell_in(), iconstyle(), cellnumber_style(), hdeps_style(),
    usingcell_style(), outputcell_style(), inputcell_style(), bdy)
    st
end

function olivesheetdark()
    st = ToolipsDefaults.sheet("olivestyle", dark = true)
    bdy = Style("body", "background-color" => "#121212", "transition" => ".8s")
    st[:children]["div"]["background-color"] = "#370083"
    push!(st, google_icons(),
    cell_in(), iconstyle(), cellnumber_style(), hdeps_style(),
    usingcell_style(), outputcell_style(), inputcell_style(), bdy)
    st
    st
end

mutable struct OliveExtension <: Servable

end

mutable struct OliveCore <: ServerExtension
    pages::Vector{Servable}
    sessions::Dict{String, Pair{Vector{Any}, String}}
    extensions::Vector{OliveExtension}
    users::Dict{String, Vector{Servable}}
    function OliveCore()
        pages = ["login" => div("login")]
    end
end
