@ECHO OFF
SET _USERNAME=%1
SET _GROUP=%2
SET _SERVERURL=%3
SET _CA_LOCATION=%USERPROFILE%\.minikube
SET _OUTPUTDIR=users\%_USERNAME%
SET _CLUSTERNAME=minikube
set RANDFILE=.rnd
mkdir %_OUTPUTDIR%


IF [%1] == [] echo "Missing username parameter" && cmd /k
IF [%2] == [] echo "Missing group URL parameter" && cmd /k
IF [%3] == [] echo "Missing server URL parameter" && cmd /k

openssl genrsa -out %_OUTPUTDIR%\%_USERNAME%.key 2048
openssl req -new -key  %_OUTPUTDIR%\%_USERNAME%.key -out %_OUTPUTDIR%\%_USERNAME%.csr -subj "/CN=%_USERNAME%/O=%_GROUP%"
openssl x509 -req -in %_OUTPUTDIR%\%_USERNAME%.csr -CA %_CA_LOCATION%\ca.crt -CAkey %_CA_LOCATION%\ca.key -CAcreateserial -out %_OUTPUTDIR%\%_USERNAME%.crt -days 500
timeout /t 1

kubectl config --kubeconfig=%_OUTPUTDIR%\config set-cluster minikube --certificate-authority=%_CA_LOCATION%\ca.crt --server=%_SERVERURL% --embed-certs=true
kubectl config --kubeconfig=%_OUTPUTDIR%\config set-credentials %_USERNAME% --client-certificate=%_OUTPUTDIR%\%_USERNAME%.crt  --client-key=%_OUTPUTDIR%\%_USERNAME%.key --embed-certs=true
kubectl config --kubeconfig=%_OUTPUTDIR%\config set-context airwave-rbac --cluster=minikube --namespace=airwave-rbac --user=%_USERNAME% 
kubectl config --kubeconfig=%_OUTPUTDIR%\config use-context airwave-rbac
