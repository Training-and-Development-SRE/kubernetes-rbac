#!/bin/bash
_USERNAME=$1
_GROUP=$2
_SERVERURL=$3
_CA_LOCATION=./server_certs
_OUTPUTDIR=users/$_USERNAME
_CLUSTERNAME=minikube
mkdir -p $_OUTPUTDIR

if [ -z $1 ]; then 
    echo "Missing username parameter";
    exit 1;
fi
if [ -z $2 ]; then 
    echo "Missing group parameter";
    exit 1;
fi
if [ -z $3 ]; then 
    echo "Missing server parameter";
    exit 1;
fi
openssl genrsa -out $_OUTPUTDIR/$_USERNAME.key 2048
cp ./.rnd ~/
openssl req -new -key  $_OUTPUTDIR/$_USERNAME.key -out $_OUTPUTDIR/$_USERNAME.csr -subj "/CN=$_USERNAME/O=$_GROUP"
openssl x509 -req -in $_OUTPUTDIR/$_USERNAME.csr -CA $_CA_LOCATION/ca.crt -CAkey $_CA_LOCATION/ca.key -CAcreateserial -out $_OUTPUTDIR/$_USERNAME.crt -days 500
rm ~/.rnd
sleep 2

kubectl config --kubeconfig=$_OUTPUTDIR/config  set-cluster minikube --certificate-authority=$_CA_LOCATION/ca.crt --server=$_SERVERURL --embed-certs=true
kubectl config --kubeconfig=$_OUTPUTDIR/config set-credentials $_USERNAME --client-certificate=$_OUTPUTDIR/$_USERNAME.crt  --client-key=$_OUTPUTDIR/$_USERNAME.key --embed-certs=true
kubectl config --kubeconfig=$_OUTPUTDIR/config set-context airwave-rbac --cluster=minikube --namespace=airwave-rbac --user=$_USERNAME 
kubectl config --kubeconfig=$_OUTPUTDIR/config use-context airwave-rbac

