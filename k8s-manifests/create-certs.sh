#!/bin/sh

CERTDIR=certs
LANG=C

rm -rf ${CERTDIR}
mkdir -p ${CERTDIR}

certstrap --depot-path ${CERTDIR} init --common-name "rmt-ca" --passphrase ""

if [ -n "$*" ]; then
    HOSTNAMES="$@"
else
    HOSTNAMES="localhost"
fi
HOSTNAMES="rmt-nginx-svc ${HOSTNAMES}"

certstrap --depot-path ${CERTDIR} request-cert -domain ${HOSTNAMES} --passphrase "" --common-name rmt-server
certstrap --depot-path ${CERTDIR} sign rmt-server --CA "rmt-ca"

kubectl delete secret rmt-nginx-secret
kubectl create secret tls rmt-nginx-secret --key ${CERTDIR}/rmt-server.key --cert ${CERTDIR}/rmt-server.crt
kubectl delete configmap rmt-ca-configmap
kubectl create configmap rmt-ca-configmap --from-file=${CERTDIR}/rmt-ca.crt
