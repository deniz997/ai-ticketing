# Frontend Proxy Service

This service acts as a reverse proxy for the various user-facing web interfaces.

## Modifying the Envoy Configuration

The envoy configuration is generated from the `envoy.tmpl.yaml` file in this
directory. Environment variables are substituted at deploy-time.
## Docker Build

From the root directory, run:

**GitLab container registry:**
```sh
docker login git.tu-berlin.de:5000
docker build -t git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/frontendproxy:original -f ./src/frontendproxy/Dockerfile .
docker push git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/frontendproxy:original
```
