#!/bin/sh

CERTDIR=certs
KEY=${CERTDIR}/rmt-server.key
CERT=${CERTDIR}/rmt-server.crt

rm -rf ${CERTDIR}
mkdir ${CERTDIR}
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY} -out ${CERT} -subj "/CN=rmt-nginx-svc/O=rmt-nginx-svc"

kubectl create secret tls rmt-nginx-secret --key ${KEY} --cert ${CERT}
