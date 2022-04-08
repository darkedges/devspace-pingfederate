# Ping Directory

## Setup

```bash
docker build . -t darkedges/pingdirectory_base:9.0.0.1
docker run --env-file .env -it docker.io/darkedges/pingdirectory_base:9.0.0.1 init
```

## Commands

```bash
ldapsearch -h localhost -p 636 --useSsl --trustAll -D"cn=Directory Manager" -wPassw0rd -b dc=example,dc=com "(objectclass=*)"
```
