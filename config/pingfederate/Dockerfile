ARG PINGFEDERATE_IMAGE=darkedges/pingfederate_base
ARG PINGFEDERATE_TAG=11.2.3

# Initial Configuration
FROM alpine:3.17.2 as config

COPY data/ /var/tmp/data
COPY conf/ /var/tmp/conf
COPY plugins/ /var/tmp/plugins

RUN apk add --no-cache zip && \
    cd /var/tmp/data/ && \
    zip -r /var/tmp/data.zip *

FROM ${PINGFEDERATE_IMAGE}:${PINGFEDERATE_TAG}

COPY --chown=ping:ping license/PingFederate-11.2-Production.lic /opt/ping/federate/server/default/conf/pingfederate.lic
COPY --from=config --chown=ping:ping /var/tmp/data.zip /opt/ping/federate/server/default/data/drop-in-deployer/data.zip
COPY --from=config --chown=ping:ping /var/tmp/plugins/ /opt/ping/federate/server/default/deploy
COPY --from=config --chown=ping:ping /var/tmp/conf/ /opt/ping/federate/server/default/conf
