# Payment Service

This service is responsible for processing and validating payments through the
application.

## Local Build

Copy the `demo.proto` file to this directory and run `npm ci`

## Docker Build

From the root directory, run:

```sh
docker compose build paymentservice
```
## Docker Build

From the root directory, run:

**GitLab container registry:**
```sh
docker login git.tu-berlin.de:5000
docker build -t git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/paymentservice:original -f ./src/paymentservice/Dockerfile .
docker push git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/paymentservice:original
```
