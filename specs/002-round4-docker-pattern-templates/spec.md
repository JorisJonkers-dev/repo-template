# Feature Specification: Round 4 Usable Docker Pattern Templates

**Feature Branch**: `002-round4-docker-pattern-templates`
**Created**: 2026-06-09
**Status**: Draft
**Input**: User description: "Promote Docker pattern skeletons into complete, usable parameterized templates while keeping CI/Pipeline Complete green."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - JVM Runtime Templates (Priority: P1)

Service maintainers can copy a parameterized multi-stage JVM Dockerfile and a
CRaC-capable JVM Dockerfile into a target repository, substitute documented
inputs, and get a complete build/runtime image pattern without source-repo
specific values.

**Why this priority**: JVM service images are the highest-risk Docker patterns
because they combine build caching, runtime identity, JVM flags, observability,
healthchecks, and optional CRaC behavior.

**Independent Test**: Run `scripts/validate-templates.sh` and inspect that JVM
templates include build and runtime stages, runtime user creation, entrypoint
copying, `USER`, `EXPOSE`, and `HEALTHCHECK`.

**Acceptance Scenarios**:

1. **Given** a Gradle or other JVM service, **When** maintainers render
   `jvm/Dockerfile.jvm.tmpl`, **Then** the result has a multi-stage build,
   a non-root runtime, OTel entrypoint composition, and a healthcheck.
2. **Given** a CRaC-capable service, **When** maintainers render
   `jvm/Dockerfile.crac-jvm.tmpl`, **Then** the result exposes separate
   `train` and `runtime` targets and delegates train/restore/run behavior to
   the CRaC entrypoint.

---

### User Story 2 - Frontend and nginx Templates (Priority: P2)

Frontend maintainers can copy generic Vue, pnpm-specific Vue, Yarn-specific Vue,
privileged nginx, or unprivileged nginx templates and render complete static
runtime images.

**Why this priority**: Frontend image patterns need consistent build/runtime
separation while still allowing package-manager-specific lockfile and cache
behavior.

**Independent Test**: Run `scripts/validate-templates.sh` and inspect that Vue
templates include dependency, build, and nginx runtime stages, and nginx
templates include static asset copy, `EXPOSE`, `HEALTHCHECK`, and command.

**Acceptance Scenarios**:

1. **Given** a Vue app with pnpm, **When** maintainers render
   `vue/Dockerfile.pnpm-build.tmpl`, **Then** the result installs with a frozen
   lockfile, builds the target app, and serves the build output from nginx.
2. **Given** a Vue app with Yarn, **When** maintainers render
   `vue/Dockerfile.yarn-build.tmpl`, **Then** the result enables Corepack,
   installs immutably, builds, and serves the build output from nginx.
3. **Given** a platform that cannot bind privileged ports, **When** maintainers
   choose the unprivileged nginx template, **Then** the rendered image runs as a
   configured non-root UID/GID.

---

### User Story 3 - Documented Parameter Surface (Priority: P3)

Repository maintainers can see every required `{{placeholder}}` in
`templates/docker-patterns/README.md` and in the Round 4 data model.

**Why this priority**: Usable templates are only safe if their substitution
contract is explicit and source-specific values stay outside this repository.

**Independent Test**: Run `scripts/validate-templates.sh`; it fails when a
Docker placeholder is not documented in both the README and this spec data
model.

**Acceptance Scenarios**:

1. **Given** a new placeholder is added to a Docker template, **When** validation
   runs before documentation is updated, **Then** validation fails.
2. **Given** source-specific values appear in templates, **When** validation
   runs, **Then** validation fails before CI can pass.

### Edge Cases

- Templates must remain templates with `{{...}}` placeholders, not a single
  shared Dockerfile.
- Templates must not hardcode domains, hostnames, namespaces, IPs, exchange or
  queue names, image prefixes, personal paths, or vendor download URLs.
- Shell entrypoint templates must stay structurally valid before placeholder
  substitution.
- CRaC training and restore orchestration remain target-repository concerns;
  this repository provides image and entrypoint contracts only.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a complete multi-stage JVM Dockerfile template
  with dependency caching, artifact build, runtime user creation, jar copy,
  OTel entrypoint copy, `USER`, `EXPOSE`, `HEALTHCHECK`, `ENTRYPOINT`, and
  `CMD`.
- **FR-002**: System MUST provide a complete CRaC JVM Dockerfile template with
  build, CRaC base, `train`, and `runtime` stages plus checkpoint directory
  handling.
- **FR-003**: System MUST provide OTel and CRaC shell entrypoint templates that
  set runtime defaults, compose OTel resource attributes, and `exec` the final
  Java process.
- **FR-004**: System MUST provide complete generic Vue, pnpm Vue, and Yarn Vue
  Dockerfile templates with dependency, build, and nginx runtime stages.
- **FR-005**: System MUST provide complete privileged and unprivileged nginx
  runtime templates with static asset copy, exposed ports, healthchecks, and
  nginx foreground command.
- **FR-006**: System MUST document all Docker placeholders in
  `templates/docker-patterns/README.md` and `data-model.md`.
- **FR-007**: System MUST extend local validation to reject design-only Docker
  markers, missing structure, undocumented placeholders, and forbidden
  source-specific values.

### Key Entities

- **DockerPatternTemplate**: A parameterized Dockerfile or entrypoint that can
  be rendered into a usable target-repository artifact.
- **PlaceholderInput**: A documented `{{...}}` substitution input supplied by a
  consuming repository, Flux postBuild substitution, or another renderer.
- **DockerTemplateValidator**: Local validation that checks structure and
  placeholder documentation without Docker or network access.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `scripts/validate-templates.sh` exits successfully without
  network access.
- **SC-002**: Docker templates contain no `DESIGN-ONLY SKELETON` markers.
- **SC-003**: Every Docker placeholder is documented in both
  `templates/docker-patterns/README.md` and
  `specs/002-round4-docker-pattern-templates/data-model.md`.
- **SC-004**: No Docker template contains known personal-stack or website
  domains, hostnames, IP addresses, namespaces, image prefixes, paths,
  exchange names, queue names, or vendor download URLs.
