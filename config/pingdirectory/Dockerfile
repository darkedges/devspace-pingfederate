# Initial Configuration
FROM alpine:3.15.0

COPY config/ /var/tmp/config

# Final Configuration
FROM darkedges/pingdirectory_base:9.0.0.1

COPY --chown=ping:ping license/ /opt/ping/directory/