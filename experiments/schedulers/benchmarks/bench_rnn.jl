using Pkg
Pkg.activate(ENV["JULIA_PROJECT"])

import TapirSchedulers  # workaround a world-age issue

import Gaius
@show Gaius.TAPIR_SCHEDULER_CONFIG

using TapirBenchmarks2
@info "START: warmup"
TapirBenchmarks2.BenchRNN.warmup()
@info "DONE: warmup"
SUITE = TapirBenchmarks2.BenchRNN.setup()
