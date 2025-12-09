## Repo overview

This repository is a Jekyll site/theme (based on `jekyll-theme-chirpy`) used to build a static site. Key responsibilities for an AI coding agent working here:

- Build system: Ruby Jekyll for site generation plus Node toolchain for frontend assets (Rollup + PurgeCSS).
- Primary content locations: `_posts`, `_pages`/`_tabs`, `_layouts`, `_includes`, `_sass`, and `assets/` or `images/` for static assets.
- JS sources live under `_javascript/` and `assets/js/`; CSS/Sass lives in `_sass/` and `assets/css`.

## Quick dev & build commands (examples)

- Start local Jekyll server (recommended shell: WSL, Git Bash, or any Bash that has Ruby/bundler):

  ```bash
  bash tools/run.sh            # defaults to host 127.0.0.1
  bash tools/run.sh -H 0.0.0.0 # bind to all interfaces
  bash tools/run.sh -p        # JEKYLL_ENV=production
  ```

- Build the site and run HTML checks (production):

  ```bash
  bash tools/test.sh          # uses bundle exec jekyll b and htmlproofer
  ```

- Frontend asset workflow (Node):

  ```bash
  npm run watch:js   # watch & rebuild JS with rollup
  npm run build:css  # run PurgeCSS to generate production CSS
  npm run build      # runs build:js and build:css concurrently
  ```

Notes: `package.json` contains these scripts and devDependencies (rollup, purgecss, eslint, stylelint, concurrently). Ruby/Jekyll dependencies are declared in `Gemfile` and installed via `bundle install`.

## CI / Release / Automation

- GitHub Actions: check `.github/workflows/jekyll.yml` (site build) and other workflow files in `.github/workflows/`. Some workflows are kept as `.bak` files—be careful when reactivating them.
- Release: semantic-release is configured in `package.json` and calls `tools/release.sh`. Do not alter release flow without checking `package.json:release` and `tools/release.sh`.

## Project-specific patterns & conventions

- The theme is heavily structured (inherited from `jekyll-theme-chirpy`). Typical places to look when changing UI or layout:
  - Templates: `_layouts/` and `_includes/`
  - Styles: `_sass/` (partials and theme variables)
  - Scripts: `_javascript/` and `assets/js/` (entry points configured by `rollup.config.js`)
  - Localization: `_data/locales/` and `_data/*` (site strings)

- Keep content and templates separate. Update templates or partials when layout changes are required; modify `_posts` or `_tabs` for content.

- JS/CSS build interplay: JS uses Rollup + Babel (`rollup.config.js`); CSS is pruned with `purgecss.js` to remove unused classes. When adding classes used only in templates or markdown, ensure PurgeCSS safelist or update `purgecss.js` to avoid accidental removal.

## Files to inspect for context when making changes

- `package.json` — npm scripts, devDependencies, and semantic-release config.
- `Gemfile` — ruby dependencies for Jekyll plugins.
- `tools/run.sh` — how the local server is started (host, production flag, docker detection).
- `tools/test.sh` — production build + `htmlproofer` usage and baseurl handling.
- `rollup.config.js` and `purgecss.js` — frontend build specifics.
- `_layouts/`, `_includes/`, `_sass/`, `_javascript/`, `assets/` — where to change site UI and assets.

## Safety notes for AI edits

- Don't accidentally remove or rename key Liquid template variables used across layouts (e.g., `page`, `site`, localized keys). Search for usages before changing names.
- When altering CSS classes, check `purgecss.js` and add safelisting for dynamic classes (classes added by JS or generated in templates).
- For JS changes: prefer editing sources under `_javascript/` and update `rollup.config.js` only if adding new entry points.
- For any change affecting CI or releases, announce before editing: workflows and `package.json` release section are sensitive.

## Examples (copyable) — local dev

1) Start JS watcher and Jekyll server in parallel (two shells):

   Shell A (WSL/Git Bash):
   ```bash
   npm run watch:js
   ```

   Shell B (Bash):
   ```bash
   bash tools/run.sh
   ```

2) Build for production and run HTML checks:

   ```bash
   bash tools/test.sh
   npm run build
   ```

## What this file should help you do

- Quickly locate the right files for layout, styling, and scripts.
- Run and reproduce local builds, tests, and asset pipelines.
- Understand where CI and release hooks live so you avoid breaking automation.

## How I expect to be used

- If you are an AI agent making changes: modify a single logical area per PR (e.g., a layout change or a JS fix), run the local build (`tools/run.sh` or `tools/test.sh`), and keep changes minimal and reversible.

---

If anything above is unclear or you'd like specific examples (e.g., add PurgeCSS safelist for a dynamic class, adjust Rollup entry points, or update the GitHub Actions job), tell me which area and I'll expand with concrete code snippets and exact file edits.
