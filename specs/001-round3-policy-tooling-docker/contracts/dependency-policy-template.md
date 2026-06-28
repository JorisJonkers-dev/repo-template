# Contract: Dependency Policy Templates

Dependency policy templates must:

- Use `{{placeholder}}` values for repository-specific paths, branches, languages, build commands, and generated-code ignores.
- Represent a 7-day update delay through `cooldown.default-days: 7` for Dependabot and `minimumReleaseAge: "7 days"` for Renovate.
- Group `minor` and `patch` version updates.
- Group security updates separately.
- Leave major updates outside routine version-update groups.
- Support optional JorisJonkers-dev shared-artifact grouping without requiring every consumer to use JorisJonkers-dev package names.
- Avoid hardcoded source-repo domains, hostnames, namespaces, image prefixes, queue/exchange names, paths, IPs, and vendor URLs.
