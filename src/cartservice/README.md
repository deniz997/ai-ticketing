# Cart Service

This service stores user shopping carts in Redis.

## Local Build

Run `dotnet restore` and `dotnet build`.

Protobufs must be present in `./src/protos`

## Docker Build

From the root directory, run:

```sh
docker compose build cartservice
```
## Docker Build

From the root directory, run:

**GitLab container registry:**
```sh
docker login git.tu-berlin.de:5000
docker build -t git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/cartservice:original -f ./src/cartservice/src/Dockerfile .
docker push git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/cartservice:original
```
