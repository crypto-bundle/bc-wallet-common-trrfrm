{{/*
Copyright (c) 2024 Aleksei Kotelnikov(gudron2s@gmail.com)
License: MIT NON-AI
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.terraformer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Hashicorp Vault agent annotations
*/}}
{{- define "_vault_agent_annotations" }}
vault.hashicorp.com/agent-inject: {{ pluck .Values.global.env .Values.terraformer.vault.agent.inject | first | default .Values.terraformer.vault.agent.inject._default | quote }}
vault.hashicorp.com/role: {{ pluck .Values.global.env .Values.terraformer.vault.agent.role | first | default .Values.terraformer.vault.agent.role._default | quote }}
vault.hashicorp.com/agent-inject-perms: {{ pluck .Values.global.env .Values.terraformer.vault.agent.inject_perms | first | default .Values.terraformer.vault.agent.inject_perms._default | quote }}
vault.hashicorp.com/agent-init-first: {{ pluck .Values.global.env .Values.terraformer.vault.agent.init_first | first | default .Values.terraformer.vault.agent.init_first._default | quote }}
vault.hashicorp.com/agent-pre-populate-only: {{ pluck .Values.global.env .Values.terraformer.vault.agent.pre_populate | first | default .Values.terraformer.vault.agent.pre_populate._default | quote }}
vault.hashicorp.com/agent-inject-token: {{ pluck .Values.global.env .Values.terraformer.vault.agent.inject_token | first | default .Values.terraformer.vault.agent.inject_token._default | quote }}
vault.hashicorp.com/agent-run-as-user: {{ .Values.terraformer.securityContext.runAsUser | quote }}
vault.hashicorp.com/agent-inject-secret-{{ .Values.terraformer.env.file_name._default }}: {{ .Values.terraformer.vault.agent.inject_secret_path | quote }}
vault.hashicorp.com/agent-inject-template-{{ .Values.terraformer.env.file_name._default }}: |
{{- .Values.terraformer.vault.agent.inject_template | nindent 2 }}
{{- end }}