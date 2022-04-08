#!/bin/bash -eux

echo "Setup"

echo "Passw0rd" > /tmp/rootUserPasswordFile
echo "Passw0rd" > /tmp/encryptDataWithPassphraseFromFile

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

rm -rf /tmp/{rootUserPasswordFile,encryptDataWithPassphraseFromFile}