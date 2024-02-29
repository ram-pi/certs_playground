#!/bin/sh
set -e

# Creating TLS CA, Certificates and keystore / truststore
rm -rf certs
mkdir -p certs

# Generate CA certificates
echo "Generate Self-Signed Root CA"
openssl req -new -nodes -x509 -days 3650 -newkey rsa:2048 -keyout certs/ca.key -out certs/ca.crt -config ca.cnf
cat certs/ca.crt certs/ca.key >certs/ca.pem

# Generate kafka server certificates
openssl req -new -newkey rsa:2048 -keyout certs/client.key -out certs/client.csr -config client.cnf -nodes
openssl x509 -req -days 3650 -in certs/client.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/client.crt -extfile client.cnf -extensions v3_req
openssl pkcs12 -export -in certs/client.crt -inkey certs/client.key -chain -CAfile certs/ca.pem -name "flink" -out certs/client.p12 -password pass:test1234

# Import server certificate to keystore and CA to truststore
keytool -importkeystore -deststorepass test1234 -destkeystore certs/client.keystore.jks \
    -srckeystore certs/client.p12 \
    -deststoretype PKCS12 \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass test1234
