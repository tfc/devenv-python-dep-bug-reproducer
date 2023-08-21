# Devenv dependency bug reproducer

This repository demonstrates the following problem:

We have a standalone python app in `./standalone_app` which depends on
`psycopg2` with version constraint `>=2.9.6`.

This app is then included in the `packages` attribute of a devenv shell.
The devenv shell also has `languages.python` enabled with an additional
requirement of `psycopg2==2.9.5`.

## What happens:

Error in the log:

```sh
$ nix develop --impure
Collecting psycopg2==2.9.5
  Using cached psycopg2-2.9.5.tar.gz (384 kB)
  Preparing metadata (setup.py) ... done
Installing collected packages: psycopg2
  DEPRECATION: psycopg2 is being installed using the legacy 'setup.py install' method, because it does not have a 'pyproject.toml' and the 'wheel' package is not installed. pip 23.1 will enforce this behaviour change. A possible replacement is to enable the '--use-pep517' option. Discussion can be found at https://github.com/pypa/pip/issues/8559
  Running setup.py install for psycopg2 ... done
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
standalone-app 1.0.0 requires psycopg2>=2.9.6, but you have psycopg2 2.9.5 which is incompatible.
Successfully installed psycopg2-2.9.5

[notice] A new release of pip is available: 23.0.1 -> 23.2.1
[notice] To update, run: pip install --upgrade pip
(devenv) (venv)
```

## Expected:

Devenv should not care about the dependencies of `standalone_app` and just put
it into the `$PATH` environment, without trying to manage its deps.
