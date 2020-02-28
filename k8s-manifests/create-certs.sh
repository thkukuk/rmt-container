#!/bin/sh

CERTDIR=${CERTDIR:-certs}
LANG=C

mkdir -p ${CERTDIR}

if [ ! -e ${CERTDIR}/rmt-ca.crt ]; then
	certstrap --depot-path ${CERTDIR} init --common-name "rmt-ca" --passphrase ""
else
	echo "Found existing rmt-ca..."
fi

if [ ! -e ${CERTDIR}/rmt-server.crt ]; then
	if [ -n "$*" ]; then
		HOSTNAMES="$@"
	else
		HOSTNAMES="localhost"
	fi
	HOSTNAMES="rmt-nginx-svc ${HOSTNAMES}"

	certstrap --depot-path ${CERTDIR} request-cert -domain ${HOSTNAMES} --passphrase "" --common-name rmt-server
	certstrap --depot-path ${CERTDIR} sign rmt-server --CA "rmt-ca"
else
	echo "Found existing rmt-server cert..."
fi

kubectl delete secret rmt-nginx-secret
kubectl create secret tls rmt-nginx-secret --key ${CERTDIR}/rmt-server.key --cert ${CERTDIR}/rmt-server.crt
kubectl delete configmap rmt-ca-configmap
kubectl create configmap rmt-ca-configmap --from-file=${CERTDIR}/rmt-ca.crt

