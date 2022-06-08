# Get Started

```
$ cd ocm-control-plane
# clean environment, build binary
$ make all
# run 
$ bin/ocm-controlplane --secure-port 8443 --v=7
```

Then open another terminal to test:
```
$ kubectl --kubeconfig ./kubeconfig api-resources
```
