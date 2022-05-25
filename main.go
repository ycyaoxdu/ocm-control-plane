package main

import (
	"os"

	genericapiserver "k8s.io/apiserver/pkg/server"
	"k8s.io/component-base/cli"

	"open-cluster-management.io/ocm-controlplane/cmd/server"
)

func main() {
	options := server.NewServerOptions(os.Stdout, os.Stderr)
	cmd := server.NewCommandStartServer(options, genericapiserver.SetupSignalContext())
	code := cli.Run(cmd)
	os.Exit(code)
}
