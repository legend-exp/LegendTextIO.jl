# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [nonstrict] [fixdoctests]
#
# for local builds.

using Documenter
using LegendTextIO

# Doctest setup
DocMeta.setdocmeta!(
    LegendTextIO,
    :DocTestSetup,
    :(using LegendTextIO);
    recursive=true,
)

makedocs(
    sitename = "LegendTextIO",
    modules = [LegendTextIO],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://legend-exp.github.io/LegendTextIO.jl/stable/"
    ),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
        "LICENSE" => "LICENSE.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
    linkcheck = !("nonstrict" in ARGS),
    strict = !("nonstrict" in ARGS),
)

deploydocs(
    repo = "github.com/legend-exp/LegendTextIO.jl.git",
    forcepush = true,
    push_preview = true,
)
