{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "app.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "app.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{ include "app.selectorLabels" . }}
{{- end -}}

{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "app.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/* Pod template, shared by Deployment and CronJob. */}}
{{- define "app.podSpec" -}}
metadata:
  labels:
    {{- include "app.selectorLabels" . | nindent 4 }}
    {{- with .Values.podLabels }}{{- toYaml . | nindent 4 }}{{- end }}
  {{- if or .Values.config.files .Values.podAnnotations }}
  annotations:
    {{- with .Values.config.files }}
    checksum/config: {{ toYaml . | sha256sum }}
    {{- end }}
    {{- with .Values.podAnnotations }}{{- toYaml . | nindent 4 }}{{- end }}
  {{- end }}
spec:
  {{- if eq .Values.kind "CronJob" }}
  restartPolicy: {{ .Values.cron.restartPolicy }}
  {{- end }}
  serviceAccountName: {{ include "app.serviceAccountName" . }}
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets: {{- toYaml . | nindent 4 }}
  {{- end }}
  securityContext: {{- toYaml .Values.podSecurityContext | nindent 4 }}
  containers:
    - name: {{ include "app.name" . }}
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      securityContext: {{- toYaml .Values.securityContext | nindent 8 }}
      {{- with .Values.command }}
      command: {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.args }}
      args: {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if .Values.service.enabled }}
      ports:
        - name: http
          containerPort: {{ .Values.service.targetPort }}
          protocol: TCP
      {{- end }}
      {{- if or .Values.env .Values.age.enabled }}
      env:
        {{- range $k, $v := .Values.env }}
        - name: {{ $k }}
          value: {{ $v | quote }}
        {{- end }}
        {{- if .Values.age.enabled }}
        {{- with .Values.age.recipients }}
        - name: LITESTREAM_AGE_RECIPIENTS
          value: {{ join "," . | quote }}
        {{- end }}
        {{- if .Values.age.identities.existingSecret }}
        - name: LITESTREAM_AGE_IDENTITIES_FILE
          value: {{ printf "%s/%s" .Values.age.identities.mountPath .Values.age.identities.key | quote }}
        {{- end }}
        {{- end }}
      {{- end }}
      {{- with .Values.envFrom }}
      envFrom: {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.livenessProbe }}
      livenessProbe: {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.readinessProbe }}
      readinessProbe: {{- toYaml . | nindent 8 }}
      {{- end }}
      resources: {{- toYaml .Values.resources | nindent 8 }}
      volumeMounts:
        - name: tmp
          mountPath: /tmp
        {{- if .Values.config.files }}
        - name: config
          mountPath: {{ .Values.config.mountPath }}
          readOnly: true
        {{- end }}
        {{- if and .Values.age.enabled .Values.age.identities.existingSecret }}
        - name: age-identities
          mountPath: {{ .Values.age.identities.mountPath }}
          readOnly: true
        {{- end }}
        {{- if .Values.persistence.enabled }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
        {{- end }}
        {{- with .Values.extraVolumeMounts }}{{- toYaml . | nindent 8 }}{{- end }}
  volumes:
    - name: tmp
      emptyDir: {}
    {{- if .Values.config.files }}
    - name: config
      configMap:
        name: {{ include "app.fullname" . }}
    {{- end }}
    {{- if and .Values.age.enabled .Values.age.identities.existingSecret }}
    - name: age-identities
      secret:
        secretName: {{ .Values.age.identities.existingSecret }}
    {{- end }}
    {{- if .Values.persistence.enabled }}
    - name: data
      persistentVolumeClaim:
        claimName: {{ .Values.persistence.existingClaim | default (include "app.fullname" .) }}
    {{- end }}
    {{- with .Values.extraVolumes }}{{- toYaml . | nindent 4 }}{{- end }}
  {{- with .Values.nodeSelector }}
  nodeSelector: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.tolerations }}
  tolerations: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.affinity }}
  affinity: {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
