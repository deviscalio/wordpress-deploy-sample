#### Requirements
* kubernetes-cli 1.26.3
* Minikube 1.29.0
* terraform 1.3.4
* Windows OS

#### Instructions
Launch mikikube:
```
 minikube start  --memory=2g
 minikube addons enable ingress
```
Launch terraform:
```
 terraform init
 terraform apply
```
Wait to resource loading and then check ip to reach wordpress:
```
kubectl -n web get ingress
```
Go to browser and enjoy.

#### Command examples to test RBAC
```
kubectl auth can-i get pods --namespace web --as developer --as-group webdev
kubectl auth can-i delete pods --namespace web --as developer --as-group webdev
kubectl auth can-i delete pods --namespace web --as admin --as-group webadmins
kubectl auth can-i get pods --namespace databases --as developer --as-group webdev
kubectl auth can-i delete pods --namespace databases --as admin --as-group webadmins
```
