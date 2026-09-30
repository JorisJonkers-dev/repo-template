# Go service archetype

A minimal Go HTTP service: stdlib `net/http`, `slog` JSON logs, `/healthz` and
`/readyz` on `:8080`, and a graceful drain on `SIGTERM`. The toolchain is pinned
in `mise.toml` and every check is a `task` target, so `task check` locally and
the one CI job run the same commands.

It covers the build-and-check half of a service repo only. Deploy wiring comes
from [`../platform-deploy/`](../platform-deploy/README.md) and release
versioning from [`../release-please/`](../release-please/); neither is copied
here.

## Files

| Template | Rendered destination in the service repo |
|----------|------------------------------------------|
| `mise.toml.tmpl` | `mise.toml` |
| `Taskfile.yml.tmpl` | `Taskfile.yml` |
| `golangci.yml.tmpl` | `.golangci.yml` |
| `Dockerfile.tmpl` | `Dockerfile` |
| `dockerignore.tmpl` | `.dockerignore` |
| `go.mod.tmpl` | `go.mod` |
| `workflows/ci.yml.tmpl` | `.github/workflows/ci.yml` (replaces the root placeholder CI) |
| `cmd/app/main.go.tmpl` | `cmd/{{service_name}}/main.go` |
| `cmd/app/main_test.go.tmpl` | `cmd/{{service_name}}/main_test.go` |

Add `bin/` and `coverage.out` to the repo's `.gitignore`.

## Placeholders

| Placeholder | Meaning | Example |
|-------------|---------|---------|
| `{{service_name}}` | Binary, `cmd/` directory and image name (kebab-case). Use the same value as `{{service_name}}` in `platform-deploy`. | `example-service` |
| `{{go_module}}` | Go module path; also the goimports local prefix | `github.com/JorisJonkers-dev/example-service` |

Render with plain substitution, for example:

```bash
sed -e 's/{{service_name}}/example-service/g' \
    -e 's|{{go_module}}|github.com/JorisJonkers-dev/example-service|g' \
    templates/go-service/Taskfile.yml.tmpl > Taskfile.yml
```

`{{.NAME}}` in `Taskfile.yml.tmpl` is Task's own variable syntax, not a
placeholder; leave it as is.

## Task targets

| Target | What it does |
|--------|--------------|
| `task check` | `fmt`, `lint`, `vet`, `test`, `build` in order: what CI runs |
| `task fmt` | Fails on any gofumpt/goimports diff |
| `task lint` | golangci-lint, squawk on `db/migrations/*.sql` (skipped until that directory exists), actionlint |
| `task vet` | `go vet ./...` |
| `task test` | `go test -race` with a statement-coverage gate (`COVERAGE_MIN`, default 80) |
| `task build` | Static binary at `bin/{{service_name}}` |
| `task fix` | Apply formatters and autofixes |

`sqlc` is pinned in `mise.toml` for when the service grows a database; the
archetype itself has no `sqlc.yaml`.

## CI

`workflows/ci.yml.tmpl` is one job named `Pipeline Complete`, the estate's only
required check: `jdx/mise-action` installs the pinned toolchain, then each
`task` target is its own step with `if: ${{ !cancelled() }}` so one failure
still reports the rest. The last step builds the container image, so a broken
`Dockerfile` fails the pull request rather than the release.

## Container image

`Dockerfile.tmpl` compiles on the build platform and cross-compiles through
`TARGETOS`/`TARGETARCH` with `CGO_ENABLED=0`, so an arm64 image needs no
emulation for the Go stage. The runtime is `distroless/static-debian12:nonroot`
with no shell, so health is checked by Kubernetes probes, not a `HEALTHCHECK`.

## Deploying it

Copy the `platform-deploy` templates as that README describes, then:

- In `platform/deployment.yml`, set the workload's `health.path` to `/readyz`
  (port `8080` already matches).
- In `.github/workflows/publish.yml`, add
  `platforms: linux/amd64,linux/arm64` to the `publish-image` job's `with:`.
  `container-publish.yml` defaults to `linux/amd64` only.
- `container-publish.yml` passes no build args, so a published binary logs
  `version: dev` unless the `VERSION` build arg is supplied.
- Use `templates/release-please/simple.json.tmpl` for release-please.

## Runtime contract

| Variable | Default | Meaning |
|----------|---------|---------|
| `ADDR` | `:8080` | Listen address |

`/healthz` answers 200 while the process is up. `/readyz` answers 200 once the
server is serving and 503 once shutdown begins. On `SIGTERM` the listener
closes and in-flight requests get up to 10 seconds to finish.
