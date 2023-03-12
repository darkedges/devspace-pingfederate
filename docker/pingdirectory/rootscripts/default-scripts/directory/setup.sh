#!/bin/bash -ex

echo "Setup"

#Create Password Files
echo "${DIRECTORY_ROOT_USER_PASSWORD:-Passw0rd}" > /tmp/rootUserPasswordFile
echo "${DIRECTORY_ENCRYPTION_PASSWORD:-Passw0rd}" > /tmp/encryptDataWithPassphraseFromFile

mkdir -p /var/ping/directory/data/security

re='^[0-9]+$'
EXTRA_OPTIONS=""
if [[ $DIRECTORY_SAMPLE_DATA  =~ $re ]]; then
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --sampleData ${DIRECTORY_SAMPLE_DATA}"
else
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --addBaseEntry"
fi

if [[ ! -z ${DIRECTORY_USE_JAVA_TRUSTSTORE} ]]; then
    f="$(basename -- ${DIRECTORY_USE_JAVA_TRUSTSTORE})"
    cp ${DIRECTORY_USE_JAVA_TRUSTSTORE} /var/ping/directory/data/security/
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --useJavaTruststore /var/ping/directory/data/security/${f}"
fi
if [[ ! -z ${DIRECTORY_TRUST_STORE_PASSWORD_FILE} ]]; then
    f="$(basename -- ${DIRECTORY_TRUST_STORE_PASSWORD_FILE})"
    cp ${DIRECTORY_TRUST_STORE_PASSWORD_FILE} /var/ping/directory/data/security/
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --trustStorePasswordFile  /var/ping/directory/data/security/${f}"
fi
if [[ ! -z ${DIRECTORY_USE_JAVA_KEYSTORE} ]]; then
    f="$(basename -- ${DIRECTORY_USE_JAVA_KEYSTORE})"
    cp ${DIRECTORY_USE_JAVA_KEYSTORE} /var/ping/directory/data/security/
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --useJavaKeystore /var/ping/directory/data/security/${f}"
fi
if [[ ! -z ${DIRECTORY_KEY_STORE_PASSWORD_FILE} ]]; then
    f="$(basename -- ${DIRECTORY_KEY_STORE_PASSWORD_FILE})"
    cp ${DIRECTORY_KEY_STORE_PASSWORD_FILE} /var/ping/directory/data/security/
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --keyStorePasswordFile /var/ping/directory/data/security/${f}"
fi

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
    --licenseKeyFile /opt/ping/directory/PingDirectory.lic \
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

# The following enable the OAuth SASL Handler
cat <<EOF > /tmp/offlineBatchFile
create-external-server --server-name pingauth --type http --set base-url:${OAUTH_BASE_URL}
create-id-token-validator --validator-name "OpenID Token Validator" --type openid-connect --set enabled:true --set "identity-mapper:All Admin Users" --set evaluation-order-index:1 --set issuer-url:${OAUTH_OIDC_ISSUER_URL} --set allowed-signing-algorithm:${OAUTH_ALLOWED_SIGNING_ALGORITHM} --set openid-connect-provider:pingauth --set jwks-endpoint-path:${OAUTH_JWKS_ENDPOINT_PATH}
create-root-dn-user --user-name user.0
create-sasl-mechanism-handler --handler-name OAUTHBEARER --type oauth-bearer --set enabled:true --set "id-token-validator:OpenID Token Validator" --set require-both-access-token-and-id-token:false
set-web-application-extension-prop --extension-name Console --set sso-enabled:true --set oidc-client-id:${OAUTH_OIDC_CLIENT_ID} --set oidc-client-secret:${OAUTH_OIDC_CLIENT_SECRET} --set oidc-issuer-url:${OAUTH_OIDC_ISSUER_URL}
EOF

./bin/dsconfig --offline --no-prompt --batch-file /tmp/offlineBatchFile

# Remove all password files
rm -rf /tmp/{rootUserPasswordFile,encryptDataWithPassphraseFromFile,offlineBatchFile}

# This moves everything over to the mount
mkdir -p /var/ping/directory/data/{db,config}
mv /opt/ping/directory/db/* /var/ping/directory/data/db/
mv /opt/ping/directory/config/* /var/ping/directory/data/config/