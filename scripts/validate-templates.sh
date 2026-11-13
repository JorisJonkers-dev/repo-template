#!/usr/bin/env bash
# Validate repo-template static assets without network access.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "validate-templates: $*" >&2
  exit 1
}

log() {
  echo "validate-templates: $*"
}

json_files=(
  .github/rulesets/main.json
  .release-please-manifest.json
  release-please-config.json
  renovate.json
  templates/dependency-policy/renovate.json.tmpl
  templates/release-please/simple.json.tmpl
  templates/release-please/node.json.tmpl
  templates/release-please/java-gradle.json.tmpl
  templates/release-please/manifest-default.json.tmpl
  templates/release-please/manifest-agents.json.tmpl
  templates/root-tooling/package/pnpm-package.json
  templates/root-tooling/package/yarn-package.json
  templates/root-tooling/hooks/lintstagedrc.json.tmpl
  templates/root-tooling/prettierrc.json.tmpl
)

workflow_template_files=(templates/workflows/*.yml.tmpl)
released_workflow_template_files=(
  templates/workflows/jvm-lib-ci.yml.tmpl
  templates/workflows/jvm-service-ci.yml.tmpl
  templates/workflows/gradle-plugin-ci.yml.tmpl
  templates/workflows/ts-lib-ci.yml.tmpl
  templates/workflows/vue-app-ci.yml.tmpl
  templates/workflows/python-ci.yml.tmpl
  templates/workflows/nix-ci.yml.tmpl
  templates/workflows/gitops-ci.yml.tmpl
)
placeholder_workflow_template_files=(
  templates/workflows/add-to-project.yml.tmpl
  templates/workflows/repository-hygiene.yml.tmpl
)

log "checking JSON syntax"
python3 - "$ROOT" "${json_files[@]}" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
for rel in sys.argv[2:]:
    path = root / rel
    with path.open("r", encoding="utf-8") as fh:
        json.load(fh)
PY

yaml_files=(
  .github/workflows/ci.yml
  .github/workflows/release.yml
  templates/dependency-policy/dependabot.yml.tmpl
  templates/dependency-policy/dependency-review.yml.tmpl
  templates/dependency-policy/scorecard.yml.tmpl
  # codeql.yml.tmpl is intentionally absent: its {{manual_timeout_minutes}}
  # placeholder renders to a bare integer, so the pre-substitution template is
  # not parseable YAML (quoting it would change the rendered type).
  templates/dependency-policy/codeql-config.yml.tmpl
  templates/go-service/Taskfile.yml.tmpl
  templates/go-service/golangci.yml.tmpl
  templates/go-service/workflows/ci.yml.tmpl
)

log "checking YAML syntax when a local parser is available"
python3 - "$ROOT" "${yaml_files[@]}" "${workflow_template_files[@]}" <<'PY'
import importlib.util
import pathlib
import sys

if importlib.util.find_spec("yaml") is None:
    print("validate-templates: PyYAML unavailable; skipped YAML parser check")
    raise SystemExit(0)

import yaml

root = pathlib.Path(sys.argv[1])
for rel in sys.argv[2:]:
    path = root / rel
    with path.open("r", encoding="utf-8") as fh:
        yaml.safe_load(fh)
PY

log "checking dependency policy invariants"
grep -R "default-days: 7" templates/dependency-policy/dependabot.yml.tmpl >/dev/null \
  || fail "Dependabot template must include 7-day cooldown"
grep -R "update-types: \\[minor, patch\\]" templates/dependency-policy/dependabot.yml.tmpl >/dev/null \
  || fail "Dependabot template must group minor and patch updates"
grep -R "security-updates" templates/dependency-policy/dependabot.yml.tmpl >/dev/null \
  || fail "Dependabot template must group security updates"

log "checking Renovate shared preset"
python3 - "$ROOT" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
expected = {
    "$schema": "https://docs.renovatebot.com/renovate-schema.json",
    "extends": ["github>JorisJonkers-dev/renovate-config"],
}
for rel in ("renovate.json", "templates/dependency-policy/renovate.json.tmpl"):
    actual = json.loads((root / rel).read_text(encoding="utf-8"))
    if actual != expected:
        raise SystemExit(f"{rel} must use the shared JorisJonkers-dev Renovate preset")
PY

log "checking release-please templates"
grep -F '"bootstrap-sha": "a2095b6de581575eaa896eea056963889b893770"' release-please-config.json >/dev/null \
  || fail "repo release-please config must carry the migration bootstrap sha"
grep -R '"bootstrap-sha": "{{bootstrap_sha}}"' templates/release-please/*.json.tmpl >/dev/null \
  || fail "release-please templates must expose bootstrap_sha"
grep -F '{ ".": "0.1.0" }' templates/release-please/manifest-default.json.tmpl >/dev/null \
  || fail "default release-please manifest template must start at 0.1.0"
grep -F '{ ".": "0.16.0" }' templates/release-please/manifest-agents.json.tmpl >/dev/null \
  || fail "agents release-please manifest template must start at 0.16.0"

log "checking root tooling invariants"
grep -R "config/detekt/detekt.yml" templates/root-tooling >/dev/null \
  || fail "Detekt default path must align with gradle-conventions"
grep -R "lint-staged" templates/root-tooling/hooks templates/root-tooling/package >/dev/null \
  || fail "lint-staged preset missing"
grep -R "prettier --check" templates/root-tooling/package templates/root-tooling/hooks >/dev/null \
  || fail "format check preset missing"
grep -R '"license": "LicenseRef-JorisJonkers-Proprietary-1.0"' templates/root-tooling/package >/dev/null \
  || fail "package presets must carry the proprietary LicenseRef"
grep -F "ignoreStatic: true" templates/root-tooling/stryker.config.mjs.tmpl >/dev/null \
  || fail "Stryker preset must ignore static mutants by default"

log "checking the testing standard"
grep -F '"test:e2e": "playwright test --retries=0"' templates/root-tooling/package/yarn-package.json >/dev/null \
  || fail "the e2e script must run with retries off; a flaky test is fixed or quarantined"
grep -F "uses: JorisJonkers-dev/github-workflows/.github/workflows/quarantine-check.yml@" .github/workflows/ci.yml >/dev/null \
  || fail "CI must run the quarantine expiry check"
grep -F "needs.quarantine.result" .github/workflows/ci.yml >/dev/null \
  || fail "Pipeline Complete must fail when the quarantine check does not succeed"
grep -F "docs/testing-standards.md" CLAUDE.md >/dev/null \
  || fail "CLAUDE.md must name the testing standard"

log "checking workflow caller templates"
for rel in "${released_workflow_template_files[@]}"; do
  [[ -f "$rel" ]] || fail "missing workflow caller template: $rel"
  grep -F "Pipeline Complete" "$rel" >/dev/null \
    || fail "$rel must include the Pipeline Complete aggregator"
  grep -F "re-actors/alls-green@release/v1" "$rel" >/dev/null \
    || fail "$rel must aggregate reusable workflow jobs"
  grep -E "JorisJonkers-dev/github-workflows/.github/workflows/.+@8b5462a796f022647dfc44123ddb3655cc3c2f28 # v0\\.45\\.3" "$rel" >/dev/null \
    || fail "$rel must pin released reusable workflows to v0.45.3 by SHA"
  if grep -E "uses: JorisJonkers-dev/github-workflows/.github/workflows/(jvm-ci|node-ci|python-ci|docker-image-ci)\\.yml@" "$rel" >/dev/null; then
    grep -F "require-package-proxy: true" "$rel" >/dev/null \
      || fail "$rel must require the package proxy on installing reusable workflows"
    grep -E "secrets: inherit|PACKAGES_PROXY_TOKEN" "$rel" >/dev/null \
      || fail "$rel must pass PACKAGES_PROXY_TOKEN to installing reusable workflows"
  fi
done
for rel in "${placeholder_workflow_template_files[@]}"; do
  [[ -f "$rel" ]] || fail "missing workflow caller template: $rel"
  grep -F "@{{github_workflows_ref}}" "$rel" >/dev/null \
    || fail "$rel must require a rendered published github-workflows ref"
done
grep -F "package-proxy-guard: enforce" templates/workflows/repository-hygiene.yml.tmpl >/dev/null \
  || fail "the repository-hygiene caller template must run the package proxy guard in enforce mode"
hygiene_tmpl=templates/workflows/repository-hygiene.yml.tmpl
grep -F "github.event.action == 'edited' && github.run_id" "$hygiene_tmpl" >/dev/null \
  && grep -F 'cancel-in-progress: true' "$hygiene_tmpl" >/dev/null \
  || fail "the repository-hygiene caller template must cancel superseded runs per pull request and give title edits their own group"
if grep -E '^\s+- (labeled|unlabeled)\s*$' "$hygiene_tmpl" >/dev/null; then
  fail "the repository-hygiene caller template must not run on label events: every label a bot adds would start another run"
fi
for rel in templates/workflows/*-ci.yml.tmpl templates/go-service/workflows/ci.yml.tmpl .github/workflows/ci.yml; do
  grep -F "github.ref == 'refs/heads/main' && github.sha || github.ref" "$rel" >/dev/null \
    && grep -F "cancel-in-progress: \${{ github.ref != 'refs/heads/main' }}" "$rel" >/dev/null \
    || fail "$rel must cancel superseded runs on a branch and never cancel a run on main (group by sha there)"
done
if rg -n 'JorisJonkers-dev/github-workflows/.github/workflows/.+@(main|master|HEAD)' templates/workflows; then
  fail "reusable workflow templates must not use moving refs"
fi

log "checking hook shell syntax"
bash -n scripts/install-git-hooks.sh templates/push-protection/hooks/*

log "checking Docker pattern template structure"
python3 - "$ROOT" <<'PY'
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
required_files = {
    "templates/docker-patterns/jvm/Dockerfile.jvm.tmpl": [
        "FROM ${JVM_BUILD_IMAGE} AS build",
        "FROM ${JVM_RUNTIME_IMAGE} AS runtime",
        "{{jvm_dependency_resolution_command}}",
        "{{jvm_build_command}}",
        "{{runtime_user_create_command}}",
        "COPY --from=build",
        "USER ${APP_UID}:${APP_GID}",
        "HEALTHCHECK",
        "ENTRYPOINT",
        "CMD",
    ],
    "templates/docker-patterns/jvm/Dockerfile.crac-jvm.tmpl": [
        "FROM ${JVM_BUILD_IMAGE} AS build",
        "FROM ${CRAC_RUNTIME_IMAGE} AS crac-base",
        "FROM crac-base AS train",
        "FROM crac-base AS runtime",
        "{{checkpoint_dir}}",
        "CRAC_MODE",
        "VOLUME",
        "HEALTHCHECK",
    ],
    "templates/docker-patterns/vue/Dockerfile.vue-build-runtime.tmpl": [
        "FROM ${NODE_BUILD_IMAGE} AS deps",
        "FROM deps AS build",
        "FROM ${NGINX_RUNTIME_IMAGE} AS runtime",
        "{{package_manager_install_command}}",
        "{{frontend_build_command}}",
        "COPY --from=build",
        "HEALTHCHECK",
    ],
    "templates/docker-patterns/vue/Dockerfile.pnpm-build.tmpl": [
        "FROM ${NODE_BUILD_IMAGE} AS deps",
        "FROM deps AS build",
        "FROM ${NGINX_RUNTIME_IMAGE} AS runtime",
        "{{pnpm_bootstrap_command}}",
        "pnpm install --frozen-lockfile",
        "pnpm {{pnpm_build_filter}} {{frontend_build_script}}",
        "COPY --from=build",
        "HEALTHCHECK",
    ],
    "templates/docker-patterns/vue/Dockerfile.yarn-build.tmpl": [
        "FROM ${NODE_BUILD_IMAGE} AS deps",
        "FROM deps AS build",
        "FROM ${NGINX_RUNTIME_IMAGE} AS runtime",
        "corepack enable",
        "yarn install --immutable",
        "yarn {{frontend_build_script}}",
        "COPY --from=build",
        "HEALTHCHECK",
    ],
    "templates/docker-patterns/nginx/Dockerfile.privileged-nginx.tmpl": [
        "FROM ${NGINX_RUNTIME_IMAGE} AS runtime",
        "COPY {{nginx_config_path}}",
        "COPY {{static_assets_dir}}",
        "EXPOSE {{privileged_listen_port}}",
        "HEALTHCHECK",
        "CMD",
    ],
    "templates/docker-patterns/nginx/Dockerfile.unprivileged-nginx.tmpl": [
        "FROM ${NGINX_RUNTIME_IMAGE} AS runtime",
        "COPY --chown=${NGINX_UID}:${NGINX_GID}",
        "USER ${NGINX_UID}:${NGINX_GID}",
        "EXPOSE {{unprivileged_listen_port}}",
        "HEALTHCHECK",
        "CMD",
    ],
    "templates/docker-patterns/entrypoints/otel-entrypoint.sh.tmpl": [
        "#!/usr/bin/env sh",
        "set -eu",
        "OTEL_RESOURCE_ATTRIBUTES",
        "otel_agent_arg",
        "exec \"$@\"",
    ],
    "templates/docker-patterns/entrypoints/crac-entrypoint.sh.tmpl": [
        "#!/usr/bin/env sh",
        "set -eu",
        "case \"${mode}\" in",
        "train)",
        "restore)",
        "run)",
        "exec java",
    ],
}

for rel, markers in required_files.items():
    path = root / rel
    if not path.exists():
        raise SystemExit(f"missing Docker pattern template: {rel}")
    text = path.read_text(encoding="utf-8")
    if "DESIGN-ONLY SKELETON" in text:
        raise SystemExit(f"Docker pattern template is still design-only: {rel}")
    missing = [marker for marker in markers if marker not in text]
    if missing:
        raise SystemExit(f"{rel} missing structural markers: {', '.join(missing)}")

template_count = len(list((root / "templates/docker-patterns").glob("**/*.tmpl")))
if template_count < len(required_files):
    raise SystemExit("expected all Docker pattern templates to be present")
if (root / "templates/docker-patterns/Dockerfile.tmpl").exists():
    raise SystemExit("single shared Dockerfile template is not allowed")

placeholder_re = re.compile(r"\{\{[a-zA-Z0-9_]+\}\}")
placeholders = set()
for path in (root / "templates/docker-patterns").glob("**/*.tmpl"):
    placeholders.update(placeholder_re.findall(path.read_text(encoding="utf-8")))

docs = [
    root / "templates/docker-patterns/README.md",
]
for doc in docs:
    text = doc.read_text(encoding="utf-8")
    missing = sorted(ph for ph in placeholders if ph not in text)
    if missing:
        raise SystemExit(f"{doc.relative_to(root)} missing placeholder docs: {', '.join(missing)}")
PY

log "checking Docker entrypoint shell syntax"
for entrypoint_template in templates/docker-patterns/entrypoints/*.tmpl; do
  sh -n "$entrypoint_template"
done

log "checking go-service archetype"
go_service_files=(
  templates/go-service/README.md
  templates/go-service/mise.toml.tmpl
  templates/go-service/Taskfile.yml.tmpl
  templates/go-service/golangci.yml.tmpl
  templates/go-service/Dockerfile.tmpl
  templates/go-service/dockerignore.tmpl
  templates/go-service/go.mod.tmpl
  templates/go-service/workflows/ci.yml.tmpl
  templates/go-service/cmd/app/main.go.tmpl
  templates/go-service/cmd/app/main_test.go.tmpl
)
for rel in "${go_service_files[@]}"; do
  [[ -f "$rel" ]] || fail "missing go-service file: $rel"
done
for marker in 'CGO_ENABLED=0' 'GOOS=$TARGETOS GOARCH=$TARGETARCH' 'FROM --platform=$BUILDPLATFORM' 'distroless/static' 'USER nonroot:nonroot'; do
  grep -F "$marker" templates/go-service/Dockerfile.tmpl >/dev/null \
    || fail "go-service Dockerfile.tmpl must contain: $marker"
done
for tool in go task golangci-lint sqlc '"github:sbdchd/squawk"'; do
  grep -E "^${tool} = \"[0-9]" templates/go-service/mise.toml.tmpl >/dev/null \
    || fail "go-service mise.toml.tmpl must pin $tool to an exact version"
done

python3 - "$ROOT" <<'PY'
import importlib.util
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
base = root / "templates/go-service"

placeholder_re = re.compile(r"\{\{[a-z0-9_]+\}\}")
placeholders = set()
for path in base.glob("**/*.tmpl"):
    placeholders.update(placeholder_re.findall(path.read_text(encoding="utf-8")))
readme = (base / "README.md").read_text(encoding="utf-8")
missing = sorted(ph for ph in placeholders if ph not in readme)
if missing:
    raise SystemExit("templates/go-service/README.md missing placeholder docs: " + ", ".join(missing))

if importlib.util.find_spec("yaml") is None:
    print("validate-templates: PyYAML unavailable; skipped go-service structure check")
    raise SystemExit(0)

import yaml

tasks = yaml.safe_load((base / "Taskfile.yml.tmpl").read_text(encoding="utf-8"))["tasks"]
check = [c["task"] for c in tasks["check"]["cmds"]]
if check != ["fmt", "lint", "vet", "test", "build"]:
    raise SystemExit(f"go-service task check must run fmt, lint, vet, test, build in order (got {check})")
if not any("-race" in c for c in tasks["test"]["cmds"] if isinstance(c, str)):
    raise SystemExit("go-service task test must run with -race")

ci = yaml.safe_load((base / "workflows/ci.yml.tmpl").read_text(encoding="utf-8"))
jobs = ci["jobs"]
if len(jobs) != 1:
    raise SystemExit("go-service ci.yml.tmpl must be a single job (jobs bill per rounded-up minute)")
job = next(iter(jobs.values()))
if job.get("name") != "Pipeline Complete":
    raise SystemExit("go-service ci.yml.tmpl job must be named Pipeline Complete")
steps = job["steps"]
if not any(str(s.get("uses", "")).startswith("jdx/mise-action@") for s in steps):
    raise SystemExit("go-service ci.yml.tmpl must install the toolchain with jdx/mise-action")
for step in steps:
    if "run" in step and step.get("if") != "${{ !cancelled() }}":
        raise SystemExit(f"go-service ci.yml.tmpl step {step.get('name')!r} must carry if: ${{{{ !cancelled() }}}}")
PY

render_go_service() {
  local out="$1" pair src dst
  mkdir -p "$out/cmd/example-service" "$out/.github/workflows"
  for pair in \
    mise.toml.tmpl:mise.toml Taskfile.yml.tmpl:Taskfile.yml golangci.yml.tmpl:.golangci.yml \
    Dockerfile.tmpl:Dockerfile dockerignore.tmpl:.dockerignore go.mod.tmpl:go.mod \
    workflows/ci.yml.tmpl:.github/workflows/ci.yml \
    cmd/app/main.go.tmpl:cmd/example-service/main.go \
    cmd/app/main_test.go.tmpl:cmd/example-service/main_test.go; do
    src="${pair%%:*}"
    dst="${pair#*:}"
    sed -e 's/{{service_name}}/example-service/g' \
        -e 's|{{go_module}}|github.com/JorisJonkers-dev/example-service|g' \
        "templates/go-service/$src" > "$out/$dst"
  done
}

# The Go build check needs a local toolchain at least as new as go.mod asks for;
# GOTOOLCHAIN=local keeps it offline instead of downloading a newer one.
go_required="$(awk '/^go / { print $2 }' templates/go-service/go.mod.tmpl)"
if ! command -v go >/dev/null 2>&1; then
  log "go unavailable; skipped go-service build check"
else
  go_local="$(go env GOVERSION | sed 's/^go//')"
  if [[ "$(printf '%s\n%s\n' "$go_required" "$go_local" | sort -V | head -n1)" != "$go_required" ]]; then
    log "go $go_local older than $go_required; skipped go-service build check"
  else
    go_service_tmp="$(mktemp -d)"
    render_go_service "$go_service_tmp"
    if grep -rnE '\{\{[a-z0-9_]+\}\}' "$go_service_tmp"; then
      rm -rf "$go_service_tmp"
      fail "rendered go-service still contains placeholders"
    fi
    (cd "$go_service_tmp" && GOTOOLCHAIN=local go vet ./... && GOTOOLCHAIN=local go test -count=1 ./... >/dev/null) \
      || { rm -rf "$go_service_tmp"; fail "rendered go-service does not vet/test cleanly"; }
    [[ -z "$(gofmt -l "$go_service_tmp")" ]] || { rm -rf "$go_service_tmp"; fail "rendered go-service is not gofmt-clean"; }
    rm -rf "$go_service_tmp"
  fi
fi

log "checking for source-specific values in templates"
forbidden_pattern='esa-blueshell|blueshell|personal-stack|frankfurt-contabo|enschede|167\.86\.79\.203|130\.89\.174\.190|192\.168\.0\.99|assistant-system|knowledge-system|media-system|utility-system|data-system|secret/data/platform|secret/platform|secret/agents|auth-api|assistant-api|knowledge-api|uptime-kuma|stalwart|rabbitmq|valkey|postgres'
if rg -n -i "$forbidden_pattern" templates; then
  fail "source-specific value found in templates"
fi

log "all checks passed"
