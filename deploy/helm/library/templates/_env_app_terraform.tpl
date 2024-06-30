{{/*
Copyright (c) 2024 Aleksei Kotelnikov(gudron2s@gmail.com)
License: MIT NON-AI
*/}}
{{- define "_env_app_terraform" -}}
- name: APP_LOCAL_ENV_FILE_PATH
  value: {{ pluck .Values.global.env .Values.terraformer.env.file_name | first | default .Values.terraformer.env.file_name._default | quote }}
- name: VAULT_ADDR
  value: {{ include "vault.addr" . | quote }}
- name: VAULT_AUTH_TOKEN_FILE_PATH
  value: {{ pluck .Values.global.env .Values.terraformer.vault.token_path | first | default .Values.terraformer.vault.token_path._default | quote }}
- name: PGHOST
  value: {{ pluck .Values.global.env .Values.terraformer.db.host | first | default .Values.terraformer.db.host._default | quote }}
- name: PGPORT
  value: {{ pluck .Values.global.env .Values.terraformer.db.port | first | default .Values.terraformer.db.port._default | quote }}
- name: PGDATABASE
  value: {{ pluck .Values.global.env .Values.terraformer.db.name | first | default .Values.terraformer.db.name._default | quote }}
- name: PGSSLMODE
  value: {{ pluck .Values.global.env .Values.terraformer.db.ssl_mode | first | default .Values.terraformer.db.ssl_mode._default | quote }}
- name: PG_SCHEMA_NAME
  value: {{ pluck .Values.global.env .Values.terraformer.db.schema | first | default .Values.terraformer.db.schema._default | quote }}
- name: TRFRM_PROJECT_NAME
  value: {{ include "app.name" . }}
- name: TRFRM_SOURCE_DIR
  value: {{ pluck .Values.global.env .Values.terraformer.terrraformDirectory.source_code | first | default .Values.terraformer.terrraformDirectory.source_code._default | quote }}
- name: TRFRM_WORK_DIR
  value: {{ pluck .Values.global.env .Values.terraformer.terrraformDirectory.work | first | default .Values.terraformer.terrraformDirectory.work._default | quote }}
- name: TRRFRM_TMP_EXECUTION_DIR
  value: /tmp/{{ include "app.name" . }}.{{ .TmpDirPostfix }}
- name: TRFRM_DATA_DIR
  value: {{ include "trrfrm.dataDir" . }}
- name: TRFRM_PLUGIN_CACHE_DIR
  value: {{ pluck .Values.global.env .Values.terraformer.terrraformDirectory.cache | first | default .Values.terraformer.terrraformDirectory.cache._default | quote }}
{{- end }}