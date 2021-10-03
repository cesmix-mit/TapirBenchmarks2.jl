# `make` targets

## `help`
Print help.

## `test`, `test-default`, `test-depthfirst`, `test-workstealing`
Run tests in an isolated environment.

## `precompile`, `precompile-default`, `precompile-depthfirst`, `precompile-workstealing`
Precompile packages in each environment. It takes care of the difference in
compile-time preferences.

## `refresh`, `refresh-depthfirst`, `refresh-workstealing`
Synchronize environments; i.e., copy
`environments/default/{Project,Manifest}.toml` to
`environments/{depthfirst,workstealing}/`.
