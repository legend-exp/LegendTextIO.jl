@testset "RootHitFile" begin

    @testset "Construction" begin
        @test RootHitFile("test.root.hits") isa RootHitFile

        @test RootHitFile(open("test.root.hits")) isa RootHitFile

        @test all(RootHitFile(open("test.root.hits")) .== RootHitFile("test.root.hits"))

        # Not a .root.hits file
        @test_throws ArgumentError RootHitFile("../Project.toml")
    end

    @testset "Parsing" begin
        f = RootHitFile("test.root.hits")

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
        @test ef.eventnum == 1559
        @test ef.primcount == 5

        @test all(ef.pos[1]     .≈ (-0.109196, 2.10771, -196.751))
        @test ef.E[1]            ≈ 0.03819
        @test ef.time[1]        == 0
        @test ef.particleID[1]  == 22
        @test ef.trkID[1]       == 10
        @test ef.trkparentID[1] == 7
        @test ef.volumeID[1]    == "physiDet"

        @test all(ef.pos[end]     .≈ (-1.02351, 2.28199, -198.087))
        @test ef.E[end]            ≈ 9.71922
        @test ef.time[end]        == 0
        @test ef.particleID[end]  == 11
        @test ef.trkID[end]       == 111
        @test ef.trkparentID[end] == 16
        @test ef.volumeID[end]    == "physiDet"
    end

    @testset "Iteration" begin
        f = RootHitFile("test.root.hits")
        T = typeof(first(RootHitFile("test.root.hits")))

        for e in RootHitFile("test.root.hits")
            @test e == read(f)

            @test typeof(e) == T
        end

        

        @test Base.IteratorSize(RootHitFile) == Base.SizeUnknown()

        @test Base.IteratorEltype(RootHitFile) == Base.HasEltype()

        @test eltype(RootHitFile("test.root.hits")) <: NamedTuple
        @test eltype(RootHitFile("test.root.hits")) == T
    end

    @testset "File Interface" begin
        f = RootHitFile("test.root.hits")

        @test eof(f) == false

        collect(f)

        @test eof(f) == true
    end

    @testset "Tables Interface" begin
        f = RootHitFile("test.root.hits")

        @test Tables.istable(typeof(f))

        @test Tables.rowaccess(typeof(f))
        @test Tables.rows(f) === f

        ctbl = columntable(f)
        @test ctbl.eventnum == [624, 632, 1150, 1266, 1447, 1488, 1559]

        rtbl = rowtable(RootHitFile("test.root.hits"))
        @test first(rtbl) == first(RootHitFile("test.root.hits"))
    end

    @testset "Partitions" begin
        @test LegendTextIO.DEFAULTS.root_hits_batch_size == 10

        LegendTextIO.DEFAULTS.root_hits_batch_size = 3

        @test LegendTextIO.DEFAULTS.root_hits_batch_size == 3

        p1 = collect(Tables.partitions(RootHitFile("test.root.hits")))

        LegendTextIO.DEFAULTS.root_hits_batch_size = 10

        p2 = collect(Tables.partitions(RootHitFile("test.root.hits", batch_size=3)))
        p3 = collect(Iterators.partition(RootHitFile("test.root.hits"), 3))

        @test length(p1) == length(p2) == length(p3)
        @test eltype(p1) == eltype(p2) == eltype(p3)

        @test eltype(p1) <: Vector{<:NamedTuple}

        for (tbl1, tbl2, tbl3) in zip(p1, p2, p3)
            @test tbl1 == tbl2 == tbl3
        end
    end
end
