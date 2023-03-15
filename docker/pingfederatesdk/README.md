# pingfederatesdk

## Build

```console
docker build . -t darkedges/pingfederatesdk:11.2.3
```

## Run

```console
docker run --volume //e/development/projects/ping/pingfederatesdk:/opt/ping/federate/pingfederatesdk darkedges/pingfederatesdk:11.2.3 deploy-plugin -D"target-plugin.name=external-consent-page-example"
```
