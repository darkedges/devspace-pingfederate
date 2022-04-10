#!/bin/bash -eux

echo "Setup"

#Create Password Files
echo "Passw0rd" > /tmp/rootUserPasswordFile
echo "Passw0rd" > /tmp/encryptDataWithPassphraseFromFile

# Setup
./setup \
    --acceptLicense \
    --allowWeakRootUserPassword \
    --addBaseEntry \
    --baseDN dc=example,dc=com \
    --doNotStart \
    --enableStartTLS \
    --encryptDataWithPassphraseFromFile /tmp/encryptDataWithPassphraseFromFile \
    --generateSelfSignedCertificate \
    --httpsPort 443 \
    --instanceName Melbourne01 \
    --ldapPort 389 \
    --ldapsPort 636 \
    --licenseKeyFile /opt/ping/directory/PingDirectory-9.0-Production.lic \
    --localHostName e409879c2bc9 \
    --location Melbourne \
    --maxHeapSize 768m \
    --no-prompt \
    --optionCacheDirectory /opt/ping/directory/logs/option-cache \
    --populateToolPropertiesFile connect \
    --primeDB \
    --rejectInsecureRequests \
    --rootUserDN "cn=Directory Manager" \
    --rootUserPasswordFile /tmp/rootUserPasswordFile \
    --skipHostnameCheck

# Remove all password files
rm -rf /tmp/{rootUserPasswordFile,encryptDataWithPassphraseFromFile}

# This moves everything over to the mount
mkdir -p /var/ping/directory/data/{db,config} 
mv /opt/ping/directory/db/* /var/ping/directory/data/db/ 
mv /opt/ping/directory/config/* /var/ping/directory/data/config/ 