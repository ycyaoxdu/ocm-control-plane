# Get Started

```
$ cd ocm-control-plane
# clean environment, build binary
$ make all
# run 
$ hack/local-up-cluster.sh  
```

Then open another terminal to test:
```
$ kubectl --kubeconfig ./kubeconfig api-resources
```
