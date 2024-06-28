{{/*
Copyright (c) 2024 Aleksei Kotelnikov(gudron2s@gmail.com)
License: MIT NON-AI
*/}}
{{- define "_env_pg" -}}
- name: APP_LOCAL_ENV_FILE_PATH
  value: {{ pluck .Values.global.env .Values.pg.env.file_name | first | default .Values.pg.env.file_name._default | quote }}
- name: PGHOST
  value: {{ pluck .Values.global.env .Values.terraformer.db.host | first | default .Values.terraformer.db.host._default | quote }}
- name: PGPORT
  value: {{ pluck .Values.global.env .Values.terraformer.db.port | first | default .Values.terraformer.db.port._default | quote }}
- name: PGDATABASE
  value: {{ pluck .Values.global.env .Values.terraformer.db.name | first | default .Values.terraformer.db.name._default | quote }}
- name: PGSSLMODE
  value: {{ pluck .Values.global.env .Values.terraformer.db.ssl_mode | first | default .Values.terraformer.db.ssl_mode._default | quote }}
- name: TRFRM_PROJECT_NAME
  value: {{ include "app.name" . }}
{{- end }}