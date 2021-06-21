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

- many packages are missing (and interoperability with Pip has many issues when you start playing with dependency pinning);
- usually second-class citizen in CI workflows (see also previous point about deps pinning);
- Conda's dependency resolution is *slow*;
- many people don't use Conda.

My Conda workflow is consequently an attempt at overcoming some of these issues.

- Addressing missing packages: Use [conda-forge](https://conda-forge.org/) as the default channel.
- Addressing slow dependency resolution: Use [Mamba](https://mamba.readthedocs.io/en/latest/).

Conda distro choice and configuration (ordered by preference):

1. [mambaforge](https://github.com/conda-forge/miniforge#mambaforge).
2. [miniforge](https://github.com/conda-forge/miniforge#miniforge3), [install Mamba manually](https://github.com/mamba-org/mamba#installation).
3. [miniconda](https://docs.conda.io/en/latest/miniconda.html), [add conda-forge to your channels](https://conda-forge.org/docs/user/introduction.html#how-can-i-install-packages-from-conda-forge), [install Mamba manually](https://github.com/mamba-org/mamba#installation).

## Living with others: A project with and without Conda

Sometimes you just can't get away with Conda, especially when you work with others and when you start publishing software. But **I still don't want to give up on Conda**, I'm very stubborn! So how can I single-source project dependencies and still pin both PyPI and Conda dependencies reliably?

Solution:

- define and manage dependencies with [Poetry](https://python-poetry.org/);
- lock Conda dependencies with [conda-lock](https://github.com/conda-incubator/conda-lock).

Still, conda-lock is no silver bullet: It will not pin Pip-only dependencies. You therefore might have to fight for your packages. It however turns out that for many projects, it's alright and you can develop and test with Conda, and package with Poetry. You just need to be a little careful.

You might want to pay attention to the following points when writing your `pyproject.toml`:

- `tool.poetry.dev-dependencies`: add `conda-lock` as a dependency;
- `tool.conda-lock`: add `conda-forge` to your channels;
- `tool.conda-lock.dependencies`: add `setuptools` and `poetry` as dependencies.

In addition, you'll need a minimal `setup.py` to setup your project. I personally like the `setup.cfg` workflow, so my

```python
for i in range(10):
    print(i)
```
