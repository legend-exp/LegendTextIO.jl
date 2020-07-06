# This file is a part of LegendDataTypes.jl, licensed under the MIT License (MIT).

function read_geant4_ascii end
export read_geant4_ascii


struct Geant4CSVInput <: AbstractLegendInput
    stream::BufferedInputStream
end

export Geant4CSVInput

Base.open(filename::AbstractString, ::Type{Geant4CSVInput}) =
    Geant4CSVInput(BufferedInputStream(open(filename)))

Base.close(input::Geant4CSVInput) = close(input.stream)


function Base.getindex(input::Geant4CSVInput, ::Colon)
    read(input)
end


function Base.read(input::Geant4CSVInput)
    input_stream = input.stream
    title_expr = r"""^#title (.+)$"""
    fsep_expr = r"""^#separator ([0-9]+)$"""
    vsep_expr = r"""^#vector_separator ([0-9]+)$"""
    colspec_expr = r"""^#column ([^ ]+) ([^ ]+)$"""

    readline(input_stream) == "#class tools::wcsv::ntuple" || throw(ErrorException("Input doesn't seem to be Geant4 ntuple CSV data"))

    title = _match_or_throw(title_expr, readline(input_stream))[1]
    separator = Char(parse(Int, _match_or_throw(fsep_expr, readline(input_stream))[1]))
    vector_separator = Char(parse(Int, _match_or_throw(vsep_expr, readline(input_stream))[1]))

    @debug "File header information: " title separator vector_separator

    cols = Dict{String,Int}()
    ncols::Int = 0
    reading_header::Bool = true
    while reading_header
        c = Char(BufferedStreams.peek(input_stream))
        if c == '#'
            colname = _match_or_throw(colspec_expr, readline(input_stream))[2]
            ncols += 1
            cols[colname] = ncols
        else
            reading_header = false
        end
    end
    @assert ncols == length(cols)

    @debug "Columns in file: " cols length(cols)

    colno_evtno = cols["Event#"]
    colno_detno = get(cols, "Detector_ID", 0)
    colno_thit = get(cols, "Time", 0)
    colno_edep = cols["EnergyDeposit"]
    colno_x = cols["X"]
    colno_y = cols["Y"]
    colno_z = cols["Z"]

    @debug "Colums numbers:" colno_evtno colno_detno colno_thit colno_edep colno_x colno_y colno_z

    colno_xyz = colno_x:colno_x+2
    colno_y == colno_xyz[2] && colno_z == colno_xyz[3] || throw(ErrorException("Expected columns Y and Z directly after X"))

    @debug readline(input_stream)

    data = readdlm(input_stream, separator, Float64)::Matrix{Float64}
    data_ncols = size(data, 2)
    data_ncols == ncols || throw(ErrorException("Expected $ncols columns, but data has $data_ncols columns"))

    evtno = Int32.(data[:, colno_evtno])
    edep = Float32.(data[:, colno_edep]) .* u"keV"
    pos_mat = Float32.(data[:, colno_xyz]) .* u"mm"
    pos = nestedview(Array(pos_mat'), SVector{3})

    detno = colno_detno != 0 ? Int32.(data[:, colno_detno]) : fill!(similar(evtno), 1)
    thit = (colno_thit != 0 ? Float32.(data[:, colno_thit]) : fill!(similar(evtno, Float32), NaN)) .* u"s"

    hits = DetectorHits((
        evtno = evtno,
        detno = detno,
        thit = thit,
        edep = edep,
        pos = pos,
    ))

    events = group_by_evtno(hits)
end
