# Ping Directory

## Setup

```bash
docker build . -t darkedges/directory:9.0.0.1
docker volume create pingdirectory
docker run --env-file .env -p 636:636 -p 389:389 -p 443:443 --mount source=pingdirectory,target=/var/ping/directory/data -it darkedges/pingdirectory:9.0.0.1 init
docker run --env-file .env -p 636:636 -p 389:389 -p 443:443 --mount source=pingdirectory,target=/var/ping/directory/data -it darkedges/pingdirectory:9.0.0.1 start
```
