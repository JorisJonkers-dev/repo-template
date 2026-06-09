# Implementation Plan: Round 4 Usable Docker Pattern Templates

**Branch**: `002-round4-docker-pattern-templates` | **Date**: 2026-06-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-round4-docker-pattern-templates/spec.md`

## Summary

Promote the Round 3 Docker pattern skeletons into complete, usable
parameterized templates. Keep the files under `templates/docker-patterns/` as
copy/render templates with `{{...}}` inputs rather than a single shared
Dockerfile. Extend local validation to check Docker template structure,
entrypoint syntax, placeholder documentation, and forbidden source-specific
values without running Docker or networked builds.

## Technical Context

**Language/Version**: Dockerfile templates, POSIX shell templates, Markdown,
Bash, Python standard library
**Primary Dependencies**: Bash, local Python 3 standard library; optional local
PyYAML for existing YAML checks
**Storage**: Files in repository
**Testing**: `scripts/validate-templates.sh`
**Target Platform**: GitHub repository template consumers
**Project Type**: repository template / Docker pattern library
**Performance Goals**: Validation completes in under 5 seconds locally
**Constraints**: No networked build; no Docker execution; no modification of
read-only reference repos; templates must be source-neutral and parameterized
**Scale/Scope**: One Spec Kit feature plus Docker template and validator updates

## Constitution Check

- [x] No attribution is introduced in files, comments, commit text, or PR text
- [x] Claude/Codex parity is preserved for agent-facing behavior
- [x] Rendered artifacts are not required because templates are source assets
- [x] Small stacked PR boundary is clear and unrelated cleanup is excluded
- [x] Verification command is identified for each touched area

## Project Structure

### Documentation

```text
specs/002-round4-docker-pattern-templates/
|-- spec.md
|-- plan.md
|-- data-model.md
`-- tasks.md
```

### Source Code

```text
templates/docker-patterns/
|-- README.md
|-- entrypoints/
|-- jvm/
|-- nginx/
`-- vue/
scripts/validate-templates.sh
```

**Structure Decision**: Docker patterns remain separate files by runtime
concern. Consumers choose and render the pattern that matches their stack.

## Phase 0: Research

1. Read Round 3 spec and Docker skeletons.
2. Inspect read-only `/workspace/personal-stack` and `/workspace/website`
   Dockerfiles and entrypoints for real build/runtime behavior.
3. Generalize all concrete source values into placeholders.

**Output**: Template behavior grounded in reference repos without copying
source-specific values.

## Phase 1: Design & Contracts

1. Define `DockerPatternTemplate`, `PlaceholderInput`, and
   `DockerTemplateValidator` in `data-model.md`.
2. Document every placeholder in `templates/docker-patterns/README.md`.
3. Keep CRaC orchestration and target image selection as consumer-owned inputs.

## Phase 2: Implementation

1. Replace design-only skeletons with complete Dockerfile templates.
2. Replace entrypoint skeletons with complete POSIX shell templates.
3. Extend `scripts/validate-templates.sh` with structural checks and
   placeholder documentation coverage.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --- | --- | --- |
| N/A | N/A | N/A |

## Progress Tracking

**Phase Status**:

- [x] Phase 0: Research complete
- [x] Phase 1: Design complete
- [x] Phase 2: Implementation complete

**Gate Status**:

- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
