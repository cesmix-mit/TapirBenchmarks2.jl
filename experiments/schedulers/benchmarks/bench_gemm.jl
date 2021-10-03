using Pkg
Pkg.activate(ENV["JULIA_PROJECT"])

import Gaius
@show Gaius.TAPIR_SCHEDULER_CONFIG

using TapirBenchmarks2
@info "START: warmup"
TapirBenchmarks2.BenchGEMM.warmup()
@info "DONE: warmup"
SUITE = TapirBenchmarks2.BenchGEMM.setup()
