# Shipping Service

The Shipping service queries `quoteservice` for price quote, provides tracking IDs,
and the impression of order fulfillment & shipping processes.

## Local

This repo assumes you have rust 1.73 installed. You may use docker, or install
rust [here](https://www.rust-lang.org/tools/install).

## Build

From `../../`, run:

```sh
docker compose build shippingservice
```

## Test

```sh
cargo test
```
## Docker Build

From the root directory, run:

**GitLab container registry:**
```sh
docker login git.tu-berlin.de:5000
docker build -t git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/shippingservice:original -f ./src/shippingservice/Dockerfile .
docker push git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/shippingservice:original
```
