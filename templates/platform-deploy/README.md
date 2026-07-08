# Platform deploy templates

Wiring for a service repository onto the homelab deploy platform: the three
workflow callers (release / publish / deploy-preview), the `deploy/` contract
skeleton, the local CI-parity renderer, and the `PLATFORM.md` one-pager.
`examples/minimal-service/` is a complete worked fixture.

## Files

| Template | Rendered destination in the service repo |
|----------|------------------------------------------|
| `workflows/release.yml.tmpl` | `.github/workflows/release.yml` |
| `workflows/publish.yml.tmpl` | `.github/workflows/publish.yml` |
| `workflows/deploy-preview.yml.tmpl` | `.github/workflows/deploy-preview.yml` |
| `PLATFORM.md.tmpl` | `PLATFORM.md` |
| `deploy/deployment.yml.tmpl` | `deploy/deployment.yml` |
| `deploy/production.env.tmpl` | `deploy/production.env` |
| `deploy/images.lock.json.tmpl` | `deploy/images.lock.json` |
| `deploy/render-local.sh.tmpl` | `deploy/render-local.sh` (keep executable) |

## Placeholders

| Placeholder | Meaning | Example |
|-------------|---------|---------|
| `{{service_name}}` | Service / artifact name (kebab-case, equals the deploy-artifact name) | `agents-api` |
| `{{service_namespace}}` | Kubernetes namespace the service deploys into | `agents` |
| `{{schema_version}}` | Exact `@jorisjonkers-dev/deploy-config-schema` npm version | `0.16.0` |
| `{{context_ref}}` | Digest-pinned OCI ref of the public cluster context | `ghcr.io/…/cluster-deploy-context-public@sha256:…` |
| `{{ghcr_owner}}` | Lowercase GHCR owner for image refs | `jorisjonkers-dev` |
| `{{image_alias}}` | Image key in `images.lock.json` referenced by `deployment.yml` | `agents-api` |
| `{{release_app_id_var}}` | Actions secret name holding the release App id | `RELEASE_APP_ID` |
| `{{release_app_key_var}}` | Actions secret name holding the release App private key | `RELEASE_APP_PRIVATE_KEY` |

## Design rules (enforced by `scripts/validate-templates.sh`)

- `release.yml` mints the App token and asserts it (`E_APP_TOKEN_MISSING`);
  there is **no GITHUB_TOKEN fallback** — tags created with the default token
  would not trigger `publish.yml`. No job may `needs: release-please`.
- `publish.yml` jobs that call reusable workflows (`publish-image`,
  `publish-deploy-artifact`) never declare a job-level `outputs:` block —
  downstream jobs consume `needs.<job>.outputs.*` directly.
- The image lock crosses the reusable-workflow boundary **only** as the
  uploaded artifact (`image-lock-artifact: images-lock-<run_id>`); there is no
  intermediate download job and no `image-lock-path` on the deploy-artifact
  call.
- The first `register-service` registration emits the **full**
  `DeployUnitRegistration` spec (owner, namespace, layer, sourceRepository,
  environments, healthClass, `prune.default: true`, `allowedClusterScope: []`)
  derived from `deployment.yml`; `spec.platform.layer` is required for it.
  Updates bump only `spec.artifact` and preserve every other field.
- Reusable workflows are pinned to released
  `JorisJonkers-dev/github-workflows` tags (currently `v0.11.0`); no moving
  refs.
- `render-local.sh` mirrors CI (`validate → render → kubeconform → leak-scan →
  scorecard`); its SC-11 scorecard logic is plain bash + jq so it runs — and
  is tested — without the npm package (`--scorecard-only`).

## SC-11 scorecard

`route_owner_authmode_declared`, `stateful_policy_declared` and
`raw_manifests_guarded` are three-state (`pass|fail|not_applicable`); all other
fields are `pass|fail`. `examples/minimal-service/expected-scorecard.json` is
the golden output for the example and is asserted by the validator.
