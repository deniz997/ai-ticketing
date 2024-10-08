# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

receivers:
  otlp:
    protocols:
      grpc:
      http:
        cors:
          allowed_origins:
            - "http://*"
            - "https://*"
  httpcheck/frontendproxy:
    targets:
      - endpoint: http://frontendproxy:$${env:ENVOY_PORT}
  redis:
    endpoint: "redis-cart:6379"
    collection_interval: 10s

exporters:
  debug:
  otlp:
    endpoint: "jaeger:4317"
    tls:
      insecure: true
  otlphttp/prometheus:
    endpoint: "http://prometheus:9090/api/v1/otlp"
    tls:
      insecure: true
  opensearch:
    logs_index: otel
    http:
      endpoint: "http://opensearch:9200"
      tls:
        insecure: true
  otlphttp/express:
    endpoint: ${ai_ticketing_endpoint}
    encoding: json
    tls:
      insecure: true

processors:
  batch:
  groupbytrace/2:
    wait_duration: 11s
  filter/traces:
    error_mode: propagate
    traces:
      span:
        - 'status.code != 2'


connectors:
  spanmetrics:

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [groupbytrace/2, filter/traces]
      exporters: [otlp, debug, spanmetrics, debug, otlphttp/express]
    metrics:
      receivers: [httpcheck/frontendproxy, redis, otlp, spanmetrics]
      processors: [batch]
      exporters: [otlphttp/prometheus, debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [opensearch, debug]
