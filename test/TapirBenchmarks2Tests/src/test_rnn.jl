module TestRNN

import LinearAlgebra
using TapirBenchmarks2.BenchRNN: rnn!
using Test

function compare_mul_rnn(n; g = 1, nsteps = 5)
    M = randn(n, n) .* (g ./ √n)
    v0 = randn(n)
    y0 = zero(v0)
    v1 = copy(v0)
    y1 = zero(v1)

    rnn!(y0, v0, M, nsteps)
    rnn!(y1, v1, M, nsteps, LinearAlgebra.mul!)

    return (; v0, v1, y0, y1, M)
end

function test_mul_rnn(n; kwargs...)
    (; v0, v1) = compare_mul_rnn(n; kwargs...)
    @test v0 ≈ v1
end

function test_mul_rnn()
    @testset for n in [100, 500, 1000]
        test_mul_rnn(n)
    end
end

end  # module
