# Recommendation Service

This service provides recommendations for other products based on the currently
selected product.

## Local Build

To build the protos, run:

```sh
pip install -r requirements.txt
python -m pip install grpcio-tools==1.48.2
python -m grpc_tools.protoc -I=../pb/ --python_out=./ --grpc_python_out=./ ../pb/demo.proto
```

## Docker Build

From the root directory, run:

**GitLab container registry:**
```sh
docker login git.tu-berlin.de:5000
docker build -t git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/recommendationservice:original -f ./src/recommendationservice/Dockerfile .
docker push git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/recommendationservice:original
```
