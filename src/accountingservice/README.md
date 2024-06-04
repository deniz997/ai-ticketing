# Accounting Service

This service consumes new orders from a Kafka topic.

## Local Build

To build the service binary, run:

```sh
go build -o /go/bin/accountingservice/
```

## Docker Build

From the root directory, run:

```sh
docker compose build accountingservice
```

## Regenerate protos

> [!NOTE]
> [`protoc`](https://grpc.io/docs/protoc-installation/) is required.

To regenerate gRPC code run:

```sh
go generate
```

## Bump dependencies

To bump all dependencies run:

```sh
go get -u -t ./...
go mod tidy
```

## Docker Build

From the root directory, run:

**GitLab container registry:**
```sh
docker login git.tu-berlin.de:5000
docker build -t git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/accountingservice:original -f ./src/accountingservice/Dockerfile .
docker push git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/accountingservice:original
```
