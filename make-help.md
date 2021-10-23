# `make` targets

## `help`
Print help.

## `test`, `test-$SCHEDULER`
Run tests in an isolated environment.

## `precompile`, `precompile-$SCHEDULER`
Precompile packages in each environment. It takes care of the difference in
compile-time preferences.

## `refresh`, `refresh-$NONDEFAULT_SCHEDULER`
Synchronize environments; i.e., copy
`environments/default/{Project,Manifest}.toml` to
`environments/$NONDEFAULT_SCHEDULER/`.

## Schedulers

In above targets, `$SCHEDULER` and `$NONDEFAULT_SCHEDULER` mean:

* `NONDEFAULT_SCHEDULER = workstealing depthfirst nondepthfirst`
* `SCHEDULER = $NONDEFAULT_SCHEDULER default`
