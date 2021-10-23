JULIA = julia-tapir
JULIA_CMD = $(JULIA) --startup-file=no --color=yes

NONDEFAULT_SCHEDULERS = workstealing depthfirst constantpriority randompriority
SCHEDULERS = default $(NONDEFAULT_SCHEDULERS)

SHOW_MRKDOWN = JULIA_LOAD_PATH=@stdlib $(JULIA_CMD) --compile=min -O0 \
-e 'using Markdown; display(Markdown.parse(read(ARGS[1], String)))'

export JULIA_PRECOMPILE=0

.PHONY: help refresh* precompile* test* update* resolve instantiate

help:
	@$(SHOW_MRKDOWN) make-help.md

precompile: $(patsubst %, precompile-%, $(SCHEDULERS))

precompile-default: instantiate
	JULIA_LOAD_PATH=@:@stdlib JULIA_PROJECT=environments/$* \
	$(JULIA_CMD) -e 'using Pkg; Pkg.precompile()'

$(patsubst %, precompile-%, $(NONDEFAULT_SCHEDULERS)): \
precompile-%: \
precompile-default \
environments/%/Project.toml \
environments/%/Manifest.toml
	JULIA_LOAD_PATH=@ JULIA_PROJECT=environments/$* \
	$(JULIA_CMD) -e 'using TapirBenchmarks2'

test: $(patsubst %, test-%, $(SCHEDULERS))

$(patsubst %, test-%, $(SCHEDULERS)): \
test-%: \
instantiate
	JULIA_LOAD_PATH=@ JULIA_PROJECT=environments/$* \
	$(JULIA_CMD) test/runtests.jl

instantiate:
	JULIA_PRECOMPILE=0 JULIA_LOAD_PATH=@:@stdlib JULIA_PROJECT=environments/default \
	$(JULIA_CMD) -e 'using Pkg; Pkg.instantiate()'

update: update-default
	$(MAKE) refresh

update-default:
	JULIA_PRECOMPILE=0 JULIA_LOAD_PATH=@:@stdlib JULIA_PROJECT=environments/default \
	$(JULIA_CMD) -e 'using Pkg; Pkg.update()'

refresh: $(patsubst %, refresh-%, $(NONDEFAULT_SCHEDULERS))

$(patsubst %, refresh-%, $(NONDEFAULT_SCHEDULERS)): \
refresh-%: \
environments/%/Project.toml \
environments/%/Manifest.toml

resolve:
	JULIA_PRECOMPILE=0 JULIA_LOAD_PATH=@:@stdlib JULIA_PROJECT=environments/default \
	$(JULIA_CMD) -e 'using Pkg; Pkg.resolve()'

$(patsubst %, environments/%/Project.toml, $(NONDEFAULT_SCHEDULERS)): \
environments/%/Project.toml: environments/default/Project.toml
	mkdir -pv environments/$*
	cp $< $@

$(patsubst %, environments/%/Manifest.toml, $(NONDEFAULT_SCHEDULERS)): \
environments/%/Manifest.toml: environments/default/Manifest.toml
	mkdir -pv environments/$*
	cp $< $@
