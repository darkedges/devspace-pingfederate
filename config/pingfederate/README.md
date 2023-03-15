# Ping Federate

## Setup

```bash
docker build . -t darkedges/pingfederate:11.2.3
```

## Refresh

```console
kubectl delete pods -n pingfederate --selector=app=pingfederate
$pod= kubectl get pods --selector='app=pingfederate,engine=enabled' -o jsonpath='{.items[*].metadata.name}' -n pingfederate ; kubectl exec -it $pod -- bash
```