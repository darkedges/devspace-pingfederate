#!/bin/bash -eux

# TrustStore generation
TRUSTSTORE_PASSWORD=changeit
keytool -import -trustcacerts -noprompt -keystore /tmp/truststore.jks -file /usr/local/share/ca-certificates/${NAMESPACE}-root.crt -storepass ${TRUSTSTORE_PASSWORD} -alias DarkEdgesRoot; 
keytool -import -trustcacerts -noprompt -keystore /tmp/truststore.jks -file /usr/local/share/ca-certificates/${NAMESPACE}-intermediate.crt -storepass ${TRUSTSTORE_PASSWORD} -alias DarkEdgesIntermediate; 
TRUSTSTORE_B64=`cat /tmp/truststore.jks|base64 -w0`
TRUSTSTORE_PASSWORD_B64=`echo -n ${TRUSTSTORE_PASSWORD}|base64 -w0`

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${INSTANCE}-${TYPE}-truststore
type: Opaque
data:
  truststore.jks: ${TRUSTSTORE_B64}
  truststore.pin: ${TRUSTSTORE_PASSWORD_B64}
EOF


# KeyStore generation
for FILE in `find  /etc/secret-volume -mindepth 1 -maxdepth 1 -type d`
do
  APP=$(basename "${FILE%.*}")
  KEYSTORE_PASSWORD=$(openssl rand -hex 16)
  openssl pkcs12 -export -inkey ${FILE}/tls.key -in ${FILE}/tls.crt -out /tmp/keystore-${APP}.p12 -password pass:${KEYSTORE_PASSWORD} 
  keytool -importkeystore -noprompt -srckeystore /tmp/keystore-${APP}.p12 -srcstoretype pkcs12 -destkeystore /tmp/keystore-${APP}.jks -storepass ${KEYSTORE_PASSWORD} -srcstorepass ${KEYSTORE_PASSWORD} -destalias "${INSTANCE}-${APP}" -srcalias 1
  KEYSTORE_B64=`cat /tmp/keystore-${APP}.jks|base64 -w0`
  KEYSTORE_PASSWORD_B64=`echo -n ${KEYSTORE_PASSWORD}|base64 -w0`
      
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: Secret
  metadata:
    name: ${INSTANCE}-${APP}-keystore
  type: Opaque
  data:
    keystore.jks: ${KEYSTORE_B64}
    keystore.pin: ${KEYSTORE_PASSWORD_B64}
    truststore.jks: ${TRUSTSTORE_B64}
    truststore.pin: ${TRUSTSTORE_PASSWORD_B64}
EOF
done

rm -rf /tmp/*