JULIA ?= julia-tapir
JULIA_CMD ?= $(JULIA) --color=yes --startup-file=no

BENCHMARKS = $(wildcard bench_*.jl)
BENCHMARK_TARGETS = $(patsubst %.jl, build/%/.done, $(BENCHMARKS))

.PHONY: all benchmark

all: benchmark

benchmark: $(BENCHMARK_TARGETS)
$(BENCHMARK_TARGETS): build/%/.done:
	@mkdir -p build/$*
	git show --format='format:%H' --no-patch > build/$*/git-rev-sha1
	git show --format='format:%T' --no-patch > build/$*/git-tree-sha1
	JULIA_PROJECT=$(PWD)/../../../environments/default \
	$(JULIA_CMD) run_benchmarks.jl $*.jl build/$*
	touch $@

.PHONY: clean
clean:
	rm -f build/*/.done
