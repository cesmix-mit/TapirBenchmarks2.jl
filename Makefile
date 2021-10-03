JULIA = julia-tapir
JULIA_CMD = $(JULIA) --startup-file=no --color=yes

SHOW_MRKDOWN = JULIA_LOAD_PATH=@stdlib $(JULIA_CMD) --compile=min -O0 \
-e 'using Markdown; display(Markdown.parse(read(ARGS[1], String)))'

export JULIA_PRECOMPILE=0

.PHONY: help refresh* precompile* test* update* resolve instantiate

help:
	@$(SHOW_MRKDOWN) make-help.md

precompile: \
precompile-default precompile-depthfirst precompile-workstealing

precompile-default: instantiate
	JULIA_LOAD_PATH=@:@stdlib JULIA_PROJECT=environments/$* \
	$(JULIA_CMD) -e 'using Pkg; Pkg.precompile()'

precompile-depthfirst precompile-workstealing: \
precompile-%: \
precompile-default \
environments/%/Project.toml \
environments/%/Manifest.toml
	JULIA_LOAD_PATH=@ JULIA_PROJECT=environments/$* \
	$(JULIA_CMD) -e 'using TapirBenchmarks2'

test: \
test-default test-depthfirst test-workstealing

test-default test-depthfirst test-workstealing: \
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

refresh: \
refresh-depthfirst refresh-workstealing

refresh-depthfirst refresh-workstealing: \
refresh-%: \
environments/%/Project.toml \
environments/%/Manifest.toml

resolve:
	JULIA_PRECOMPILE=0 JULIA_LOAD_PATH=@:@stdlib JULIA_PROJECT=environments/default \
	$(JULIA_CMD) -e 'using Pkg; Pkg.resolve()'

environments/workstealing/Project.toml \
environments/depthfirst/Project.toml: \
environments/%/Project.toml: environments/default/Project.toml
	cp $< $@

environments/workstealing/Manifest.toml \
environments/depthfirst/Manifest.toml: \
environments/%/Manifest.toml: environments/default/Manifest.toml
	cp $< $@
