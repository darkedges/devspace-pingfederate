# Ping Directory

## Setup

```bash
docker build . -t darkedges/pingdirectory:9.2.0.0
docker volume create pingdirectory
docker run --env-file .env -p 636:636 -p 389:389 -p 443:443 --mount source=pingdirectory,target=/var/ping/directory/data -it darkedges/pingdirectory:9.2.0.0 init
docker run --env-file .env -p 636:636 -p 389:389 -p 443:443 --mount source=pingdirectory,target=/var/ping/directory/data -it darkedges/pingdirectory:9.2.0.0 start
```
