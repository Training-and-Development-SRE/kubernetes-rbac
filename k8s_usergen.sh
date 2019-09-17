#!/bin/bash

_USERNAME=$1
_CA_LOCATION=./server_certs
_OUTPUTDIR=users/$_USERNAME
_SERVERURL=$2
_CLUSTERNAME=minikube

mkdir -p $_OUTPUTDIR

if [ -z $1 ]; then 
    echo "Missing username parameter";
    exit 1;
fi
if [ -z $2 ]; then 
    echo "Missing server URL parameter";
    exit 1;
fi
openssl genrsa -out $_OUTPUTDIR/$_USERNAME.key 2048
openssl req -new -key  $_OUTPUTDIR/$_USERNAME.key -out $_OUTPUTDIR/$_USERNAME.csr -subj "/CN=$_USERNAME/O=airwave"
openssl x509 -req -in $_OUTPUTDIR/$_USERNAME.csr -CA $_CA_LOCATION/ca.crt -CAkey $_CA_LOCATION/ca.key -CAcreateserial -out $_OUTPUTDIR/$_USERNAME.crt -days 500
sleep 2

kubectl config --kubeconfig=$_OUTPUTDIR/config  set-cluster minikube --certificate-authority=$_CA_LOCATION/ca.crt --server=$_SERVERURL --embed-certs=true
kubectl config --kubeconfig=$_OUTPUTDIR/config set-credentials $_USERNAME --client-certificate=$_OUTPUTDIR/$_USERNAME.crt  --client-key=$_OUTPUTDIR/$_USERNAME.key --embed-certs=true
kubectl config --kubeconfig=$_OUTPUTDIR/config set-context airwave-rbac --cluster=minikube --namespace=airwave-rbac --user=$_USERNAME 
kubectl config --kubeconfig=$_OUTPUTDIR/config use-context airwave-rbac

echo -e "\n---\napiVersion: v1\nkind: ServiceAccount\nmetadata:\n  name: $_USERNAME" >> rbac-user-rolebinding.yml

