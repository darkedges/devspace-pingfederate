# Initial Configuration
FROM alpine:3.15.0

COPY config/ /var/tmp/config

RUN apk add --no-cache zip && \
    cd /var/tmp/config/ && \
    zip -r /var/tmp/data.zip *

FROM darkedges/pingfederate_base:11.0.2

COPY --chown=ping:ping license/PingFederate-11.0-Production.lic /opt/ping/federate/server/default/conf/pingfederate.lic
COPY --from=0 --chown=ping:ping /var/tmp/data.zip /opt/ping/federate/server/default/data/drop-in-deployer/data.zip