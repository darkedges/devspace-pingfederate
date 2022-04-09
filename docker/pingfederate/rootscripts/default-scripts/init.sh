#!/bin/bash -eux

echo "Init"

for var in "${!PF_@}"; do
    case ${var} in
        PF_OPERATIONAL_MODE)
            sed -i "s/^pf\.operational\.mode.*/pf.operational.mode=${!var}/" bin/run.properties
            ;;
        PF_CLUSTER_DISCOVERY_PROTOCOL)
            sed -i "s/^pf\.cluster\.discovery\.protocol.*/pf.cluster.discovery.protocol=${!var}/" bin/jgroups.properties
            ;;
        PF_CLUSTER_DNS_PING_DNS_QUERY)
            sed -i "s/^pf\.cluster\.DNS_PING\.dns_query.*/pf.cluster.DNS_PING.dns_query=${!var}/" bin/jgroups.properties
            ;;
        *)
            echo "Unknown value presented: ${var}"
    esac
done