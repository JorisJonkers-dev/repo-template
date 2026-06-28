# repo-template

The template every [JorisJonkers-dev](https://github.com/JorisJonkers-dev) repository is
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
- **Release-please archetype templates** for simple, Node, and Gradle repos.
  (`templates/release-please/`)
- **Reusable workflow caller templates** for JVM, Node, Python, Nix, Dockerized
  services, and GitOps repos. (`templates/workflows/`)
- **Private-repo push-protection hooks** for direct-main-push blocking and
  Conventional Commit enforcement. (`scripts/install-git-hooks.sh`,
  `templates/push-protection/`)
- **Renovate** via the shared JorisJonkers-dev preset.
- **Dependency policy templates** for Dependabot, Renovate, dependency-review,
  Scorecard, and CodeQL. (`templates/dependency-policy/`)
- **Root tooling and docs presets** for frontend lint/format hooks, gitleaks,
  ADR layout, and docs indexes. (`templates/root-tooling/`)
- **Opt-in platform/deploy config validation** against
  `@jorisjonkers-dev/deploy-config-schema` via a reusable workflow template.
  (`templates/platform-config-validation/`)
- **Design-only Docker pattern skeletons** for JVM, CRaC JVM, OTel entrypoints,
  Vue builds, package-manager builds, and nginx privilege variants.
  (`templates/docker-patterns/`)
- **PR + issue templates**, `CODEOWNERS`, `SECURITY.md`, `CONTRIBUTING.md`, and
  baseline hygiene (`.editorconfig`, `.gitignore`, `.gitleaks.toml`, `LICENSE`).

## Use it

See [`docs/REPO_SETUP.md`](docs/REPO_SETUP.md) to bootstrap a new repo, and
[`CONTRIBUTING.md`](CONTRIBUTING.md) / [`VERSIONING.md`](VERSIONING.md) for the
conventions every repo follows.

Validate template assets locally with:

```bash
scripts/validate-templates.sh
```

Repos that carry platform/deploy YAML can opt into schema validation by copying
`templates/platform-config-validation/platform-config-validate.yml.tmpl` to
`.github/workflows/platform-config-validate.yml`. The workflow calls
`JorisJonkers-dev/github-workflows/.github/workflows/platform-config-validate.yml@v0.6.0`
with `schema-kind: auto` and defaults to `platform/**/*.yml`,
`platform/**/*.yaml`, `deploy/**/*.yml`, and `deploy/**/*.yaml`.
