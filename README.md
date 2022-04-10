# Devspace for Ping Fedrate

## Build Images

```bash
cd docker
cd jre
docker build . -t darkedges/jre:11.0.14_9-jre-alpine
cd ..\tomcat
docker build . --rm -t darkedges/tomcat:9.0.62
cd ..\genjks
docker build . -t darkedges/genjks:1.0.0
cd ..\pingdirectory
docker build . -t darkedges/pingdirectory_base:9.0.0.1
cd ..\pingdirectoryconsole
docker build . --rm -t darkedges/pingdirectoryconsole:9.0.0.1
cd ..\pingfederate
docker build . -t darkedges/pingfederate_base:11.0.2
cd ..\..
cd config
cd pingdirectory
docker build . -t darkedges/pingdirectory:9.0.0.1
cd ..\pingfederate
docker build . -t darkedges/pingfederate:11.0.2
cd ..\..
```