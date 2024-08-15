# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

x-default-logging: &logging
  driver: "json-file"
  options:
    max-size: "5m"
    max-file: "2"
    tag: "{{.Name}}"

networks:
  default:
    name: opentelemetry-demo
    driver: bridge

services:
  # ******************
  # Core Demo Services
  # ******************
  # Accounting service
  accountingservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-accountingservice
    container_name: accounting-service
    build:
      context: ./
      dockerfile: ./src/accountingservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-accountingservice
    deploy:
      resources:
        limits:
          memory: 20M
    restart: unless-stopped
    environment:
      - KAFKA_SERVICE_ADDR
      - OTEL_EXPORTER_OTLP_ENDPOINT
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=accountingservice
    depends_on:
      otelcol:
        condition: service_started
      kafka:
        condition: service_healthy
    logging: *logging

  # AdService
  adservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-adservice
    container_name: ad-service
    build:
      context: ./
      dockerfile: ./src/adservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-adservice
    deploy:
      resources:
        limits:
          memory: 300M
    restart: unless-stopped
    ports:
      - "$${AD_SERVICE_PORT}"
    environment:
      - AD_SERVICE_PORT
      - FLAGD_HOST
      - FLAGD_PORT
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://$${OTEL_COLLECTOR_HOST}:$${OTEL_COLLECTOR_PORT_HTTP}
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_LOGS_EXPORTER=otlp
      - OTEL_SERVICE_NAME=adservice
    depends_on:
      otelcol:
        condition: service_started
      flagd:
        condition: service_started
    logging: *logging

  # Cart service
  cartservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-cartservice
    container_name: cart-service
    build:
      context: ./
      dockerfile: ./src/cartservice/src/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-cartservice
    deploy:
      resources:
        limits:
          memory: 160M
    restart: unless-stopped
    ports:
      - "$${CART_SERVICE_PORT}"
    environment:
      - CART_SERVICE_PORT
      - FLAGD_HOST
      - FLAGD_PORT
      - REDIS_ADDR
      - OTEL_EXPORTER_OTLP_ENDPOINT
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=cartservice
      - ASPNETCORE_URLS=http://*:$${CART_SERVICE_PORT}
    depends_on:
      redis-cart:
        condition: service_started
      otelcol:
        condition: service_started
      flagd:
        condition: service_started
    logging: *logging

  # Checkout service
  checkoutservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-checkoutservice
    container_name: checkout-service
    build:
      context: ./
      dockerfile: ./src/checkoutservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-checkoutservice
    deploy:
      resources:
        limits:
          memory: 20M
    restart: unless-stopped
    ports:
      - "$${CHECKOUT_SERVICE_PORT}"
    environment:
      - FLAGD_HOST
      - FLAGD_PORT
      - CHECKOUT_SERVICE_PORT
      - CART_SERVICE_ADDR
      - CURRENCY_SERVICE_ADDR
      - EMAIL_SERVICE_ADDR
      - PAYMENT_SERVICE_ADDR
      - PRODUCT_CATALOG_SERVICE_ADDR
      - SHIPPING_SERVICE_ADDR
      - KAFKA_SERVICE_ADDR
      - OTEL_EXPORTER_OTLP_ENDPOINT
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=checkoutservice
    depends_on:
      cartservice:
        condition: service_started
      currencyservice:
        condition: service_started
      emailservice:
        condition: service_started
      paymentservice:
        condition: service_started
      productcatalogservice:
        condition: service_started
      shippingservice:
        condition: service_started
      otelcol:
        condition: service_started
      kafka:
        condition: service_healthy
      flagd:
        condition: service_started
    logging: *logging

  # Currency service
  currencyservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-currencyservice
    container_name: currency-service
    build:
      context: ./
      dockerfile: ./src/currencyservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-currencyservice
    deploy:
      resources:
        limits:
          memory: 20M
    restart: unless-stopped
    ports:
      - "$${CURRENCY_SERVICE_PORT}"
    environment:
      - CURRENCY_SERVICE_PORT
      - VERSION=$${IMAGE_VERSION}
      - OTEL_EXPORTER_OTLP_ENDPOINT
      - OTEL_RESOURCE_ATTRIBUTES=$${OTEL_RESOURCE_ATTRIBUTES},service.name=currencyservice   # The C++ SDK does not support OTEL_SERVICE_NAME
    depends_on:
      otelcol:
        condition: service_started
    logging: *logging

  # Email service
  emailservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-emailservice
    container_name: email-service
    build:
      context: ./src/emailservice
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-emailservice
    deploy:
      resources:
        limits:
          memory: 100M
    restart: unless-stopped
    ports:
      - "$${EMAIL_SERVICE_PORT}"
    environment:
      - APP_ENV=production
      - EMAIL_SERVICE_PORT
      - OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://$${OTEL_COLLECTOR_HOST}:$${OTEL_COLLECTOR_PORT_HTTP}/v1/traces
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=emailservice
    depends_on:
      otelcol:
        condition: service_started
    logging: *logging

  # Fraud Detection service
  frauddetectionservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-frauddetectionservice
    container_name: frauddetection-service
    build:
      context: ./
      dockerfile: ./src/frauddetectionservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-frauddetectionservice
    deploy:
      resources:
        limits:
          memory: 300M
    restart: unless-stopped
    environment:
      - FLAGD_HOST
      - FLAGD_PORT
      - KAFKA_SERVICE_ADDR
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://$${OTEL_COLLECTOR_HOST}:$${OTEL_COLLECTOR_PORT_HTTP}
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - OTEL_INSTRUMENTATION_KAFKA_EXPERIMENTAL_SPAN_ATTRIBUTES=true
      - OTEL_INSTRUMENTATION_MESSAGING_EXPERIMENTAL_RECEIVE_TELEMETRY_ENABLED=true
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=frauddetectionservice
    depends_on:
      otelcol:
        condition: service_started
      kafka:
        condition: service_healthy
    logging: *logging

  # Frontend
  frontend:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-frontend
    container_name: frontend
    build:
      context: ./
      dockerfile: ./src/frontend/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-frontend
    deploy:
      resources:
        limits:
          memory: 250M
    restart: unless-stopped
    ports:
      - "$${FRONTEND_PORT}"
    environment:
      - PORT=$${FRONTEND_PORT}
      - FRONTEND_ADDR
      - AD_SERVICE_ADDR
      - CART_SERVICE_ADDR
      - CHECKOUT_SERVICE_ADDR
      - CURRENCY_SERVICE_ADDR
      - PRODUCT_CATALOG_SERVICE_ADDR
      - RECOMMENDATION_SERVICE_ADDR
      - SHIPPING_SERVICE_ADDR
      - OTEL_EXPORTER_OTLP_ENDPOINT
      - OTEL_RESOURCE_ATTRIBUTES=$${OTEL_RESOURCE_ATTRIBUTES}
      - ENV_PLATFORM
      - OTEL_SERVICE_NAME=frontend
      - PUBLIC_OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - WEB_OTEL_SERVICE_NAME=frontend-web
      - OTEL_COLLECTOR_HOST
      - FLAGD_HOST
      - FLAGD_PORT
    depends_on:
      adservice:
        condition: service_started
      cartservice:
        condition: service_started
      checkoutservice:
        condition: service_started
      currencyservice:
        condition: service_started
      productcatalogservice:
        condition: service_started
      quoteservice:
        condition: service_started
      recommendationservice:
        condition: service_started
      shippingservice:
        condition: service_started
      otelcol:
        condition: service_started
      imageprovider:
        condition: service_started
      flagd:
        condition: service_started
    logging: *logging

  # Frontend Proxy (Envoy)
  frontendproxy:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-frontendproxy
    container_name: frontend-proxy
    build:
      context: ./
      dockerfile: src/frontendproxy/Dockerfile
    deploy:
      resources:
        limits:
          memory: 50M
    restart: unless-stopped
    ports:
      - "$${ENVOY_PORT}:$${ENVOY_PORT}"
      - 10000:10000
    environment:
      - FRONTEND_PORT
      - FRONTEND_HOST
      - LOCUST_WEB_HOST
      - LOCUST_WEB_PORT
      - GRAFANA_SERVICE_PORT
      - GRAFANA_SERVICE_HOST
      - JAEGER_SERVICE_PORT
      - JAEGER_SERVICE_HOST
      - OTEL_COLLECTOR_HOST
      - IMAGE_PROVIDER_HOST
      - IMAGE_PROVIDER_PORT
      - OTEL_COLLECTOR_PORT_GRPC
      - OTEL_COLLECTOR_PORT_HTTP
      - OTEL_RESOURCE_ATTRIBUTES
      - ENVOY_PORT
      - FLAGD_HOST
      - FLAGD_PORT
    depends_on:
      frontend:
        condition: service_started
      loadgenerator:
        condition: service_started
      jaeger:
        condition: service_started
      grafana:
        condition: service_started

  # Imageprovider
  imageprovider:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-imageprovider
    container_name: imageprovider
    build:
      context: ./
      dockerfile: ./src/imageprovider/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-imageprovider
    deploy:
      resources:
        limits:
          memory: 120M
    restart: unless-stopped
    ports:
      - "$${IMAGE_PROVIDER_PORT}"
    environment:
      - IMAGE_PROVIDER_PORT
      - OTEL_COLLECTOR_HOST
      - OTEL_COLLECTOR_PORT_GRPC
      - OTEL_SERVICE_NAME=imageprovider
      - OTEL_RESOURCE_ATTRIBUTES
    depends_on:
      otelcol:
        condition: service_started
    logging: *logging

  # Load Generator
  loadgenerator:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-loadgenerator
    container_name: load-generator
    build:
      context: ./
      dockerfile: ./src/loadgenerator/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-loadgenerator
    deploy:
      resources:
        limits:
          memory: 1G
    restart: unless-stopped
    ports:
      - "$${LOCUST_WEB_PORT}"
    environment:
      - LOCUST_WEB_PORT
      - LOCUST_USERS
      - LOCUST_HOST
      - LOCUST_HEADLESS
      - LOCUST_AUTOSTART
      - LOCUST_BROWSER_TRAFFIC_ENABLED=true
      - OTEL_EXPORTER_OTLP_ENDPOINT
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=loadgenerator
      - PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
      - LOCUST_WEB_HOST=0.0.0.0
      - FLAGD_HOST
      - FLAGD_PORT
    depends_on:
      frontend:
        condition: service_started
      flagd:
        condition: service_started
    logging: *logging

  # Payment service
  paymentservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-paymentservice
    container_name: payment-service
    build:
      context: ./
      dockerfile: ./src/paymentservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-paymentservice
    deploy:
      resources:
        limits:
          memory: 120M
    restart: unless-stopped
    ports:
      - "$${PAYMENT_SERVICE_PORT}"
    environment:
      - PAYMENT_SERVICE_PORT
      - FLAGD_HOST
      - FLAGD_PORT
      - OTEL_EXPORTER_OTLP_ENDPOINT
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=paymentservice
    depends_on:
      otelcol:
        condition: service_started
      flagd:
        condition: service_started
    logging: *logging

  # Product Catalog service
  productcatalogservice:
    image: git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/productcatalogservice #$${IMAGE_NAME}:$${DEMO_VERSION}-productcatalogservice
    container_name: product-catalog-service
    build:
      context: ./
      dockerfile: ./src/productcatalogservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-productcatalogservice
    deploy:
      resources:
        limits:
          memory: 20M
    restart: unless-stopped
    ports:
      - "$${PRODUCT_CATALOG_SERVICE_PORT}"
    environment:
      - PRODUCT_CATALOG_SERVICE_PORT
      - FLAGD_HOST
      - FLAGD_PORT
      - OTEL_EXPORTER_OTLP_ENDPOINT
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=productcatalogservice
    depends_on:
      otelcol:
        condition: service_started
      flagd:
        condition: service_started
    logging: *logging

  # Quote service
  quoteservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-quoteservice
    container_name: quote-service
    build:
      context: ./
      dockerfile: ./src/quoteservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-quoteservice
    deploy:
      resources:
        limits:
          memory: 40M
    restart: unless-stopped
    ports:
      - "$${QUOTE_SERVICE_PORT}"
    environment:
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://$${OTEL_COLLECTOR_HOST}:$${OTEL_COLLECTOR_PORT_HTTP}
      - OTEL_PHP_AUTOLOAD_ENABLED=true
      - QUOTE_SERVICE_PORT
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=quoteservice
      - OTEL_PHP_INTERNAL_METRICS_ENABLED=true
    depends_on:
      otelcol:
        condition: service_started
    logging: *logging

  # Recommendation service
  recommendationservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-recommendationservice
    container_name: recommendation-service
    build:
      context: ./
      dockerfile: ./src/recommendationservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-recommendationservice
    deploy:
      resources:
        limits:
          memory: 500M               # This is high to enable supporting the recommendationCache feature flag use case
    restart: unless-stopped
    ports:
      - "$${RECOMMENDATION_SERVICE_PORT}"
    environment:
      - RECOMMENDATION_SERVICE_PORT
      - PRODUCT_CATALOG_SERVICE_ADDR
      - FLAGD_HOST
      - FLAGD_PORT
      - OTEL_PYTHON_LOG_CORRELATION=true
      - OTEL_EXPORTER_OTLP_ENDPOINT
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=recommendationservice
      - PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
    depends_on:
      productcatalogservice:
        condition: service_started
      otelcol:
        condition: service_started
      flagd:
        condition: service_started
    logging: *logging

  # Shipping service
  shippingservice:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-shippingservice
    container_name: shipping-service
    build:
      context: ./
      dockerfile: ./src/shippingservice/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-shippingservice
    deploy:
      resources:
        limits:
          memory: 20M
    restart: unless-stopped
    ports:
      - "$${SHIPPING_SERVICE_PORT}"
    environment:
      - SHIPPING_SERVICE_PORT
      - QUOTE_SERVICE_ADDR
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://$${OTEL_COLLECTOR_HOST}:$${OTEL_COLLECTOR_PORT_GRPC}
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=shippingservice
    depends_on:
      otelcol:
        condition: service_started
    logging: *logging

  # ******************
  # Dependent Services
  # ******************
  # Flagd, feature flagging service
  flagd:
    image: ghcr.io/open-feature/flagd:v0.10.1
    container_name: flagd
    deploy:
      resources:
        limits:
          memory: 50M
    environment:
      - FLAGD_OTEL_COLLECTOR_URI=$${OTEL_COLLECTOR_HOST}:$${OTEL_COLLECTOR_PORT_GRPC}
      - FLAGD_METRICS_EXPORTER=otel
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=flagd
    command: [
      "start",
      "--uri",
      "file:./etc/flagd/demo.flagd.json"
    ]
    ports:
      - 8013
    volumes:
      - ./src/flagd:/etc/flagd
    logging:
      *logging

  # Kafka used by Checkout, Accounting, and Fraud Detection services
  kafka:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-kafka
    container_name: kafka
    build:
      context: ./
      dockerfile: ./src/kafka/Dockerfile
      cache_from:
        - $${IMAGE_NAME}:$${IMAGE_VERSION}-kafka
    deploy:
      resources:
        limits:
          memory: 500M
    restart: unless-stopped
    environment:
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://$${OTEL_COLLECTOR_HOST}:$${OTEL_COLLECTOR_PORT_HTTP}
      - OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      - OTEL_RESOURCE_ATTRIBUTES
      - OTEL_SERVICE_NAME=kafka
      - KAFKA_HEAP_OPTS=-Xmx250m -Xms250m
    healthcheck:
      test: nc -z kafka 9092
      start_period: 10s
      interval: 5s
      timeout: 10s
      retries: 10
    logging: *logging

  # Redis used by Cart service
  redis-cart:
    image: $${REDIS_IMAGE}
    container_name: redis-cart
    user: redis
    deploy:
      resources:
        limits:
          memory: 20M
    restart: unless-stopped
    ports:
      - "$${REDIS_PORT}"
    logging: *logging


  # ********************
  # Telemetry Components
  # ********************
  # Jaeger
  jaeger:
    image: $${JAEGERTRACING_IMAGE}
    container_name: jaeger
    command:
      - "--memory.max-traces=5000"
      - "--query.base-path=/jaeger/ui"
      - "--prometheus.server-url=http://$${PROMETHEUS_ADDR}"
      - "--prometheus.query.normalize-calls=true"
      - "--prometheus.query.normalize-duration=true"
    deploy:
      resources:
        limits:
          memory: 400M
    restart: unless-stopped
    ports:
      - "$${JAEGER_SERVICE_PORT}"         # Jaeger UI
      - "$${OTEL_COLLECTOR_PORT_GRPC}"
    environment:
      - METRICS_STORAGE_TYPE=prometheus
    logging: *logging

  # Grafana
  grafana:
    image: $${GRAFANA_IMAGE}
    container_name: grafana
    deploy:
      resources:
        limits:
          memory: 100M
    restart: unless-stopped
    environment:
      - "GF_INSTALL_PLUGINS=grafana-opensearch-datasource"
    volumes:
      - ./src/grafana/grafana.ini:/etc/grafana/grafana.ini
      - ./src/grafana/provisioning/:/etc/grafana/provisioning/
    ports:
      - "$${GRAFANA_SERVICE_PORT}"
    logging: *logging

  # OpenTelemetry Collector
  otelcol:
    image: $${COLLECTOR_CONTRIB_IMAGE}
    container_name: otel-col
    deploy:
      resources:
        limits:
          memory: 200M
    restart: unless-stopped
    command: [ "--config=/etc/otelcol-config.yml", "--config=/etc/otelcol-config-extras.yml" ]
    volumes:
      - ./src/otelcollector/otelcol-config.yml:/etc/otelcol-config.yml
      - ./src/otelcollector/otelcol-config-extras.yml:/etc/otelcol-config-extras.yml
    ports:
#      - "$${OTEL_COLLECTOR_PORT_GRPC}"
#      - "$${OTEL_COLLECTOR_PORT_HTTP}"
      - 1888:1888 # pprof extension
      - 8888:8888 # Prometheus metrics exposed by the Collector
      - 8889:8889 # Prometheus exporter metrics
      - 13133:13133 # health_check extension
      - 4317:4317 # OTLP gRPC receiver
      - 4318:4318 # OTLP http receiver
      - 55679:55679 # zpages extension
    depends_on:
      - jaeger
    logging: *logging
    environment:
      - ENVOY_PORT

  # Prometheus
  prometheus:
    image: $${PROMETHEUS_IMAGE}
    container_name: prometheus
    command:
      - --web.console.templates=/etc/prometheus/consoles
      - --web.console.libraries=/etc/prometheus/console_libraries
      - --storage.tsdb.retention.time=1h
      - --config.file=/etc/prometheus/prometheus-config.yaml
      - --storage.tsdb.path=/prometheus
      - --web.enable-lifecycle
      - --web.route-prefix=/
      - --enable-feature=exemplar-storage
      - --enable-feature=otlp-write-receiver
    volumes:
      - ./src/prometheus/prometheus-config.yaml:/etc/prometheus/prometheus-config.yaml
    deploy:
      resources:
        limits:
          memory: 300M
    restart: unless-stopped
    ports:
      - "$${PROMETHEUS_SERVICE_PORT}:$${PROMETHEUS_SERVICE_PORT}"
    logging: *logging

  # OpenSearch
  opensearch:
    image: $${OPENSEARCH_IMAGE}
    container_name: opensearch
    deploy:
      resources:
        limits:
          memory: 1G
    restart: unless-stopped
    environment:
      - cluster.name=demo-cluster
      - node.name=demo-node
      - bootstrap.memory_lock=true
      - discovery.type=single-node
      - OPENSEARCH_JAVA_OPTS=-Xms300m -Xmx300m
      - DISABLE_INSTALL_DEMO_CONFIG=true
      - DISABLE_SECURITY_PLUGIN=true
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    ports:
      - "9200"
    logging: *logging

  # *****
  # Tests
  # *****
  # Frontend Tests
  frontendTests:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-frontend-tests
    container_name: frontend-tests
    build:
      context: ./
      dockerfile: ./src/frontend/Dockerfile.cypress
    profiles:
      - tests
    volumes:
      - ./src/frontend/cypress/videos:/app/cypress/videos
      - ./src/frontend/cypress/screenshots:/app/cypress/screenshots
    environment:
      - CYPRESS_baseUrl=http://$${FRONTEND_ADDR}
      - FRONTEND_ADDR
      - NODE_ENV=production
    depends_on:
      - frontend

  # Tracebased Tests
  traceBasedTests:
    image: $${IMAGE_NAME}:$${DEMO_VERSION}-traceBasedTests
    container_name: traceBasedTests
    profiles:
      - tests
    build:
      context: ./
      dockerfile: ./test/tracetesting/Dockerfile
    environment:
      - AD_SERVICE_ADDR
      - CART_SERVICE_ADDR
      - CHECKOUT_SERVICE_ADDR
      - CURRENCY_SERVICE_ADDR
      - EMAIL_SERVICE_ADDR
      - FRONTEND_ADDR
      - PAYMENT_SERVICE_ADDR
      - PRODUCT_CATALOG_SERVICE_ADDR
      - RECOMMENDATION_SERVICE_ADDR
      - SHIPPING_SERVICE_ADDR
      - KAFKA_SERVICE_ADDR
    extra_hosts:
      - "host.docker.internal:host-gateway"
    volumes:
      - ./test/tracetesting:/app/test/tracetesting
      - ./pb:/app/pb
    depends_on:
      tracetest-server:
        condition: service_healthy
      # adding demo services as dependencies
      frontend:
        condition: service_started
      adservice:
        condition: service_started
      cartservice:
        condition: service_started
      checkoutservice:
        condition: service_started
      currencyservice:
        condition: service_started
      emailservice:
        condition: service_started
      paymentservice:
        condition: service_started
      productcatalogservice:
        condition: service_started
      recommendationservice:
        condition: service_started
      shippingservice:
        condition: service_started
      quoteservice:
        condition: service_started
      accountingservice:
        condition: service_started
      frauddetectionservice:
        condition: service_started
      flagd:
        condition: service_started

  tracetest-server:
    image: $${TRACETEST_IMAGE}
    platform: linux/amd64
    container_name: tracetest-server
    profiles:
      - tests
      - odd          # Observabilty-Driven Development (ODD)
    volumes:
      - type: bind
        source: ./test/tracetesting/tracetest-config.yaml
        target: /app/tracetest.yaml
      - type: bind
        source: ./test/tracetesting/tracetest-provision.yaml
        target: /app/provision.yaml
    command: --provisioning-file /app/provision.yaml
    ports:
      - 11633:11633
    extra_hosts:
      - "host.docker.internal:host-gateway"
    depends_on:
      tracetest-postgres:
        condition: service_healthy
      otelcol:
        condition: service_started
    healthcheck:
      test: [ "CMD", "wget", "--spider", "localhost:11633" ]
      interval: 1s
      timeout: 3s
      retries: 60

  tracetest-postgres:
    image: $${POSTGRES_IMAGE}
    container_name: tracetest-postgres
    profiles:
      - tests
      - odd          # Observabilty-Driven Development (ODD)
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_USER: postgres
    healthcheck:
      test: pg_isready -U "$$POSTGRES_USER" -d "$$POSTGRES_DB"
      interval: 1s
      timeout: 5s
      retries: 60
    ports:
      - 5432
