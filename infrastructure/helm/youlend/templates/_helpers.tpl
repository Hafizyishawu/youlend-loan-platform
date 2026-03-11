{{/*
Expand the name of the chart.
*/}}
{{- define "youlend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "youlend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "youlend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "youlend.labels" -}}
helm.sh/chart: {{ include "youlend.chart" . }}
{{ include "youlend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "youlend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "youlend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend labels
*/}}
{{- define "youlend.backend.labels" -}}
{{ include "youlend.labels" . }}
app: backend
component: api
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "youlend.backend.selectorLabels" -}}
{{ include "youlend.selectorLabels" . }}
app: backend
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "youlend.frontend.labels" -}}
{{ include "youlend.labels" . }}
app: frontend
component: web
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "youlend.frontend.selectorLabels" -}}
{{ include "youlend.selectorLabels" . }}
app: frontend
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "youlend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "youlend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Backend image
*/}}
{{- define "youlend.backend.image" -}}
{{- printf "%s:%s" .Values.backend.image.repository .Values.backend.image.tag }}
{{- end }}

{{/*
Frontend image
*/}}
{{- define "youlend.frontend.image" -}}
{{- printf "%s:%s" .Values.frontend.image.repository .Values.frontend.image.tag }}
{{- end }}

{{/*
Namespace
*/}}
{{- define "youlend.namespace" -}}
{{- default .Values.global.namespace .Release.Namespace }}
{{- end }}
