script, resultdir = ARGS

if length(ARGS) >= 3
    threads = include_string(@__MODULE__, ARGS[3])
else
    # threads = 1:32
    threads = [1, 32, 16, 8, 24, 28, 20, 12]
    union!(threads, 1:32)
    # threads = [1, 8, 16]
    # threads = [24, 32]
end

using PkgBenchmark

resultdir = abspath(resultdir)
mkpath(resultdir)

SCHEDULERS = ["default", "workstealing", "depthfirst", "constantpriority", "randompriority"]

for n in threads
    for scheduler in SCHEDULERS
        project = joinpath(@__DIR__, "../../../environments", scheduler)
        @assert isdir(project)

        @info "Benchmarking `$scheduler` scheduler with `JULIA_NUM_THREADS=$n`"
        resultname = "result-$scheduler-$n"
        resultfile = joinpath(resultdir, "$resultname.json")
        group = benchmarkpkg(
            @__DIR__,
            BenchmarkConfig(
                env = Dict(
                    "JULIA_EXCLUSIVE" => "1",
                    "JULIA_PROJECT" => project,  # specifies scheduler via preference
                    "JULIA_NUM_THREADS" => string(n),
                ),
            ),
            resultfile = resultfile,
            script = abspath(script),
        )
        PkgBenchmark.export_markdown(joinpath(resultdir, "$resultname.md"), group)
    end
end
