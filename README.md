# repo-template

The template every [ExtraToast](https://github.com/ExtraToast) repository is
bootstrapped from. It carries the org's shared conventions so each repo starts
aligned instead of re-inventing CI, rulesets, templates, and release flow.

## What you get

- **One CI pipeline that ends in `Pipeline Complete`** — the single required
  status check across the org. (`.github/workflows/ci.yml`)
- **The common branch ruleset as code** — squash-only, linear history, and
  `Pipeline Complete` required — plus an idempotent apply script.
  (`.github/rulesets/main.json`, `scripts/apply-ruleset.sh`)
- **Tag → release versioning** via release-please, with exact-pin consumption
  and version-pinned deploys. (`release.yml`, `VERSIONING.md`)
- **Renovate** for exact-version dependency bumps (ExtraToast artifacts grouped).
- **PR + issue templates**, `CODEOWNERS`, `SECURITY.md`, `CONTRIBUTING.md`, and
  baseline hygiene (`.editorconfig`, `.gitignore`, `.gitleaks.toml`, `LICENSE`).

## Use it

See [`docs/REPO_SETUP.md`](docs/REPO_SETUP.md) to bootstrap a new repo, and
[`CONTRIBUTING.md`](CONTRIBUTING.md) / [`VERSIONING.md`](VERSIONING.md) for the
conventions every repo follows.
