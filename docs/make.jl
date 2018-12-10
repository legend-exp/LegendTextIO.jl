# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [fixdoctests]
#
# for local builds.

using Documenter
using LegendTextIO

makedocs(
    sitename = "LegendTextIO",
    modules = [LegendTextIO],
    format = :html,
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
        "LICENSE" => "LICENSE.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
    html_prettyurls = !("local" in ARGS),
    html_canonical = "https://legend-exp.github.io/LegendTextIO.jl/stable/",
)

deploydocs(
    repo = "github.com/legend-exp/LegendTextIO.jl.git"
)
