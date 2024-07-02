{{/*
Copyright (c) 2024 Aleksei Kotelnikov(gudron2s@gmail.com)
License: MIT NON-AI
*/}}

{{/*
Sets VolumeClaim annotations for data volume
*/}}
{{- define "providersVolumeClaim.annotations" -}}
  {{- if and (.Values.terraformer.providersStorage.enabled) (.Values.terraformer.providersStorage.annotations) }}
  annotations:
    {{- $tp := typeOf .Values.terraformer.providersStorage.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.terraformer.providersStorage.annotations . | nindent 4 }}
    {{- else }}
      {{- toYaml .Values.terraformer.providersStorage.annotations | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Set's up the volumeClaimTemplates when data or audit storage is required.  HA
might not use data storage since Consul is likely it's backend, however, audit
storage might be desired by the user.
*/}}
{{- define "providersVolumeClaim" -}}
  {{- if .Values.terraformer.providersStorage.enabled }}
  volumeClaimTemplates:
    - metadata:
        name: {{ include "trrfrm.app.name" . }}-providers
        {{- include "providersVolumeClaim.annotations" . | nindent 6 }}
      spec:
        accessModes:
          - {{ .Values.terraformer.providersStorage.accessMode | default "ReadWriteOnce" }}
        resources:
          requests:
            storage: {{ .Values.terraformer.providersStorage.size }}
          {{- if .Values.terraformer.providersStorage.storageClass }}
        storageClassName: {{ .Values.terraformer.providersStorage.storageClass }}
          {{- end }}
  {{ end }}
{{- end -}}