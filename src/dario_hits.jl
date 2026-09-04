"""
    DarioHitsFile(file::Union{IOStream, AbstractString}; batch_size::Integer=10)

represents a `.root.hits` file given by MaGe's Dario output scheme. A `DarioHitsFile` can be
iterated or read to yield events, which contain data on energy depositions, i.e. hits.

A `DarioHitsFile` is also a Tables.jl compatible row table of events. `batch_size`
determines the number of events grouped into partitions when `Tables.partitions` is used.
To change the default of 10, see `DARIO_HITS_BATCH_SIZE`.
"""
struct DarioHitsFile
    stream::IOBuffer
    batch_size::Int

    function DarioHitsFile(stream::IOStream; batch_size=DARIO_HITS_BATCH_SIZE[])
        new(IOBuffer(mmap(stream)), batch_size)
    end
end

function DarioHitsFile(path::AbstractString; batch_size=DARIO_HITS_BATCH_SIZE[])
    if occursin(r".root.hits$", path)
        return DarioHitsFile(open(path); batch_size=batch_size)
    else
        throw(ArgumentError("$path is not a .root.hits file"))
    end
end

const DARIO_HITS_BATCH_SIZE = Ref(10)

const DarioHitsEventTuple = NamedTuple{
    (:eventnum, :primcount, :pos, :E, :time, :particleID, :trkID, :trkparentID, :volumeID),
    Tuple{
        Int32, Int32, Vector{SVector{3, Float32}}, Vector{Float32}, Vector{Float32},
        Vector{Int32}, Vector{Int32}, Vector{Int32}, Vector{String}
    }
}

# TODO: Add documentation for this ^

function Base.read(f::DarioHitsFile)
    eventnum, hitcount, primcount = map(s -> parse(Int32, s), split(readline(f.stream)))

    pos         = Vector{SVector{3, Float32}}(undef, hitcount)
    E           = Vector{            Float32}(undef, hitcount)
    time        = Vector{            Float32}(undef, hitcount)
    particleID  = Vector{              Int32}(undef, hitcount)
    trkID       = Vector{              Int32}(undef, hitcount)
    trkparentID = Vector{              Int32}(undef, hitcount)
    volumeID    = Vector{             String}(undef, hitcount)

    @inbounds for i in 1:hitcount
        x, y, z, e, t, pid, tid, tpid, vol = eachsplit(readline(f.stream))
        pos[i]         = SVector{3, Float32}(parse(Float32, x), parse(Float32, y), parse(Float32, z))
        E[i]           = parse(Float32, e)
        time[i]        = parse(Float32, t)
        particleID[i]  = parse(Int32, pid)
        trkID[i]       = parse(Int32, tid)
        trkparentID[i] = parse(Int32, tpid)
        volumeID[i]    = String(vol)
    end

    return DarioHitsEventTuple((
        eventnum, primcount, pos, E, time,
        particleID, trkID, trkparentID, volumeID
    ))
end

Base.eof(f::DarioHitsFile) = eof(f.stream)

function Base.iterate(f::DarioHitsFile, state = nothing)
    eof(f) && return nothing
    return read(f), nothing
end

Base.IteratorSize(::Type{DarioHitsFile}) = Base.SizeUnknown()
Base.IteratorEltype(::Type{DarioHitsFile}) = Base.HasEltype()
Base.eltype(::Type{DarioHitsFile}) = DarioHitsEventTuple

Tables.isrowtable(::Type{DarioHitsFile}) = true
Tables.schema(f::DarioHitsFile) = Tables.Schema(eltype(f))

Tables.partitions(f::DarioHitsFile) = Iterators.partition(f, f.batch_size)
