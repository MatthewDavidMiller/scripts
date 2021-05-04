#!/bin/bash
# Credits
# https://stackoverflow.com/questions/19979171/how-to-convert-pem-into-key
# https://stackoverflow.com/questions/13732826/convert-pem-to-crt-and-key

certificate='./fullchain'
private_key='./privkey'

# Convert certificate to crt
openssl x509 -outform der -in "$certificate.pem" -out "$certificate.crt"

# Convert private_key to key
openssl rsa -outform der -in "$private_key.pem" -out "$private_key.key"
