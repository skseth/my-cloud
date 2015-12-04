if [ -z "$1" ]
  then
    echo "Please provide domain name as parameter e.g. projectname.yourname"
    exit 1
fi

DOMAIN=$1
CRTFILE=ssl.crt
KEYFILE=ssl.key

cat > openssl.cnf <<-EOF
  [req]
  distinguished_name = req_distinguished_name
  x509_extensions = v3_req
  prompt = no
  [req_distinguished_name]
  CN = *.$DOMAIN
  [v3_req]
  keyUsage = keyEncipherment, dataEncipherment
  extendedKeyUsage = serverAuth
  subjectAltName = @alt_names
  [alt_names]
  DNS.1 = *.$DOMAIN
  DNS.2 = $DOMAIN
EOF

openssl req \
  -new \
  -newkey rsa:2048 \
  -sha256 \
  -days 3650 \
  -nodes \
  -x509 \
  -keyout $KEYFILE \
  -out $CRTFILE \
  -config openssl.cnf

rm openssl.cnf