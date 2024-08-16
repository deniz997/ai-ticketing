# Approach 2 - Automated API Documentation

This project is a fork from the baseline repository OpenTelemetry Demo.
It contains the changes to execute the approach to AI ticket generation via OpenAI Chat Completion API and publish it to a Notion database.

## Quick start

Follow the instructions in the [REPRODUCTION.md](REPRODUCTION.md) file.

## Folder Structure

- iac. Contains Infrastructure as Code for different cloud providers (GCP, AWS) Only GCP is supported.
- internal. Tools for sanity checks and other utilities
- kubernetes. Contains a single file with all Kubernetes manifests to create the application
- pb. Protocol Buffers demo files
- src. Source code for each microservice
    - [accountingservice](./src/accountingservice/README.md)
    - [adservice](./src/adservice/README.md)
    - [cartservice](./src/cartservice/README.md)
    - [checkoutservice](./src/checkoutservice/README.md)
    - [currencyservice](./src/currencyservice/README.md)
    - [emailservice](./src/emailservice/README.md)
    - [flagd](./src/flagd/README.md)
    - [frauddetectionservice](./src/frauddetectionservice/README.md)
    - [frontend](./src/frontend/README.md)
    - [frontendproxy](./src/frontendproxy/README.md)
    - [grafana](./src/grafana/README.md)
    - [imageprovider](./src/imageprovider/README.md)
    - [kafka](./src/kafka/README.md)
    - [loadgenerator](./src/loadgenerator/README.md)
    - [otelcollector](./src/otelcollector/README.md)
    - [paymentservice](./src/paymentservice/README.md)
    - [productcatalogservice](./src/productcatalogservice/README.md)
    - [prometheus](./src/prometheus/README.md)
    - [quoteservice](./src/quoteservice/README.md)
    - [recommendationservice](./src/recommendationservice/README.md)
    - [shippingservice](./src/shippingservice/README.md)
    - [ticketingservice](./src/ticketingservice/README.md)
- mttd. Mean time to detect evaluation
