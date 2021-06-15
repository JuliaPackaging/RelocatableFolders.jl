using RelocatableFolders, Test

module M

using RelocatableFolders

const DIR = @path "path"
const FILE = @path joinpath("path", "file.jl")

end

@testset "RelocatableFolders" begin
    tests = function ()
        @test isfile(M.FILE)
        @test read(M.FILE, String) == "# file.jl"

        @test isdir(M.DIR)
        @test sort(readdir(M.DIR)) == ["file.jl", "subfolder", "text.md"]
        @test readdir(joinpath(M.DIR, "subfolder")) == ["other.jl"]

        @test read(joinpath(M.DIR, "file.jl"), String) == "# file.jl"
        @test read(joinpath(M.DIR, "text.md"), String) == "text.md"
        @test read(joinpath(M.DIR, "subfolder", "other.jl"), String) == "# other.jl"

        @test length(M.DIR.files) == 3
        @test M.DIR.mod == M
        @test M.DIR.path == joinpath(@__DIR__, "path")
    end
    from, to = joinpath.(Ref(@__DIR__), ("path", "moved"))
    try
        tests()
        @test String(M.DIR) == joinpath(@__DIR__, "path")
        @test String(M.FILE) == joinpath(@__DIR__, "path", "file.jl")

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
        let file = String(M.FILE)
            @test isfile(file)
            @test file != joinpath(@__FILE__, "path", "file.jl")
        end
        tests()
        @test String(M.DIR) != joinpath(@__DIR__, "path")
        @test String(M.FILE) != joinpath(@__DIR__, "path", "file.jl")

        # Return the referenced folder `DIR`.
        @test !isdir(from)
        @test isdir(to)
        mv(to, from)
        @test isdir(from)
        @test !isdir(to)

        tests()
        @test String(M.DIR) == joinpath(@__DIR__, "path")
        @test String(M.FILE) == joinpath(@__DIR__, "path", "file.jl")
    finally
        isdir(from) || mv(to, from)
    end
end
