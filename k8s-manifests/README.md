# Deploy RMT on kubernetes

RMT consists of three containers:
* MariaDB
* Nginx
* RMT

and needs two persistent storage volumes:
* MariaDB database
* RMT storage for repositories

## Pre-Requires

The following tools are required:
* kustomization - to build final yaml files
* certstrap - in the case self signed certificates needs to be created
* kubectl

## SSL certificates

``create-certs.sh`` creates the certificates for https and uploads
them to kubernetes.

## Configuration

`kustomize` is used to configure the deployment. Checkout the git repository:
`git clone https://github.com/thkukuk/rmt-container`

Inside ``rmt-container`` create a new directory: ``overlay`` with the
following files:

### kustomization.yaml
```
secretGenerator:
- name: rmt-scc-account
  literals:
  - username=UCXXX
  - password=xxxxxxxxxx
  behavior: replace

resources:
- ../k8s-manifests

patchesStrategicMerge:
- patch_LoadBalancerIP.yaml
- patch_PVC.yaml
```

Replace UCXXX with your SCC username and xxxxxxxxxx with your SCC password.

### patch_LoadBalancerIP.yaml

Here a preferred Loadbalancer IP can be specified. If not wanted, remote
the entry from ``kustomization.yaml``:

```
apiVersion: v1
kind: Service
metadata:
  name: rmt-nginx-svc
spec:
  loadBalancerIP: XX.XXX.XXX.XX
```

Replace XX.XXX.XXX.XX with the IP under which Nginx/RMT should be reacheable.

### patch_PVC.yaml

Change the required persisent storage size to match your needs:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rmt-pv-claim
spec:
  resources:
    requests:
      storage: XXXGi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rmt-mariadb-pv-claim
spec:
  resources:
    requests:
      storage: XXGi
```

## Deployment

In case the configuration was adjusted:
```
kustomize build overlay | kubectl apply -f -
```

In case the configuration was not adjusted:
```
kustomize build k8s-manifests | kubectl apply -f -
```
