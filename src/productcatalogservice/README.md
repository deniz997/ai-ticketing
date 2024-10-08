# Product Catalog Service

When this service is run the output should be similar to the following

```json
{"message":"successfully parsed product catalog json","severity":"info","timestamp":"2022-06-02T23:54:10.191283363Z"}
{"message":"starting grpc server at :3550","severity":"info","timestamp":"2022-06-02T23:54:10.191849078Z"}
```

## Local Build

To build the service binary, run:

```sh
go build -o /go/bin/productcatalogservice/
```

## Docker Build

From the root directory, run:

```sh
docker compose build productcatalogservice
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

If you want to use `google_container_node_pool` with machine type `e2-medium`, you may need to build your image with `--platform linux/amd64` argument.

```sh
docker login git.tu-berlin.de:5000
docker build -t git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/productcatalogservice:original -f ./src/productcatalogservice/Dockerfile .
docker push git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/productcatalogservice:original
```