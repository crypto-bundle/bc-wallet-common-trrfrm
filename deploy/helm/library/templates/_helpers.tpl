{{/*
Copyright (c) 2024 Aleksei Kotelnikov(gudron2s@gmail.com)
License: MIT NON-AI
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "trrfrm.app.name" -}}
{{- default .Values.terraformer.fullnameOverride .Values.terraformer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "trrfrm.app.chart" -}}
{{- printf "%s-%s" .Values.terraformer.nameOverride .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "trrfrmr.app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trrfrm.app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "trrfrm.app.labels" -}}
helm.sh/chart: {{ include "trrfrm.app.chart" . }}
{{ include "trrfrmr.app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Hashicorp Vault agent annotations
*/}}
{{- define "_trrfrmr.vault_agent_annotations" }}
vault.hashicorp.com/agent-inject: {{ pluck .Values.global.env .Values.terraformer.vault.agent.inject | first | default .Values.terraformer.vault.agent.inject._default | quote }}
vault.hashicorp.com/role: {{ pluck .Values.global.env .Values.terraformer.vault.agent.role | first | default .Values.terraformer.vault.agent.role._default | quote }}
vault.hashicorp.com/agent-inject-perms: {{ pluck .Values.global.env .Values.terraformer.vault.agent.inject_perms | first | default .Values.terraformer.vault.agent.inject_perms._default | quote }}
vault.hashicorp.com/agent-init-first: {{ pluck .Values.global.env .Values.terraformer.vault.agent.init_first | first | default .Values.terraformer.vault.agent.init_first._default | quote }}
vault.hashicorp.com/agent-pre-populate-only: {{ pluck .Values.global.env .Values.terraformer.vault.agent.pre_populate | first | default .Values.terraformer.vault.agent.pre_populate._default | quote }}
vault.hashicorp.com/agent-inject-token: {{ pluck .Values.global.env .Values.terraformer.vault.agent.inject_token | first | default .Values.terraformer.vault.agent.inject_token._default | quote }}
vault.hashicorp.com/agent-run-as-user: {{ .Values.terraformer.securityContext.runAsUser | quote }}
vault.hashicorp.com/agent-inject-secret-{{ .Values.terraformer.env.file_name._default | base }}: {{ .Values.terraformer.vault.agent.inject_secret_path | quote }}
vault.hashicorp.com/agent-inject-template-{{ .Values.terraformer.env.file_name._default | base}}: |
{{- .Values.terraformer.vault.agent.inject_template | nindent 2 }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "trrfrmr.pv.prefix" -}}
bc-wallet-common-trrfrm
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "trrfrmr.vault.addr" -}}
{{- $host := pluck .Values.global.env .Values.terraformer.vault.host | first | default .Values.terraformer.vault.host._default -}}
{{- $port := pluck .Values.global.env .Values.terraformer.vault.port | first | default .Values.terraformer.vault.port._default | int -}}
{{- $schema := "http://" -}}
{{- if pluck .Values.global.env .Values.terraformer.vault.use_https | first | default .Values.terraformer.vault.use_https._default -}}
    {{- $schema = "https://" -}}
{{- end -}}
{{- printf "%s%s:%d" $schema $host $port -}}
{{- end -}}

{{- define "trrfrm.dataDir" -}}
{{- $workDir := pluck .Values.global.env .Values.terraformer.terrraformDirectory.work | first | default .Values.terraformer.terrraformDirectory.work._default -}}
{{- $projectName := include "trrfrm.app.name" . -}}
{{- printf "%s/%s/%s" $workDir $projectName ".terraform" -}}
{{- end -}}

{{- define "trrfrm.tmpExecutionDir" -}}
/tmp/{{ include "trrfrm.app.name" . }}.{{ randNumeric 7 | nospace }}
{{- end -}}

{{- define "trrfrmr.serviceAccount.name" -}}
{{- .Values.terraformer.serviceAccount.worker.name | quote -}}
{{- end -}}

{{- define "trrfrmr.subchart.init.containers" -}}
{{- end -}}