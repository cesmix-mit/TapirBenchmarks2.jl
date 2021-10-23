module Utils

import Gaius
import Folds
using Base.Experimental: Tapir
using BenchmarkTools: Benchmark, BenchmarkGroup
using FoldsTapir: TapirEx
using TapirSchedulers:
    ConstantPriorityTaskGroup,
    DepthFirstTaskGroup,
    RandomPriorityTaskGroup,
    WorkStealingTaskGroup,
    rollback_priority

if Gaius.TAPIR_SCHEDULER_CONFIG == "default"
    const taskgroup = Tapir.taskgroup
elseif Gaius.TAPIR_SCHEDULER_CONFIG == "workstealing"
    const taskgroup = WorkStealingTaskGroup
elseif Gaius.TAPIR_SCHEDULER_CONFIG == "depthfirst"
    const taskgroup = DepthFirstTaskGroup
elseif Gaius.TAPIR_SCHEDULER_CONFIG == "constantpriority"
    const taskgroup = ConstantPriorityTaskGroup
elseif Gaius.TAPIR_SCHEDULER_CONFIG == "randompriority"
    const taskgroup = RandomPriorityTaskGroup
else
    error("unknown scheduler: ", Gaius.TAPIR_SCHEDULER_CONFIG)
end

function foreach(f::F, xs; basesize = nothing) where {F}
    rollback_priority() do
        Folds.foreach(f, xs, TapirEx(; taskgroup, basesize))
    end
end

function set_quick_params!(bench)
    bench.params.seconds = 0.001
    bench.params.evals = 1
    bench.params.samples = 1
    bench.params.gctrial = false
    bench.params.gcsample = false
    return bench
end

foreach_benchmark(f!, bench::Benchmark) = f!(bench)
function foreach_benchmark(f!, group::BenchmarkGroup)
    for x in values(group)
        foreach_benchmark(f!, x)
    end
end

function quick!(suite)
    foreach_benchmark(set_quick_params!, suite)
    return suite
end

end  # module
