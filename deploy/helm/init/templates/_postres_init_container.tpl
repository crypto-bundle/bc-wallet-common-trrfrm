{{/*
Copyright (c) 2024 Aleksei Kotelnikov(gudron2s@gmail.com)
License: MIT NON-AI
*/}}
{{- define "subchart.init.containers" -}}
- name: {{ include "app.name" . }}-pg-init
  image: {{ .Values.pg.image.path }}:{{ .Values.pg.image.tag }}
  imagePullPolicy: {{ .Values.pg.image.pullPolicy }}
  securityContext:
    {{- toYaml .Values.pg.securityContext | nindent 4 }}
  resources:
    {{- toYaml .Values.pg.resources | nindent 4 }}
  env:
    {{- include "_env_pg" . | nindent 4 }}
  args:
    - "createdb"
    - {{ pluck .Values.global.env .Values.terraformer.db.name | first | default .Values.terraformer.db.name._default | quote }}
{{- end -}}