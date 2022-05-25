#!/bin/bash

OCMCONFIGDIR=".ocmconfig"
# check openssl and etcd

# export ENV

# ssl
if [ ! -e ${OCMCONFIGDIR} ];then mkdir -p ${OCMCONFIGDIR}; fi
cd ${OCMCONFIGDIR}
openssl req -nodes -new -x509 -keyout ca.key -out ca.crt -subj '/CN=development/O=system:masters'
openssl req -out client.csr -new -newkey rsa:4096 -nodes -keyout client.key -subj "/CN=development/O=system:masters"
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
openssl pkcs12 -export -in ./client.crt -inkey ./client.key -out client.p12 -passout pass:password

# start
# bin/ocm-controlplane --secure-port 8443 --v=7 --client-ca-file .ocmconfig/ca.crt --kubeconfig ~/.kube/config --authentication-kubeconfig ~/.kube/config --authorization-kubeconfig ~/.kube/config

# open another terminal
# wget -O- --no-check-certificate --certificate .ocmconfig/client.crt --private-key .ocmconfig/client.key https://localhost:8443/
