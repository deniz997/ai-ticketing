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
- test. Tracing testing. Documentation [here](./test/README.md)
