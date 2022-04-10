# Initial Configuration
FROM alpine:3.15.0
ARG PINGDIRECTORY_VERSION=9.0.0.1
COPY PingDirectory-$PINGDIRECTORY_VERSION.zip /var/tmp/pingdirectory.zip

RUN unzip /var/tmp/pingdirectory.zip -d /var/tmp/
RUN unzip /var/tmp/PingDirectory/resource/admin-console.zip -d /var/tmp/admin-console

# Runtime deployment
FROM darkedges/tomcat:9.0.62

WORKDIR /usr/local/tomcat

RUN set -ex && \
    rm -rf /usr/local/tomcat/webapps/* && \
    adduser -h /usr/local/tomcat/ -G ping -D -u 11111 ping

COPY --from=0 --chown=ping:ping /var/tmp/admin-console /usr/local/tomcat/webapps/
COPY --chown=ping:ping webapps/ /usr/local/tomcat/webapps/
COPY --chown=ping:ping rootscripts/ /usr/local/tomcat/

RUN chown -R ping:ping /usr/local/tomcat && \
    chmod 0700 /usr/local/tomcat/*.sh

USER 11111

ENTRYPOINT  ["/usr/local/tomcat/docker-entrypoint.sh"]

CMD ["catalina.sh", "run"]