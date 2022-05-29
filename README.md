# Get Started

```
$ cd OCM-control-plane
# clean environment, build binary
$ make all
# run 
$ bin/ocm-controlplane --secure-port 8443 --v=7 --client-ca-file .ocmconfig/ca.crt --kubeconfig ~/.kube/config --authentication-kubeconfig ~/.kube/config --authorization-kubeconfig ~/.kube/config
```

Then open another terminal to test:
```
$ wget -O- --no-check-certificate --certificate .ocmconfig/client.crt --private-key .ocmconfig/client.key https://localhost:8443/
# or we can use kubectl to check
$  kubectl get --raw='/readyz?verbose'
```
