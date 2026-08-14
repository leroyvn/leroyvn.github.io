# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Overview

Personal website for Vincent Leroy, built with [Hugo](https://gohugo.io/) using the [Hugo Bear Blog](https://github.com/janraasch/hugo-bearblog) theme (vendored as a git submodule in `themes/hugo-bearblog`, pointing at a personal fork).

Deployed to GitHub Pages via GitHub Actions on push to `main`: `.github/workflows/gh-pages.yml` runs `pixi run build` and publishes `build/` to the `gh-pages` branch. Pull requests build but do not deploy.

## Commands

Hugo is installed by Pixi (a PyPI dependency), not from the system — always go through `pixi run`.

- `pixi run server` — local dev server with live reload
- `pixi run build` — production build with minification (output to `build/`)
- `pixi run clean` — clean the build directory

A fresh clone needs `git submodule update --init` before any build, otherwise the theme is missing and Hugo fails.

## Structure

- `config.toml` — Hugo site configuration (`publishDir = "build"`, which is gitignored)
- `content/` — Markdown pages (`_index.md`, `about.md`, `resources.md`, `blog/`, `cooking/`)
- `layouts/cooking/single.html` — per-section template for recipes
- `layouts/shortcodes/rawhtml.html` — custom shortcode for embedding raw HTML
- `layouts/partials/custom_head.html` — theme head override
- `static/` — static assets (images, favicon)
- `themes/hugo-bearblog/` — theme (git submodule; do not edit directly)

## Content conventions

Front matter is TOML (`+++` fences). `content/_index.md` is the exception: plain Markdown, no front matter.

A page or section appears in the top navigation by setting `menu = "main"` in its front matter; section landing pages do this in their `_index.md`.

Blog posts carry `title`, `date` and `tags`, and start their body directly (the theme renders the title). Use the `rawhtml` shortcode for HTML that Markdown cannot express, e.g. `<details>` blocks.

### Recipes (`content/cooking/`)

`layouts/cooking/single.html` styles recipes with inline CSS driven by the *structure* of the rendered body, not by classes:

- first `<ul>` → meta line (prep time, difficulty), rendered inline and muted
- second `<ul>` → ingredients, rendered as a two-column card
- `<ol>` → steps, rendered with large circled numbers

So a recipe body must follow that order, and must not open with an `#` heading — the title comes from front matter. If a recipe ever needs a different intro layout, move the meta and ingredients into front matter rather than adding more structural selectors.
