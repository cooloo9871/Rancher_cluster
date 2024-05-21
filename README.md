# Rancher cluster builder

This project is used to quickly create custom clusters in the rancher and generate registration command.
### How to use
You need to run it on the rancher master.
```
git clone https://github.com/cooloo9871/Rancher_cluster-builder.git; cd Rancher_cluster-builder
```
#### You need to fill in the rancher url,rancher account password,rancher version
```
$ nano env.txt
#You need to fill in the rancher url,rancher account password,rancher version

URL="bigred.cooloo9871.com"
USER="admin"
PASSWORD="rancheradmin"
RANCHER_VERSION="v2.8.2"
```

#### The general cluster configuration options are available through [values.yaml](./charts/values.yaml).

```yaml
$ nano charts/values.yaml
# cluster specific values
cluster:
  # specify cluster name
  name: cluster-example

  # specify cluster labels
  labels: {}

  # specify cluster annotations
  annotations: {}

# specify cloud credential secret name, do not need to be provided if using custom driver
cloudCredentialSecretName: ""

# specify cloud provider, options are amazonec2, digitalocean, azure, vsphere or custom
cloudprovider: "custom"

# enable network policy
enableNetworkPolicy: false

kubernetesVersion: "v1.28.8+rke2r1"

# specify rancher helm chart values deployed into downstream cluster
rancherValues: {}

# specify extra env variables in cluster-agent deployment
# agentEnvs:
#  - name: HTTP_PROXY
#     value: foo.bar

# general RKE options
rke:
  # specify rancher helm chart values deployed into downstream cluster
  chartValues: {}

  # controlplane/etcd configuration settings
  controlPlaneConfig:
    # Path to the file that defines the audit policy configuration
    # audit-policy-file: ""
    # IPv4/IPv6 network CIDRs to use for pod IPs (default: 10.42.0.0/16)
    # cluster-cidr: ""
    # IPv4 Cluster IP for coredns service. Should be in your service-cidr range (default: 10.43.0.10)
    # cluster-dns: ""
    # Cluster Domain (default: "cluster.local")
    # cluster-domain: ""
    # CNI Plugin to deploy, one of none, canal, cilium (default: "canal")
    cni: calico
    # Do not deploy packaged components and delete any deployed components (valid items: rke2-coredns, rke2-ingress-nginx, rke2-kube-proxy, rke2-metrics-server)
    # disable: false
    # Disable automatic etcd snapshots
    # etcd-disable-snapshots: false
    # Expose etcd metrics to client interface. (Default false)
    # etcd-expose-metrics: false
    # Directory to save db snapshots. (Default location: ${data-dir}/db/snapshots)
    # etcd-snapshot-dir: ""
    # Set the base name of etcd snapshots. Default: etcd-snapshot-<unix-timestamp> (default: "etcd-snapshot")
    # etcd-snapshot-name: ""
    # Number of snapshots to retain (default: 5)
    # etcd-snapshot-retention: 5
    # Snapshot interval time in cron spec. eg. every 5 hours '* */5 * * *' (default: "0 */12 * * *")
    # etcd-snapshot-schedule-cron: "0 */12 * * *"
    # Customized flag for kube-apiserver process
    # kube-apiserver-arg: ""
    # Customized flag for kube-scheduler process
    # kube-scheduler-arg: ""
    # Customized flag for kube-controller-manager process
    # kube-controller-manager-arg: ""
    # Validate system configuration against the selected benchmark (valid items: cis-1.5, cis-1.6 )
    # profile: "cis-1.6"
    # Enable Secret encryption at rest
    # secrets-encryption: false
    # IPv4/IPv6 network CIDRs to use for service IPs (default: 10.43.0.0/16)
    # service-cidr: "10.43.0.0/16"
    # Port range to reserve for services with NodePort visibility (default: "30000-32767")
    # service-node-port-range: "30000-32767"
    # Add additional hostnames or IPv4/IPv6 addresses as Subject Alternative Names on the server TLS cert
    # tls-san: []

  # worker configuration settings
  workerConfig:
  - config:
      # Node name
      # node-name: ""
      # Disable embedded containerd and use alternative CRI implementation
      # container-runtime-endpoint: ""
      # Override default containerd snapshotter (default: "overlayfs")
      # snapshotter: ""
      # IP address to advertise for node
      # node-ip: "1.1.1.1"
      # Kubelet resolv.conf file
      # resolv-conf: ""
      # Customized flag for kubelet process
      # kubelet-arg: ""
      # Customized flag for kube-proxy process
      # kube-proxy-arg: ""
      # Kernel tuning behavior. If set, error if kernel tunables are different than kubelet defaults. (default: false)
      # protect-kernel-defaults: false
      # Enable SELinux in containerd (default: false)
      # selinux: true
      # Cloud provider name
      # cloud-provider-name: ""
      # Cloud provider configuration file path
      # cloud-provider-config: ""
    machineLabelSelector:
      matchLabels:
        foo: bar

  # enable local auth endpoint
  localClusterAuthEndpoint:
    enabled: false
  # specify fqdn of local access endpoint
  # fqdn: foo.bar.example
  # specify cacert of local access endpoint
  # caCerts: ""

  # Specify upgrade options
  upgradeStrategy:
    controlPlaneDrainOptions:
      enabled: false
      # deleteEmptyDirData: false
      # disableEviction: false
      # gracePeriod: 0
      # ignoreErrors: false
      # skipWaitForDeleteTimeoutSeconds: 0
      # timeout: 0
    workerDrainOptions:
      enabled: false
      # deleteEmptyDirData: false
      # disableEviction: false
      # gracePeriod: 0
      # ignoreErrors: false
      # skipWaitForDeleteTimeoutSeconds: 0
      # timeout: 0
    workerConcurrency: "1"
```

#### Create Cluster
```bash
$ bash build.sh
==Please copy the following token==
token-76b42:84qfwlwrbfqdnr5hbqpc6bffbf4bhnwr66qg72nct8qrf4twnpmr8q

==Please copy the Registration Allinone Command==
curl --insecure -fL https://bigred.cooloo9871.com/system-agent-install.sh | sudo  sh -s - --server https://bigred.cooloo9871.com --label 'cattle.io/os=linux' --token wsnf2krwgkfq89m8mf8444rljsgj8h8x8cl8btsrggvq5qprkgwgcm --ca-checksum 64dfdeb4ea7fab50c3794bfc3bcf6d8f2cea4c66062061a67ccff6221ac5a800 --etcd --controlplane --worker
```

#### Delete Cluster
```
$ helm -n fleet-default uninstall do-cluster
```
