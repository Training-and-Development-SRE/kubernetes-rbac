@ECHO OFF
SET _USERNAME=%1
SET _CA_LOCATION=%USERPROFILE%\.minikube
SET _OUTPUTDIR=users\%_USERNAME%
SET _SERVERURL=%2
SET _CLUSTERNAME=minikube
rmdir users\%_USERNAME%
mkdir %_OUTPUTDIR%

IF [%1] == [] echo "Missing username parameter" && cmd /k
IF [%2] == [] echo "Missing server URL parameter" && cmd /k
openssl genrsa -out %_OUTPUTDIR%\%_USERNAME%.key 2048
openssl req -new -key  %_OUTPUTDIR%\%_USERNAME%.key -out %_OUTPUTDIR%\%_USERNAME%.csr -subj "/CN=%_USERNAME%/O=airwave"
openssl x509 -req -in %_OUTPUTDIR%\%_USERNAME%.csr -CA %_CA_LOCATION%\ca.crt -CAkey %_CA_LOCATION%\ca.key -CAcreateserial -out %_OUTPUTDIR%\%_USERNAME%.crt -days 500
timeout /t 1

kubectl config --kubeconfig=%_OUTPUTDIR%\config set-cluster minikube --certificate-authority=%_CA_LOCATION%\ca.crt --server=%_SERVERURL% --embed-certs=true
kubectl config --kubeconfig=%_OUTPUTDIR%\config set-credentials %_USERNAME% --client-certificate=%_OUTPUTDIR%\%_USERNAME%.crt  --client-key=%_OUTPUTDIR%\%_USERNAME%.key --embed-certs=true
kubectl config --kubeconfig=%_OUTPUTDIR%\config set-context airwave-rbac --cluster=minikube --namespace=airwave-rbac --user=%_USERNAME% 
kubectl config --kubeconfig=%_OUTPUTDIR%\config use-context airwave-rbac


echo. >> rbac-user-rolebinding.yml
echo --- >> rbac-user-rolebinding.yml
echo apiVersion: v1 >> rbac-user-rolebinding.yml
echo kind: ServiceAccount >> rbac-user-rolebinding.yml
echo metadata: >> rbac-user-rolebinding.yml
echo   name: %_USERNAME% >> rbac-user-rolebinding.yml