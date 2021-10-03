module BenchRNN

using ..Utils: Utils, quick!
import Gaius
using BenchmarkTools

const CACHE = Ref{Any}()

function generate(; sizes = [1024, 2048], nsamples = 8)
    arrays = map(sizes) do n
        M = rand(n, n) ./ √n
        v0s = [randn(n) for _ in 1:nsamples]
        return (; M, v0s)
    end
    return (; sizes, arrays)
end

function rnn!(y, v, M, nsteps, mul! = Gaius.mul!)
    idx = eachindex(y, v)
    for _ in 1:nsteps
        mul!(y, M, v)
        @inline update(i) = @inbounds v[i] = tanh(y[i])
        Utils.foreach(update, idx; basesize = 256)
    end
end

function parallel_rnn!(ys, vs, M, nsteps)
    Utils.foreach(eachindex(ys, vs); basesize = 1) do i
        rnn!(ys[i], vs[i], M, nsteps)
    end
end

function setup(; nsteps = 100, kwargs...)
    (; sizes, arrays) = generate(; kwargs...)
    CACHE[] = arrays
    T = typeof(arrays)

    suite = BenchmarkGroup()
    for (i, n) in pairs(sizes)
        suite["n=$n"] = @benchmarkable(
            parallel_rnn!(ys, vs, M, $nsteps),
            setup = begin
                m = (CACHE[]::$T)[$i]
                M = m.M
                vs = map(copy, m.v0s)
                ys = map(similar, vs)
            end,
            samples = 100,
            seconds = 120,
            # samples = if Threads.nthreads() <= 2
            #     100
            # else
            #     BenchmarkTools.DEFAULT_PARAMETERS.samples
            # end,
            # seconds = if Threads.nthreads() <= 2
            #     120
            # else
            #     BenchmarkTools.DEFAULT_PARAMETERS.seconds
            # end,
        )
    end

    return suite
end

function clear()
    CACHE[] = nothing
end

warmup() = run(quick!(setup()))

end  # module
