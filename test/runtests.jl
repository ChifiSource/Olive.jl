using Test
using Olive

mkdir("testdir")

Olive.setup_olive(Olive.LOGGER, "testdir")
Olive.start(path = "testdir")

@testset "basic olive start test" begin
    ret = Olive.Toolips.get("127.0.0.1":8000)
    @test length(ret) > 1
end

rm("testdir", force = true, recursive = true)