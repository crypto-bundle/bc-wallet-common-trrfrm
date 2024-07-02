{{/*
Overwrite library chart service account name
*/}}
{{- define "trrfrmr.serviceAccount.name" -}}
{{- .Values.terraformer.serviceAccount.init.name | quote -}}
{{- end -}}