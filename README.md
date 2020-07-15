# rmt-container
Deploy RMT in a kubernetes cluster or as containerized workload

## Deploy RMT on kubernetes

RMT consists of four containers:
* MariaDB server
* MariaDB client utilities
* Nginx
* RMT

and needs two persistent storage volumes:
* MariaDB database
* RMT storage for repositories

### Pre-Requires

The following tools are required:
* kustomization - to build final yaml files
* certstrap - in the case self signed certificates needs to be created
* kubectl

### SSL certificates
``create-certs.sh`` creates the certificates for https if they don't exist
already and uploads them to kubernetes.
The environment variable _CERTDIR_ can point to a directory, which contains
already the certificates or where they should be stored. By default _certs_
in the local directory is used.

### Configuration
**kustomize** is used to configure the deployment. Checkout the git repository:
`git clone https://github.com/thkukuk/rmt-container` to get the current
manifest.

To configure the RMT deployment create a new directory _overlay_ (or any other
meaningful name) inside _rmt-container_ with the following files:

#### kustomization.yaml
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

#### patch_LoadBalancerIP.yaml
Here a preferred Loadbalancer IP can be specified. If not wanted, remote
the entry from _kustomization.yaml_. In the same way, the LoadBalancer
could be replaced with NodePort.

```
apiVersion: v1
kind: Service
metadata:
  name: rmt-nginx-svc
spec:
  loadBalancerIP: XX.XXX.XXX.XX
```

Replace XX.XXX.XXX.XX with the IP under which Nginx/RMT should be reacheable.

#### patch_PVC.yaml
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

### Deployment
In case the configuration was adjusted:
```sh
kustomize build overlay | kubectl apply -f -
```

In case the configuration was not adjusted:
```sh
kustomize build k8s-manifests | kubectl apply -f -
```

### Cronjobs for RMT sync jobs
There are three cronjobs for RMT:
* rmt-cronjob-sync.yaml - get latest product informations from SCC
* rmt-cronjob-mirror.yaml - mirror enabled repositories once a night
* rmt-cronjob-systems-scc-sync.yaml - forward registered systems data to SCC

*rmt-cronjob-sync.yaml* and *rmt-cronjob-mirror.yaml* are enabled
automatically by *kustomize*. *rmt-cront-systems-scc-sync.yaml* needs to
be added to *kustomization.yaml* if it should be executed every night.

### RMT Configuration
To configure RMT, you need to exec into the rmt-server container and
run `rmt-cli` to sync, enable and mirror products and repositories.

## Run RMT with podman/docker

There is an untested script to run RMT in containers on a single
Container Host OS like openSUSE MicroOS:

```sh
podman/run-rmt-containerized.sh
```

While the script is for `podman`, it should be easy adjustable for `docker`.
Support for automatic mirroring and syncing is missing.
