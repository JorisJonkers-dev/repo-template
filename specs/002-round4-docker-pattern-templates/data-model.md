# Data Model: Round 4 Docker Pattern Templates

## DockerPatternTemplate

- `name`: template file name.
- `runtimeConcern`: JVM, CRaC JVM, OTel entrypoint, CRaC entrypoint, Vue,
  pnpm, Yarn, privileged nginx, or unprivileged nginx.
- `stages`: Docker stages or shell modes that must remain structurally present.
- `placeholderInputs`: documented `{{...}}` values required from the consuming
  repository or deployment renderer.
- `validationRules`: local structural checks that do not require Docker,
  Gradle, npm, pnpm, Yarn, Kubernetes, or network access.

## PlaceholderInput

All current Docker pattern placeholders:

- `{{app_gid}}`
- `{{app_group}}`
- `{{app_home}}`
- `{{app_jar_path}}`
- `{{app_uid}}`
- `{{app_user}}`
- `{{build_revision}}`
- `{{checkpoint_dir}}`
- `{{crac_entrypoint_source}}`
- `{{crac_mode}}`
- `{{crac_restore_java_args}}`
- `{{crac_runtime_image}}`
- `{{crac_train_java_args}}`
- `{{deployment_environment}}`
- `{{entrypoint_path}}`
- `{{frontend_build_command}}`
- `{{frontend_build_script}}`
- `{{frontend_dist_dir}}`
- `{{frontend_source_paths}}`
- `{{frontend_workdir}}`
- `{{healthcheck_command}}`
- `{{healthcheck_interval}}`
- `{{healthcheck_retries}}`
- `{{healthcheck_start_period}}`
- `{{healthcheck_timeout}}`
- `{{java_opts}}`
- `{{jvm_artifact_from_build_stage}}`
- `{{jvm_build_cache_target}}`
- `{{jvm_build_command}}`
- `{{jvm_build_image}}`
- `{{jvm_dependency_manifest_paths}}`
- `{{jvm_dependency_resolution_command}}`
- `{{jvm_runtime_image}}`
- `{{jvm_source_paths}}`
- `{{nginx_config_path}}`
- `{{nginx_gid}}`
- `{{nginx_healthcheck_command}}`
- `{{nginx_html_dir}}`
- `{{nginx_listen_port}}`
- `{{nginx_runtime_image}}`
- `{{nginx_uid}}`
- `{{node_build_image}}`
- `{{otel_entrypoint_source}}`
- `{{otel_exporter_otlp_endpoint}}`
- `{{otel_java_agent_enabled}}`
- `{{otel_java_agent_path}}`
- `{{otel_java_agent_source}}`
- `{{otel_resource_attributes}}`
- `{{otel_service_name}}`
- `{{package_manager_cache_target}}`
- `{{package_manager_files}}`
- `{{package_manager_install_command}}`
- `{{pnpm_bootstrap_command}}`
- `{{pnpm_build_filter}}`
- `{{pnpm_home}}`
- `{{pnpm_package_manifest_paths}}`
- `{{pnpm_store_path}}`
- `{{pnpm_workspace_files}}`
- `{{privileged_listen_port}}`
- `{{runtime_user_create_command}}`
- `{{server_port}}`
- `{{service_version}}`
- `{{static_assets_dir}}`
- `{{unprivileged_listen_port}}`
- `{{unprivileged_nginx_runtime_image}}`
- `{{vite_api_base_url}}`
- `{{vite_public_base_url}}`
- `{{yarn_cache_folder}}`
- `{{yarn_package_manifest_paths}}`
- `{{yarn_workspace_files}}`

## DockerTemplateValidator

- `templateInventory`: required Docker pattern files must exist and no
  top-level shared `templates/docker-patterns/Dockerfile.tmpl` may be added.
- `markerChecks`: templates must not contain `DESIGN-ONLY SKELETON`.
- `structureChecks`: Dockerfile templates must contain expected stages,
  `COPY`, `RUN` where applicable, `EXPOSE`, `HEALTHCHECK`, and foreground
  runtime command or entrypoint.
- `entrypointChecks`: shell templates must have a shebang, `set -eu`, a final
  `exec`, and mode-specific behavior.
- `placeholderChecks`: every placeholder found in Docker templates must be
  documented in this data model and in `templates/docker-patterns/README.md`.
- `leakChecks`: forbidden source values include personal domains, hostnames,
  IPs, namespaces, image prefixes, exchange or queue names, personal paths, and
  hardcoded vendor download URLs.
