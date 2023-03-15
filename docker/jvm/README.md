# JVM

## Build JRE

```bash
docker build . -t darkedges/jvm:11-jre-alpine
```

## Build JVM

```bash
docker build . --build-arg JVM_TAG=11-jdk-alpine -t darkedges/jvm:11-jdk-alpine
```
