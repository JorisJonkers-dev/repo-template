# Feature Specification: Round 3 Policy, Tooling, and Docker Pattern Templates

**Feature Branch**: `001-round3-policy-tooling-docker`
**Created**: 2026-06-09
**Status**: Draft
**Input**: User description: "EXTRACT-NOW dependency policy templates and root dev-tooling/docs/ADR preset; DESIGN-FIRST Dockerfile/entrypoint patterns as spec plus skeletons only."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Dependency Policy Templates (Priority: P1)

Repository maintainers can start from parameterized Dependabot, Renovate, dependency-review, Scorecard, and CodeQL templates that encode the JorisJonkers-dev dependency policy without inheriting source-repo-specific paths or domains.

**Why this priority**: Dependency automation is a repo-onboarding policy and must be available before new repositories select their application stack.

**Independent Test**: Run the template validation script and inspect that dependency templates include 7-day release age/cooldown, minor/patch grouping, security grouping, and isolated major updates.

**Acceptance Scenarios**:

1. **Given** a Gradle, Node, Docker, or GitHub Actions repository, **When** a maintainer fills the dependency-policy template parameters, **Then** generated update policy files group minor/patch updates and security updates while leaving major updates isolated.
2. **Given** an JorisJonkers-dev shared-artifact consumer, **When** the optional shared-artifact grouping is enabled, **Then** packages matching `dev.jorisjonkers`, `@jorisjonkers-dev`, and the reusable workflow repo can be grouped in one coherent update.

---

### User Story 2 - Root Tooling and Docs Preset (Priority: P2)

Repository maintainers can add a root tooling preset for editor defaults, Prettier, ESLint, lint-staged, Husky, gitleaks, package-manager scripts, ADR layout, docs index, and optional strict pre-commit checks.

**Why this priority**: New repositories need consistent local feedback loops and documentation structure before application-specific code diverges.

**Independent Test**: Run the template validation script and inspect that root tooling templates contain no personal project values and that Detekt paths default to `config/detekt/detekt.yml`.

**Acceptance Scenarios**:

1. **Given** a pnpm or Yarn frontend repository, **When** a maintainer chooses the matching preset, **Then** the repo has scripts and lint-staged hooks for lint, typecheck, tests, build, and formatting.
2. **Given** a JVM repository using gradle-conventions, **When** strict pre-commit snippets are enabled, **Then** Detekt and ktlint commands use convention-aligned paths and remain optional local hooks, not mandatory template runtime logic.
3. **Given** a repository adopting ADRs, **When** the docs preset is copied, **Then** ADR files, ADR indexes, and docs indexes use a consistent neutral layout.

---

### User Story 3 - Docker Pattern Design Skeletons (Priority: P3)

Platform maintainers can review design-first Dockerfile and entrypoint pattern skeletons for JVM, CRaC JVM, OTel entrypoint, Vue build/runtime, pnpm/Yarn, and nginx privilege variants without shipping a single shared production Dockerfile.

**Why this priority**: Docker patterns need design agreement before production implementation because they span runtime security, observability, CRaC, package managers, and frontend serving.

**Independent Test**: Verify that skeleton files are labeled design-only, contain placeholders rather than production values, and provide separate patterns rather than one shared Dockerfile.

**Acceptance Scenarios**:

1. **Given** a JVM service, **When** maintainers review the skeletons, **Then** the ordinary JVM and CRaC JVM paths are separate and identify configurable jar paths, JVM flags, user IDs, and checkpoint behavior.
2. **Given** a Vue application, **When** maintainers review the skeletons, **Then** package-manager build and nginx runtime concerns are separated.
3. **Given** an nginx runtime, **When** maintainers review the skeletons, **Then** privileged and unprivileged variants are represented explicitly.

### Edge Cases

- Templates must not embed source-repo domains, hostnames, exchange names, queue names, namespaces, image prefixes, IP addresses, personal paths, or vendor URLs.
- Active repo policy files must remain valid for this template repository while richer parameterized variants live under `templates/`.
- Docker skeletons must not imply a production-ready shared base image or a single Dockerfile that all services inherit.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide parameterized Dependabot templates with 7-day cooldowns, grouped minor/patch updates, separate security groups, and major updates outside grouped version-update rules.
- **FR-002**: System MUST provide parameterized Renovate templates with 7-day release age, grouped minor/patch updates, isolated major updates, lockfile maintenance, GitHub Actions digest pinning, and optional JorisJonkers-dev shared-artifact grouping.
- **FR-003**: System MUST provide dependency-review, Scorecard, CodeQL workflow templates, plus a CodeQL config template with configurable languages, build commands, and ignored generated paths.
- **FR-004**: System MUST provide root dev-tooling template variants for pnpm and Yarn frontend repositories, including ESLint, Prettier, editorconfig, lint-staged, Husky, and gitleaks.
- **FR-005**: System MUST provide docs/ADR layout templates including an ADR index, ADR file template, docs index, and domain-split ADR index option.
- **FR-006**: System MUST provide optional strict pre-commit snippets that align Detekt defaults with `config/detekt/detekt.yml` and ktlint defaults with Gradle convention tasks.
- **FR-007**: System MUST provide Dockerfile and entrypoint skeleton fixtures for JVM, CRaC JVM, OTel entrypoint, Vue build/runtime, pnpm, Yarn, privileged nginx, and unprivileged nginx patterns.
- **FR-008**: System MUST include local validation that detects malformed JSON, malformed YAML when a local parser is available, missing required policy markers, and forbidden source-repo-specific values.

### Key Entities

- **Dependency Policy Template**: A configurable file or workflow defining dependency update or supply-chain scanning behavior for a new repository.
- **Root Tooling Preset**: A set of repo-root configuration templates for local developer feedback loops and documentation conventions.
- **Docker Pattern Skeleton**: A design-only placeholder file that records intended Docker and entrypoint responsibilities without production implementation.
- **Template Validation Script**: A local script that checks template syntax and policy invariants without network access.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Validation script exits successfully with no network access.
- **SC-002**: Dependency policy templates include the required 7-day delay/cooldown and grouping controls.
- **SC-003**: No new template contains known personal-stack or website domains, hostnames, IP addresses, namespaces, image prefixes, paths, exchange names, or queue names.
- **SC-004**: Docker pattern files are skeletons only and are split by runtime concern rather than represented as one shared Dockerfile.
