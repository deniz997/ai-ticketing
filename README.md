# OpenTelemetry Demo - Astronomy Shop

- [Official documentation](https://opentelemetry.io/docs/demo/)
- [Original readme](./original_readme.md)

## Quick start

### Minikube

- [Install minikube](https://minikube.sigs.k8s.io/docs/start/)
- Connect to the cluster and execute the following steps
```shell
kubectl create namespace otel-demo
kubectl apply --namespace otel-demo -f https://raw.githubusercontent.com/open-telemetry/opentelemetry-demo/main/kubernetes/opentelemetry-demo.yaml
```

### Google Cloud - GCP

Using terraform, follow the instructions in the found in [iac/gcp/readme.md](./iac/gcp/readme.md)

### AWS

Using terraform, follow the instructions in the found in [iac/aws/readme.md](./iac/aws/readme.md)

## Folder Structure

- iac. Contains Infrastructure as Code for different cloud providers (GCP, AWS)
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
- test. Tracing testing. Documentation [here](./test/README.md)
