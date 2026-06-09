# Tasks: Round 4 Usable Docker Pattern Templates

**Input**: Design documents from `/specs/002-round4-docker-pattern-templates/`
**Prerequisites**: plan.md (required), spec.md, data-model.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel with other tasks because it touches different files
- **[Story]**: User story label, for example US1, US2, US3
- Include exact file paths in descriptions

## Phase 1: Setup

- [x] T001 Create `specs/002-round4-docker-pattern-templates/` with spec,
  plan, data model, and tasks.
- [x] T002 Read Round 3 Docker skeleton contract and current
  `scripts/validate-templates.sh`.

## Phase 2: Foundational

- [x] T003 Inspect read-only `/workspace/personal-stack` and
  `/workspace/website` Dockerfiles and entrypoints for behavior to generalize.
- [x] T004 Keep all source-specific values out of template outputs and document
  substitutions as placeholders.

## Phase 3: User Story 1 (Priority: P1)

**Goal**: JVM and CRaC JVM templates are complete, usable, and parameterized.

**Independent Test**: `scripts/validate-templates.sh`

- [x] T005 [US1] Replace `templates/docker-patterns/jvm/Dockerfile.jvm.tmpl`
  with a complete multi-stage JVM template.
- [x] T006 [US1] Replace
  `templates/docker-patterns/jvm/Dockerfile.crac-jvm.tmpl` with build,
  CRaC base, train, and runtime stages.
- [x] T007 [US1] Replace
  `templates/docker-patterns/entrypoints/otel-entrypoint.sh.tmpl` with a
  complete OTel-aware Java entrypoint.
- [x] T008 [US1] Replace
  `templates/docker-patterns/entrypoints/crac-entrypoint.sh.tmpl` with a
  complete CRaC train/restore/run entrypoint.

## Phase 4: User Story 2 (Priority: P2)

**Goal**: Vue and nginx templates are complete, usable, and parameterized.

**Independent Test**: `scripts/validate-templates.sh`

- [x] T009 [P] [US2] Replace
  `templates/docker-patterns/vue/Dockerfile.vue-build-runtime.tmpl` with a
  complete generic Vue build/runtime template.
- [x] T010 [P] [US2] Replace
  `templates/docker-patterns/vue/Dockerfile.pnpm-build.tmpl` with a complete
  pnpm build/runtime template.
- [x] T011 [P] [US2] Replace
  `templates/docker-patterns/vue/Dockerfile.yarn-build.tmpl` with a complete
  Yarn build/runtime template.
- [x] T012 [P] [US2] Replace
  `templates/docker-patterns/nginx/Dockerfile.privileged-nginx.tmpl` with a
  complete privileged nginx runtime template.
- [x] T013 [P] [US2] Replace
  `templates/docker-patterns/nginx/Dockerfile.unprivileged-nginx.tmpl` with a
  complete unprivileged nginx runtime template.

## Phase 5: User Story 3 (Priority: P3)

**Goal**: Placeholder and structural contracts are documented and validated.

**Independent Test**: `scripts/validate-templates.sh`

- [x] T014 [US3] Update `templates/docker-patterns/README.md` with every
  placeholder input.
- [x] T015 [US3] Update
  `specs/002-round4-docker-pattern-templates/data-model.md` with every
  placeholder input.
- [x] T016 [US3] Extend `scripts/validate-templates.sh` with Docker structure
  and placeholder documentation checks.

## Phase 6: Polish

- [x] T017 Run `scripts/validate-templates.sh`.
- [x] T018 Review `git diff` for source-specific values and scoped changes.
