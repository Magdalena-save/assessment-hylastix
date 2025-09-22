#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
DNS="${SERVER_DNS:-example.local}"

mkdir -p /etc/ssl/myca /root/client /var/www/html/downloads
chmod 700 /etc/ssl/myca

# Root CA
openssl genrsa -out /etc/ssl/myca/ca.key 4096
openssl req -x509 -new -nodes -key /etc/ssl/myca/ca.key -sha256 -days 3650 \
  -subj "/C=RS/O=Demo Security/OU=CA/CN=demo-root-ca" -out /etc/ssl/myca/ca.crt

# Server (SAN = DNS)
cat >/etc/ssl/myca/server.cnf <<EOF2
[req]
distinguished_name=req_distinguished_name
req_extensions = v3_req
prompt = no
[req_distinguished_name]
C=RS
O=Demo Security
CN=${DNS}
[v3_req]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${DNS}
EOF2

openssl genrsa -out /etc/ssl/myca/server.key 4096
openssl req -new -key /etc/ssl/myca/server.key -out /etc/ssl/myca/server.csr -config /etc/ssl/myca/server.cnf
openssl x509 -req -in /etc/ssl/myca/server.csr -CA /etc/ssl/myca/ca.crt -CAkey /etc/ssl/myca/ca.key -CAcreateserial \
  -out /etc/ssl/myca/server.crt -days 825 -sha256 -extensions v3_req -extfile /etc/ssl/myca/server.cnf

# Client cert
cat >/etc/ssl/myca/client.cnf <<'EOF2'
[req]
distinguished_name=req_distinguished_name
req_extensions = v3_req
prompt = no
[req_distinguished_name]
C=RS
O=Demo Security
CN=client1
[v3_req]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF2

openssl genrsa -out /etc/ssl/myca/client1.key 4096
openssl req -new -key /etc/ssl/myca/client1.key -out /etc/ssl/myca/client1.csr -config /etc/ssl/myca/client.cnf
openssl x509 -req -in /etc/ssl/myca/client1.csr -CA /etc/ssl/myca/ca.crt -CAkey /etc/ssl/myca/ca.key -CAcreateserial \
  -out /etc/ssl/myca/client1.crt -days 730 -sha256 -extensions v3_req -extfile /etc/ssl/myca/client.cnf

# Optional: trust CA on server
cp -f /etc/ssl/myca/ca.crt /usr/local/share/ca-certificates/ca_demo.crt || true
update-ca-certificates || true

# Klijent bundle (za lakše testiranje)
openssl pkcs12 -export -out /root/client/client1.p12 \
  -inkey /etc/ssl/myca/client1.key -in /etc/ssl/myca/client1.crt \
  -certfile /etc/ssl/myca/ca.crt -passout pass:

# Kopije za curl testove
cp -f /etc/ssl/myca/client1.crt /root/client/
cp -f /etc/ssl/myca/client1.key /root/client/
cp -f /etc/ssl/myca/ca.crt /root/client/

# (Po želji) dostupno za download uz oprez perms
cp -f /root/client/client1.p12 /var/www/html/downloads/ 2>/dev/null || true

echo "[*] TLS material spreman."
