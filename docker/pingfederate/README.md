# Ping Federate

## Setup

```bash
docker build . -t darkedges/pingfederate_base:11.0.2
docker run --env-file .env -p 9999:9999 -p 9031:9031 -it docker.io/darkedges/pingfederate_base:11.0.2 start
```
