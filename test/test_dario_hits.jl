const hitsfile = joinpath(legend_test_data_path(), "data", "mage", "dario", "test.root.hits")

@testset "DarioHitsFile" begin

    @testset "Construction" begin
        @test DarioHitsFile(hitsfile) isa DarioHitsFile

        @test DarioHitsFile(open(hitsfile)) isa DarioHitsFile

        @test all(DarioHitsFile(open(hitsfile)) .== DarioHitsFile(hitsfile))

        # Not a .root.hits file
        @test_throws ArgumentError DarioHitsFile("../Project.toml")
    end

    @testset "Parsing" begin
        f = DarioHitsFile(hitsfile)

        e1 = read(f)
        @test e1.eventnum == 624
        @test e1.primcount == 3

        @test all(e1.pos[1]     .≈ (1.60738, -2.07026, -201.594))
        @test e1.E[1]            ≈ 0.1638
        @test e1.time[1]        == 0
        @test e1.particleID[1]  == 22
        @test e1.trkID[1]       == 187
        @test e1.trkparentID[1] == 4
        @test e1.volumeID[1]    == "physiDet"

        @test all(e1.pos[end]     .≈ (1.60714, -2.06979, -201.594))
        @test e1.E[end]            ≈ 1.09771
        @test e1.time[end]        == 0
        @test e1.particleID[end]  == 11
        @test e1.trkID[end]       == 269
        @test e1.trkparentID[end] == 235
        @test e1.volumeID[end]    == "physiDet"

        e2 = read(f)
        @test e2.eventnum == 632
        @test e2.primcount == 3

        @test all(e2.pos[1]     .≈ (-1.16375, 1.16453, -197.114))
        @test e2.E[1]            ≈ 0.01478
        @test e2.time[1]        == 0
        @test e2.particleID[1]  == 22
        @test e2.trkID[1]       == 8
        @test e2.trkparentID[1] == 5
        @test e2.volumeID[1]    == "physiDet"

        @test all(e2.pos[end]     .≈ (-1.16539, 1.16754, -197.116))
        @test e2.E[end]            ≈ 6.3739
        @test e2.time[end]        == 0
        @test e2.particleID[end]  == 11
        @test e2.trkID[end]       == 108
        @test e2.trkparentID[end] == 101
        @test e2.volumeID[end]    == "physiDet"

        ef = collect(f)[end]
        @test ef.eventnum == 999851
        @test ef.primcount == 4

        @test all(ef.pos[1]     .≈ (-1.2325, -2.44103, -196.814))
        @test ef.E[1]            ≈ 0.07764
        @test ef.time[1]        == 0
        @test ef.particleID[1]  == 22
        @test ef.trkID[1]       == 9
        @test ef.trkparentID[1] == 6
        @test ef.volumeID[1]    == "physiDet"

        @test all(ef.pos[end]     .≈ (-1.18915, -2.28214, -198.958))
        @test ef.E[end]            ≈ 8.4419
        @test ef.time[end]        == 0
        @test ef.particleID[end]  == 11
        @test ef.trkID[end]       == 165
        @test ef.trkparentID[end] == 16
        @test ef.volumeID[end]    == "physiDet"
    end

    @testset "Iteration" begin
        f = DarioHitsFile(hitsfile)
        T = typeof(first(DarioHitsFile(hitsfile)))

        for e in DarioHitsFile(hitsfile)
            @test e == read(f)

            @test typeof(e) == T
        end

        

        @test Base.IteratorSize(DarioHitsFile) == Base.SizeUnknown()

        @test Base.IteratorEltype(DarioHitsFile) == Base.HasEltype()

        @test eltype(DarioHitsFile(hitsfile)) <: NamedTuple
        @test eltype(DarioHitsFile(hitsfile)) == T
    end

    @testset "File Interface" begin
        f = DarioHitsFile(hitsfile)

        @test eof(f) == false

        collect(f)

        @test eof(f) == true
    end

    @testset "Tables Interface" begin
        f = DarioHitsFile(hitsfile)

        @test Tables.istable(typeof(f))

        @test Tables.rowaccess(typeof(f))
        @test Tables.rows(f) === f

        ctbl = columntable(f)
        @test ctbl.eventnum == [
            624, 632, 1150, 1266, 1447, 1488, 1559, 1646, 2068, 2075, 2246,
            2467, 2619, 3053, 3430, 4388, 4721, 5118, 5395, 5484, 53276, 999851
        ]

        rtbl = rowtable(DarioHitsFile(hitsfile))
        @test first(rtbl) == first(DarioHitsFile(hitsfile))
    end

    @testset "Partitions" begin
        @test LegendTextIO.DARIO_HITS_BATCH_SIZE[] == 10

        LegendTextIO.DARIO_HITS_BATCH_SIZE[] = 3

        @test LegendTextIO.DARIO_HITS_BATCH_SIZE[] == 3

        p1 = collect(Tables.partitions(DarioHitsFile(hitsfile)))

        LegendTextIO.DARIO_HITS_BATCH_SIZE[] = 10

        p2 = collect(Tables.partitions(DarioHitsFile(hitsfile, batch_size=3)))
        p3 = collect(Iterators.partition(DarioHitsFile(hitsfile), 3))

        @test length(p1) == length(p2) == length(p3)
        @test eltype(p1) == eltype(p2) == eltype(p3)

        @test eltype(p1) <: Vector{<:NamedTuple}

        for (tbl1, tbl2, tbl3) in zip(p1, p2, p3)
            @test tbl1 == tbl2 == tbl3
        end
    end
end
