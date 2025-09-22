#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
DNS="${SERVER_DNS:-example.local}"

apt-get update -y
apt-get install -y apache2
a2enmod ssl headers rewrite || true

echo "<h1>Secure Apache on Ubuntu 22.04</h1><p>HTTPS radi.</p>" > /var/www/html/index.html
mkdir -p /var/www/html/downloads
chmod -R 755 /var/www/html

cat >/etc/apache2/sites-available/secure.conf <<CONF
<VirtualHost *:80>
  ServerName ${DNS}
  RewriteEngine On
  RewriteRule ^/(.*)$ https://%{HTTP_HOST}/\$1 [R=301,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName ${DNS}
  DocumentRoot /var/www/html

  SSLEngine on
  SSLCertificateFile      /etc/ssl/myca/server.crt
  SSLCertificateKeyFile   /etc/ssl/myca/server.key
  SSLCACertificateFile    /etc/ssl/myca/ca.crt

  # Protocols & ciphers
  SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1
  SSLHonorCipherOrder     on
  SSLCompression          off
  SSLCipherSuite          TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256

  # Security headers
  Header always set X-Content-Type-Options "nosniff"
  Header always set X-Frame-Options "DENY"
  Header always set X-XSS-Protection "1; mode=block"
  Header always set Referrer-Policy "no-referrer"
  Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
  Header always set Content-Security-Policy "default-src 'self'; frame-ancestors 'none'; object-src 'none'"

  <Directory /var/www/html>
    Options -Indexes +FollowSymLinks
    AllowOverride None
    Require all granted
  </Directory>

  # mTLS-protected path
  <Location /secure>
    SSLVerifyClient require
    SSLVerifyDepth 2
    SSLOptions +StdEnvVars +ExportCertData
  </Location>

  ErrorLog \${APACHE_LOG_DIR}/secure_error.log
  CustomLog \${APACHE_LOG_DIR}/secure_access.log combined
</VirtualHost>
CONF

a2dissite 000-default.conf || true
a2ensite secure.conf
systemctl enable apache2
systemctl restart apache2
