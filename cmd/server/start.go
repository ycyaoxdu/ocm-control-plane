package server

import (
	"context"
	"fmt"
	"io"
	"net"

	"github.com/spf13/cobra"

	utilerrors "k8s.io/apimachinery/pkg/util/errors"
	genericapiserver "k8s.io/apiserver/pkg/server"
	genericoptions "k8s.io/apiserver/pkg/server/options"
	utilfeature "k8s.io/apiserver/pkg/util/feature"
	netutils "k8s.io/utils/net"

	//
	"open-cluster-management.io/ocm-controlplane/pkg/apiserver"
)

const defaultEtcdPathPrefix = "/registry"

type ServerOptions struct {
	RecommendedOptions *genericoptions.RecommendedOptions

	// SharedInformerFactory informers.SharedInformerFactory //?
	StdOut io.Writer
	StdErr io.Writer
}

func NewServerOptions(out, errOut io.Writer) *ServerOptions {
	o := &ServerOptions{
		RecommendedOptions: genericoptions.NewRecommendedOptions(
			defaultEtcdPathPrefix,
			apiserver.Codecs.LegacyCodec(),
		),

		StdOut: out,
		StdErr: errOut,
	}
	return o
}

func NewCommandStartServer(defaults *ServerOptions, ctx context.Context) *cobra.Command {
	o := *defaults
	cmd := &cobra.Command{
		Short: "Launch a API server",
		Long:  "Launch a API server",
		RunE: func(c *cobra.Command, args []string) error {
			if err := o.Complete(); err != nil {
				return err
			}
			if err := o.Validate(args); err != nil {
				return err
			}
			if err := o.RunServer(ctx); err != nil {
				return err
			}
			return nil
		},
	}

	flags := cmd.Flags()
	o.RecommendedOptions.AddFlags(flags)
	utilfeature.DefaultMutableFeatureGate.AddFlag(flags)

	return cmd
}

func (o ServerOptions) Validate(args []string) error {
	errors := []error{}
	errors = append(errors, o.RecommendedOptions.Validate()...)
	return utilerrors.NewAggregate(errors)
}

func (o *ServerOptions) Complete() error {
	return nil
}

func (o *ServerOptions) Config() (*apiserver.Config, error) {
	// TODO have a "real" external address
	if err := o.RecommendedOptions.SecureServing.MaybeDefaultWithSelfSignedCerts("localhost", nil, []net.IP{netutils.ParseIPSloppy("127.0.0.1")}); err != nil {
		return nil, fmt.Errorf("error creating self-signed certificates: %v", err)
	}

	// o.RecommendedOptions.Etcd.StorageConfig.Transport.ServerList = []string{"embedded"}

	// Build new server config using codecs
	serverConfig := genericapiserver.NewRecommendedConfig(apiserver.Codecs)

	if err := o.RecommendedOptions.ApplyTo(serverConfig); err != nil {
		return nil, err
	}

	config := apiserver.New(serverConfig, apiserver.DefaultDirectory)

	return config, nil
}

func (o ServerOptions) RunServer(ctx context.Context) error {
	config, err := o.Config()
	if err != nil {
		return err
	}

	server, err := config.Complete().New()
	if err != nil {
		return err
	}

	server.GenericAPIServer.AddPostStartHookOrDie("start-OCM-api-server-informers", func(context genericapiserver.PostStartHookContext) error {
		config.GenericConfig.SharedInformerFactory.Start(context.StopCh)
		// o.SharedInformerFactory.Start(context.StopCh)
		return nil
	})

	return server.GenericAPIServer.PrepareRun().Run(ctx.Done())
}
