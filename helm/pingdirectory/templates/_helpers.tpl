{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ping.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ping.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ping.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ping.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "ping.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "ping.frdsServiceName" -}}
{{- $release := index . 0 }}
{{- $name := index . 1 }}
{{- printf "%s-frds-%s" $release $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service to use
*/}}
{{- define "dbServiceName" -}}
{{- $name := default .Values.dbService .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "ping.genSecretName" -}}
{{.root.Release.Name }}-{{- .certificate.secretName | default (printf "%s" .certificate.name)  }}-tls
{{- end -}}

{{- define "ping.genCommonName" -}}
{{- .certificate.commonName | default (printf "%s-%s-0.%s-%s.%s" .root.Release.Name .certificate.name .root.Release.Name .certificate.name .root.Release.Namespace)  }}
{{- end -}}

{{- define "ping.genDNSNames" -}}
{{- if .certificate.dnsNames -}}
{{ .certificate.dnsNames | toYaml | indent 2}}
{{- else -}}
{{- $count := (.root.Values.global.directory.replicas | int) -}}
{{- $root := .root -}}
{{- $certificate := .certificate }}
{{- $r:=list}}
{{- range $index0 := until $count -}}
 {{- $r = append $r (printf "%s-%s-%d\n" $root.Release.Name $certificate.name $index0) -}}
{{- end }}
{{- range $index0 := until $count -}}
 {{- $r = append $r (printf "%s-%s-%d.%s-%s\n" $root.Release.Name $certificate.name $index0 $root.Release.Name $certificate.name) -}}
{{- end }}
{{- range $index0 := until $count -}}
 {{- $r = append $r (printf "%s-%s-%d.%s-%s.%s\n" $root.Release.Name $certificate.name $index0 $root.Release.Name $certificate.name $root.Release.Namespace) -}}
{{- end }}
{{- range $index0 := until $count -}}
 {{- $r = append $r (printf "%s-%s-%d.%s-%s.%s.%s\n" $root.Release.Name $certificate.name $index0 $root.Release.Name $certificate.name $root.Release.Namespace $root.Values.certificates.internal.cluster ) -}}
{{- end }}
{{- range $r -}}
{{ printf "- %s" . | indent 2}}
{{- end -}}
{{- end -}}
{{- end -}}