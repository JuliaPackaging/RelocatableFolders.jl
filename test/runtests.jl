using RelocatableFolders, Test

module M

using RelocatableFolders

const DIR = folder"path"

end

@testset "RelocatableFolders" begin
    tests = function ()
        @test isdir(M.DIR)
        @test sort(readdir(M.DIR)) == ["file.jl", "subfolder", "text.md"]
        @test readdir(joinpath(M.DIR, "subfolder")) == ["other.jl"]

        @test read(joinpath(M.DIR, "file.jl"), String) == "# file.jl"
        @test read(joinpath(M.DIR, "text.md"), String) == "text.md"
        @test read(joinpath(M.DIR, "subfolder", "other.jl"), String) == "# other.jl"

        @test length(M.DIR.files) == 3
        @test M.DIR.mod == M
        @test M.DIR.path == joinpath(@__DIR__, "path")
        @test M.DIR.hash == "2d8f4983bd98b6156e6e2917311c71120dd00609"
    end
    from, to = joinpath.(Ref(@__DIR__), ("path", "moved"))
    try
        tests()
        @test String(M.DIR) == joinpath(@__DIR__, "path")

        # Remove the referenced folder `DIR`.
        @test isdir(from)
        @test !isdir(to)
        mv(from, to)
        @test isdir(to)
        @test !isdir(from)

        let path = String(M.DIR)
            rm(path; recursive = true)
            @test !isdir(path)
        end
        tests()
        @test String(M.DIR) != joinpath(@__DIR__, "path")

        # Return the referenced folder `DIR`.
        @test !isdir(from)
        @test isdir(to)
        mv(to, from)
        @test isdir(from)
        @test !isdir(to)

        tests()
        @test String(M.DIR) == joinpath(@__DIR__, "path")
    finally
        isdir(from) || mv(to, from)
    end
end
