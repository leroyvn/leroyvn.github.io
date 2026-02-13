# CLAUDE.md

This file provides guidance to coding agents when working with code in this repository.

To use with Claude Code, insert @AGENTS.md in CLAUDE.md.

## Overview

Personal website for Vincent Leroy, built with [Hugo](https://gohugo.io/) using the [Hugo Bear Blog](https://github.com/janraasch/hugo-bearblog) theme (vendored as a git submodule in `themes/hugo-bearblog`).

Deployed to GitHub Pages via GitHub Actions on push to `main`.

## Commands

- `pixi run server` — local dev server with live reload
- `pixi run build` — production build with minification (output to `build/`)
- `pixi run clean` — clean the build directory

## Structure

- `config.toml` — Hugo site configuration
- `content/` — Markdown pages (`_index.md`, `about.md`, `resources.md`, `blog/`)
- `layouts/shortcodes/rawhtml.html` — custom shortcode for embedding raw HTML
- `layouts/partials/custom_head.html` — theme head override
- `static/` — static assets (images, favicon)
- `themes/hugo-bearblog/` — theme (git submodule; do not edit directly)
