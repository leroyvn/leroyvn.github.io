+++
title = "Conda Workflow"
date = "2021-06-21T11:44:22+02:00"

#
# Set menu to "main" to add this page to
# the main menu on top of the page
#
menu = "main"

#
# description is optional
#
# description = "An optional description for SEO. If not provided, an automatically created summary will be used."

#
# tags are optional
#
# tags = ["markdown","syntax",]
+++

# Conda Workflow

This page describes my Conda workflow.

## Conda

I use Conda as my environment and package manager. This choice is the outcome of a long professional history. Pros for choosing Conda:

- it's portable;
- it's simple to use;
- it provides optimised binaries for several scientific packages;
- it saves space on my hard drive;
- it can install more than just Python stuff.

Cons:

- many packages are missing (and interoperability with Pip has many issues when one starts playing with dependency pinning);
- usually second-class citizen in CI workflows (see also previous point about deps pinning);
- Conda's dependency resolution is *slow*;
- many people don't use Conda.

My Conda workflow is consequently an attempt at overcoming some of these issues.

- Addressing missing packages: Use [conda-forge](https://conda-forge.org/) as the default channel.
- Addressing slow dependency resolution: Use [Mamba](https://mamba.readthedocs.io/en/latest/).

Conda distro choice and configuration (ordered by preference):

1. [mambaforge](https://github.com/conda-forge/miniforge#mambaforge).
2. [miniforge](https://github.com/conda-forge/miniforge#miniforge3), [install Mamba manually](https://github.com/mamba-org/mamba#installation).
3. [miniconda](https://docs.conda.io/en/latest/miniconda.html), [add conda-forge to our channels](https://conda-forge.org/docs/user/introduction.html#how-can-i-install-packages-from-conda-forge), [install Mamba manually](https://github.com/mamba-org/mamba#installation).

## Living with others: A project with and without Conda

Sometimes we can't get away with just Conda, especially when we work with others and when we start publishing software. But **I still don't want to give up on Conda**, I'm very stubborn! So how can we single-source project dependencies and still pin both PyPI and Conda dependencies reliably?

Solution:

- define and manage dependencies with [Poetry](https://python-poetry.org/);
- lock Conda dependencies with [conda-lock](https://github.com/conda-incubator/conda-lock).

Still, conda-lock is no silver bullet: It will not pin Pip-only dependencies. We therefore might have to fight for our packages. It however turns out that for many projects, it's alright and we can develop and test with Conda, and package with Poetry. We just need to be a little careful.

We might want to pay attention to the following points when writing our `pyproject.toml`:

- `tool.poetry.dev-dependencies`: add `conda-lock` as a dependency;
- `tool.conda-lock`: add `conda-forge` to your channels;
- `tool.conda-lock.dependencies`: add `setuptools` and `poetry` as dependencies.

In addition, we'll need a minimal `setup.py` to setup our project. I personally like the `setup.cfg` workflow. This way, we can install our Python package to a newly created and configured Conda env with:

```bash
$ python setup.py develop --no-deps
```

**setup.py**

> ```python
> import setuptools
>
> setuptools.setup()
> ```

**setup.cfg**

> Assumptions:
>
> - code is in `src/`;
> - package is named `my_package`.
>
> Your package may actually consist of several Python packages (here, we > only have `my_package`, but we could have more).
>
> ```ini
> [metadata]
> name = my_package
> version = attr: my_package.__version__
>
> [options]
> # Package discovery
> package_dir =
>     =src
> packages = find:
>
> [options.packages.find]
> where = src
> include = *
> ```

Now we can glue all this with a makefile:

**Makefile**

> ```makefile
> ifeq ($(OS), Windows_NT)
> 	PLATFORM := win-64
> else
> 	uname := $(shell sh -c 'uname 2>/dev/null || echo unknown')
> 	ifeq ($(uname), Darwin)
> 		PLATFORM := osx-64
> 	else ifeq ($(uname), Linux)
> 		PLATFORM := linux-64
> 	else
> 		@echo "Unsupported platform"
> 		exit 1
> 	endif
> endif
>
> all:
> 	@echo "Detected platform: $(PLATFORM)"
>
> # Lock Poetry dependencies
> poetry-lock:
> 	poetry lock
>
> # Lock conda dependencies
> conda-lock:
> 	conda-lock --file pyproject.toml \
> 	    --filename-template "requirements/environment-{platform}.lock" > \
> 	    -p $(PLATFORM)
>
> conda-lock-all:
> 	conda-lock --file pyproject.toml \
> 	    --filename-template "requirements/environment-{platform}.lock"
>
> # Initialise development environment
> conda-init:
> 	conda update --file requirements/environment-$(PLATFORM).lock
> 	python setup.py develop --no-deps
>
> # Shortcut for poetry and conda lock
> lock: conda-lock-all poetry-lock
>
> conda-update: conda-lock-all conda-init lock
>
> .PHONY: poetry-lock conda-lock conda-lock-all conda-init conda-update
> ```

Now, all we need to update our lock files is a simple

```bash
$ make lock
```

We can initialise or update a Conda environment with

```bash
$ make conda-init
```

## Testing with Nox

Next up on our chore list is setting up [Nox](https://nox.thea.codes/) in a way such that we'll have:

- complete CI support for a list of Python versions;
- a similar set of Conda-based testing sessions to be sure that our package can also be installed and works with Conda.

Once again, single-sourcing dependencies is the big problem, and sadly we can't solve it completely yet.

### Installing Nox

The simplest and universal way is to use [pipx](https://pypa.github.io/pipx/). This one can be installed to your base Conda env or globally using Homebrew/Linuxbrew. *Note that you will probably have to add pipx to your path using `pipx ensurepath`.*

Then:

```bash
$ pipx install nox
```

Using pipx is nicer than using Conda because you can then customise pipx with PyPI packages --- also doable with Conda, but not as cleanly. We will install the [nox-poetry](https://nox-poetry.readthedocs.io) plugin:

```bash
$ pipx inject nox nox-poetry
```

### Configuring Nox sessions

We can configure our Nox session and combine Poetry and Conda in various ways to cover more Python versions and test whether our package works with Conda-managed dependencies.

- Use a regular virtualenv and manage packages with Poetry: This is the "normal" configuration, the one we can use in a Conda-free context. In that case, running this session locally can require installing the Python versions missing from our OS, *e.g.* using [pyenv](https://github.com/pyenv/pyenv) (preferrably installed using Homebrew/Linuxbrew for simplicity --- don't forget shell configuration).
- Use a Conda env and manage packages with Poetry: This is useful to cover testing on multiple Python versions when you don't want to mess with .
- Use a Conda env and manage packages with Conda: This is useful to check if our package works fine in a Conda environment.

**noxfile.py**

> ```python
> import nox
> import nox_poetry
>
>
> # Virtualenv + Poetry
> @nox_poetry.session(python=["3.6", "3.7", "3.8", "3.9"])
> def test_poetry(session):
>     session.run("poetry", "install", external=True)
>     session.run("pytest")
>
>
> # Conda + Poetry
> @nox.session(venv_backend="conda", python=["3.6", "3.7", "3.8", "3.9"])
> def test_conda_poetry(session):
>     session.run("poetry", "install", external=True)
>     session.run("pytest")
>
>
> # Conda + Conda
> @nox.session(venv_backend="conda", python=["3.6", "3.7", "3.8", "3.9"])
> def test_conda_conda(session):
>     session.conda_install("pytest", "setuptools")  # Add here other deps which cannot be read from pyproject.toml
>     session.run("python", "setup.py", "develop", "--no-deps")
>     session.run("pytest")
> ```
