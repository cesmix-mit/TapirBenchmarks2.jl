using BenchmarkTools
using DataFrames
using DisplayAs
using Glob
using PkgBenchmark
using Plots
using VegaLite
using FileIO

resultdir = joinpath(@__DIR__, "benchmarks/build/bench_rnn")
results = map(PkgBenchmark.readresults, sort!(readdir(glob"result-*.json", resultdir)))

table_raw =
    Iterators.map(results) do r
        scheduler = Symbol(basename(r.benchmarkconfig.env["JULIA_PROJECT"]))
        nthreads = parse(Int, r.benchmarkconfig.env["JULIA_NUM_THREADS"])
        Iterators.map(leaves(r.benchmarkgroup)) do ((prob,), trial)
            @assert startswith(prob, "n=")
            n = parse(Int, prob[length("n=")+1:end])
            (; nthreads, scheduler, n, trial)
        end
    end |>
    Iterators.flatten |>
    collect

df_raw = DataFrame(table_raw)
#-


begin
    df_tmp = select(df_raw, Not(:trial))
    df_tmp[!, :minimum] = map(trial -> minimum(trial).time, df_raw.trial)
    df_tmp[!, :median] = map(trial -> median(trial).time, df_raw.trial)
    df_tmp[!, :mean] = map(trial -> mean(trial).time, df_raw.trial)
    df_tmp[!, :memory] = map(trial -> trial.memory, df_raw.trial)
    df_stats = stack(
        df_tmp,
        [:minimum, :median, :mean],
        variable_name = :time_stat,
        variable_eltype = Symbol,
        value_name = :time_ns,
    )
end
#-

@vlplot(
    :line,
    x = :n,
    y = :time_ns,
    row = :nthreads,
    color = :scheduler,
    data = df_stats[(df_stats.time_stat .== :minimum) .& (df_stats.nthreads .∈ Ref((8, 16))), :],
)


df_speedup = let
    idx = df_stats.time_stat .== :minimum
    # idx = df_stats.time_stat .== :median
    # idx = df_stats.time_stat .== :mean
    df1 = select(df_stats[idx, :], [:n, :scheduler, :nthreads, :time_ns])
    df2 = combine(groupby(df1, :n)) do g
        idx = (g.nthreads .== 1) .& (g.scheduler .== :default)
        t1 = only(g[idx, :]).time_ns
        (; g.nthreads, g.scheduler, speedup = t1 ./ g.time_ns)
    end
end
#-

plt_simple_speedup = @vlplot(
    :line,
    x = {:nthreads, title = "Number of threads"},
    y = {:speedup, title = "Speedup (Tₛ/T₁)"},
    # row = :n,
    color = :scheduler,
    data = df_speedup[(df_speedup.nthreads .<= 8) .& (df_speedup.n .== 2048), :],
)

save(joinpath(resultdir, "simple_speedup.svg"), plt_simple_speedup)
save(joinpath(resultdir, "simple_speedup.png"), plt_simple_speedup)

plt_simple_speedup

plt_speedup = @vlplot(
    :line,
    # mark = {:line, point = true},
    x = :nthreads,
    y = :speedup,
    row = :n,
    color = :scheduler,
    # shape = :scheduler,
    strokeDash = :scheduler,
    data = df_speedup,
)

save(joinpath(resultdir, "speedup.svg"), plt_speedup)
save(joinpath(resultdir, "speedup.png"), plt_speedup)

plt_speedup
