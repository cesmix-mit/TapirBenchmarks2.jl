module BenchGEMM

using ..Utils: quick!
import Gaius
using BenchmarkTools

const CACHE = Ref{Any}()

function generate(; sizes = [128, 448, 512, 1024])
    matrices = map(sizes) do n
        A = rand(n, n)
        B = rand(n, n)
        C = zeros(n, n)
        return (; A, B, C)
    end
    return (; sizes, matrices)
end

function setup(; kwargs...)
    (; sizes, matrices) = generate(; kwargs...)
    CACHE[] = matrices
    T = typeof(matrices)

    suite = BenchmarkGroup()
    for (i, n) in pairs(sizes)
        suite["n=$n"] = @benchmarkable(
            Gaius.mul!(C, A, B),
            setup = begin
                m = (CACHE[]::$T)[$i]
                A = m.A
                B = m.B
                C = m.C
            end,
        )
    end

    return suite
end

function clear()
    CACHE[] = nothing
end

warmup() = run(quick!(setup()))

end  # module
