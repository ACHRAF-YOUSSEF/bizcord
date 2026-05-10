{{/*
Expand the name of the chart.
*/}}
{{- define "bizcord.name" -}}
{{- .Chart.Name }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "bizcord.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for a given component.
Usage: include "bizcord.selectorLabels" (dict "component" "backend")
*/}}
{{- define "bizcord.selectorLabels" -}}
app.kubernetes.io/name: {{ .component }}
app.kubernetes.io/instance: {{ $.Release.Name }}
{{- end }}

{{/*
Namespace helper — reads from global.namespace.
*/}}
{{- define "bizcord.namespace" -}}
{{ .Values.global.namespace }}
{{- end }}
