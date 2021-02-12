# This file is a part of LegendTextIO.jl, licensed under the MIT License (MIT).

__precompile__(true)

module LegendTextIO

using DelimitedFiles

using ArraysOfArrays
using BufferedStreams
using CSV
using LegendDataTypes
using RadiationDetectorSignals
using StaticArrays
using Unitful

using RadiationDetectorSignals: group_by_evtno

include("util.jl")
include("geant4_csv.jl")

## .root.hit files

import Base, Tables

using Mmap: mmap
using Parsers

export RootHitFile

include("RootHitFiles.jl")

end # module
