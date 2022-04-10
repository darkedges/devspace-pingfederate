#!/bin/bash -ex

echo "Setup"

#Create Password Files
echo "${DIRECTORY_ROOT_USER_PASSWORD:-Passw0rd}" > /tmp/rootUserPasswordFile
echo "${DIRECTORY_ENCRYPTION_PASSWORD:-Passw0rd}" > /tmp/encryptDataWithPassphraseFromFile

re='^[0-9]+$'
EXTRA_OPTIONS=""
if [[ $DIRECTORY_SAMPLE_DATA  =~ $re ]]; then
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --sampleData ${DIRECTORY_SAMPLE_DATA}"
else
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --addBaseEntry"
fi

if [[ ! -z ${DIRECTORY_USE_JAVA_TRUSTSTORE} ]]; then
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --useJavaTruststore ${DIRECTORY_USE_JAVA_TRUSTSTORE}"
fi
if [[ ! -z ${DIRECTORY_TRUST_STORE_PASSWORD_FILE} ]]; then
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --trustStorePasswordFile  ${DIRECTORY_TRUST_STORE_PASSWORD_FILE}"
fi
if [[ ! -z ${DIRECTORY_USE_JAVA_KEYSTORE} ]]; then
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --useJavaKeystore ${DIRECTORY_USE_JAVA_KEYSTORE}"
fi
if [[ ! -z ${DIRECTORY_KEY_STORE_PASSWORD_FILE} ]]; then
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --keyStorePasswordFile ${DIRECTORY_KEY_STORE_PASSWORD_FILE}"
fi

ls -lrt /var/ping/directory/secrets

HOSTNAME=$(hostname -f)

# Setup
./setup \
    --acceptLicense \
    --allowWeakRootUserPassword \
    --baseDN ${DIRECTORY_BASE_DN:-dc=example,dc=com} \
    --doNotStart \
    --enableStartTLS \
    --encryptDataWithPassphraseFromFile /tmp/encryptDataWithPassphraseFromFile \
    --httpsPort ${DIRECTORY_HTTPS_PORT:-443} \
    --instanceName ${DIRECTORY_INSTANCE_NAME:-Instance01} \
    --ldapPort ${DIRECTORY_HTTPS_PORT:-389} \
    --ldapsPort ${DIRECTORY_HTTPS_PORT:-636} \
    --licenseKeyFile /opt/ping/directory/PingDirectory-9.0-Production.lic \
    --localHostName ${HOSTNAME} \
    --location ${DIRECTORY_LOCATION:-Melbourne} \
    --maxHeapSize ${DIRECTORY_MAX_HEAP_SIZEn:-786m} \
    --no-prompt \
    --optionCacheDirectory /opt/ping/directory/logs/option-cache \
    --populateToolPropertiesFile connect \
    --primeDB \
    --rejectInsecureRequests \
    --rootUserDN "${DIRECTORY_ROOT_USER_DN:-cn=Directory Manager}" \
    --rootUserPasswordFile /tmp/rootUserPasswordFile \
    ${EXTRA_OPTIONS}

# Remove all password files
rm -rf /tmp/{rootUserPasswordFile,encryptDataWithPassphraseFromFile}

# This moves everything over to the mount
mkdir -p /var/ping/directory/data/{db,config}
mv /opt/ping/directory/db/* /var/ping/directory/data/db/
mv /opt/ping/directory/config/* /var/ping/directory/data/config/