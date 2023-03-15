ARG JVM_IMAGE=darkedges/jvm
ARG JVM_TAG=11-jre-alpine

# Initial Configuration
FROM alpine:3.15.0
ARG PINGFEDERATE_VERSION=11.2.3
COPY pingfederate-${PINGFEDERATE_VERSION}.zip /var/tmp/pingfederate.zip

RUN unzip /var/tmp/pingfederate.zip -d /var/tmp/

# Runtime deployment
FROM ${JVM_IMAGE}:${JVM_TAG}
ARG PINGFEDERATE_VERSION=11.2.3
WORKDIR /opt/ping/federate

RUN apk add --no-cache tini bash curl && \
    adduser -h /opt/ping/federate -G ping -D -u 11111 ping && \
    chmod -R 0700 /opt/ping/federate && \
    mkdir -p /var/ping/federate/data && \
    mkdir -p /var/ping/federate/init && \
    chmod 0700 /var/ping/federate && \
    chmod g+s /var/ping/federate 

COPY --from=0 --chown=ping:ping /var/tmp/pingfederate-${PINGFEDERATE_VERSION}/pingfederate/ /opt/ping/federate

ENV PATH=$PATH:/opt/ping/federate/scripts:/opt/ping/federate/bin

COPY --chown=ping:ping rootscripts/ /opt/ping/federate/

RUN chown -R ping:ping /var/ping/federate && \
    chmod 0700 /opt/ping/federate/*.sh && \
    chmod 0700 /opt/ping/federate/default-scripts

VOLUME /var/ping/federate/

USER 11111

ENTRYPOINT  ["/opt/ping/federate/docker-entrypoint.sh"]

CMD ["start"]