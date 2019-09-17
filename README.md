# kubernetes-rbac
A Kubernetes RBAC Tutorial and Scripts

## Summary
This repo contains scripts for Windows and Linux to help generate user accounts and certiticates for each user

### Scripts
* k8s_usergen.bat -  A Windows script that generates a Kubernetes user config file
```
k8s_usergen.bat <username> https://<server_ip>:<port>
```
* k8s_usergen.sh - A Linux script that generates a Kubernetes user config file
```
./k8s_usergen.sh <username> https://<server_ip>:<port>
```

### What they do
The scripts require 2 parameters, a username and server IP that you can get from an existing working client here: `kubectl cluster-info`. 
Once you have this information, you can go ahead and run the script. It will then create signed certs and generate a kubernetes `config` file
along with some updated yml files. 

Once the script has been run, apply the following files:
* rbac-user-clusterrolebinding.yml
* rbac-user-rolebinding.yml


### Configuration
Each script has environment variables that you might need to change. It is assumed your are running minikube on Windows. 
