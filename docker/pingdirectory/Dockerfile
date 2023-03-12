ARG JVM_IMAGE=darkedges/jvm
ARG JVM_TAG=11-jre-alpine

# Initial Configuration
FROM alpine:3.17.2 as zip
ARG PINGDIRECTORY_VERSION=9.2.0.0
COPY PingDirectory-$PINGDIRECTORY_VERSION.zip /var/tmp/pingdirectory.zip

RUN unzip /var/tmp/pingdirectory.zip -d /var/tmp/

# Runtime deployment
FROM ${JVM_IMAGE}:${JVM_TAG}

WORKDIR /opt/ping/directory

RUN apk add --no-cache tini bash && \
    adduser -h /opt/ping/directory -G ping -D -u 11111 ping && \
    chmod -R 0700 /opt/ping/directory && \
    mkdir -p /var/ping/directory/data && \
    mkdir -p /var/ping/directory/init && \
    chmod 0700 /var/ping/directory && \
    chmod g+s /var/ping/directory 

COPY --from=zip --chown=ping:ping /var/tmp/PingDirectory /opt/ping/directory

ENV PATH=$PATH:/opt/ping/directory/scripts:/opt/ping/directory/bin

COPY --chown=ping:ping rootscripts/ /opt/ping/directory/

RUN chown -R ping:ping /var/ping/directory && \
    chmod 0700 /opt/ping/directory/*.sh && \
    chmod 0700 /opt/ping/directory/default-scripts

VOLUME /var/ping/directory/

USER 11111

ENTRYPOINT  ["/opt/ping/directory/docker-entrypoint.sh"]

CMD ["start"]