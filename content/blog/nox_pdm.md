+++
title = "Using Nox with PDM"
date = "2022-01-05T11:30:00+01:00"

#
# Set menu to "main" to add this page to
# the main menu on top of the page
#
#
# description is optional
#
# description = "An optional description for SEO. If not provided, an automatically created summary will be used."

#
# tags are optional
#
tags = ["nox", "pdm", "python"]
+++

Nox and PDM are both fantastic Python development tools. However, their opposite stances towards virtual environment usage makes using them together a little more cumbersome. In this note, I'll explain how I integrated Nox in my PDM workflow.

We will use Nox to automate testing on multiple Python versions during CI. We'd also like to run our tests using a similar command locally without having to maintain almost duplicate Nox sessions. We'll therefore try and vary the Nox session's behaviour using Nox and PDM features.

## Assumptions

* Our development dependencies (defined in the `tool.pdm.dev-dependencies` table of our `pyproject.toml`) include a `tests` group, which includes at least some version of `pytest`.
* Nox and PDM are installed externally, *i.e.* they are not included in our development dependencies.
* Our tests are located in a `tests` directory.
* Our development environment ships Python versions from 3.7 to 3.10.

## Local testing

For this use case, we want Nox to simply do `pytest <some_args>` in the currently active virtual environment or using our PEP 582 setup. We notably do *not* want an installation step: this is taken care of by the user upon development enviromnent setup. Since our development dependencies include Pytest, we want Nox to call:

```bash
pdm run pytest tests/
```

The only caveat is that PDM is external to our currently active environment: we'll use the `external` argument of the `session.run()` function. We therefore create a simple `noxfile.py` as follows:

```python
import nox

@nox.session
def test(session):
    """Run the test suite."""
    session.run("pdm", "run", "pytest", "tests", external=True)
```

We can then invoke the `nox` command without virtual environment usage as follows:

```bash
nox --no-venv -s test
```

This will run Pytest in the currently active environment (or our PEP 582 setup).

## Traditional Nox workflow

Let's extend our usage to the regular virtual environment-based Nox workflow. We still want to retain the previous behaviour, but we also want it to work fine in an isolated virtual environment. We'll first configure PDM (using [environment variables](https://pdm.fming.dev/configuration/)) to behave as follows:

* Install dependencies to the current virtual environment (`PDM_USE_VENV`)
* Ignore a set Python interpreter if any ([`PDM_IGNORE_SAVED_PYTHON`](https://pdm.fming.dev/usage/advanced/#use-nox-as-the-runner))

We'll then install our testing dependencies to our virtual environment using

```bash
pdm install -G tests
```

Our `noxfile.py` should now look like this (assuming we parametrise our session to test against all the Python versions we have installed on our system):

```python
import os
import nox

def _has_venv(session):
    return not isinstance(session.virtualenv, nox.virtualenv.PassthroughEnv)

@nox.session(python=("3.7", "3.8", "3.9", "3.10"))
def test(session):
    """Run the test suite."""

    # If a virtual environment is used, configure PDM appropriately and install
    # If --no-venv is used, the install step is skipped
    if _has_venv(session):
        os.environ.update({"PDM_USE_VENV": "1", "PDM_IGNORE_SAVED_PYTHON": "1"})
        session.run("pdm", "install", "-G", "tests", external=True)

 session.run("pdm", "run", "pytest", "tests", external=True)
```
