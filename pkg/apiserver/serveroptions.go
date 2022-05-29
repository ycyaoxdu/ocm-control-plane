package apiserver

import (
	"context"
	"fmt"
	"io"
	"net"
	"os"
	"path/filepath"

	utilerrors "k8s.io/apimachinery/pkg/util/errors"
	genericapiserver "k8s.io/apiserver/pkg/server"
	genericoptions "k8s.io/apiserver/pkg/server/options"
	netutils "k8s.io/utils/net"
	"open-cluster-management.io/ocm-controlplane/pkg/etcd"
)

const (
	defaultEtcdPathPrefix = "/registry"
)

type ServerOptions struct {
	RecommendedOptions *genericoptions.RecommendedOptions
	EmbeddedEtcd       *EmbeddedEtcd
	Extra              *ExtraConfig

	StdOut io.Writer
	StdErr io.Writer
}

type CompeletedServerOptions struct {
	RecommendedOptions *genericoptions.RecommendedOptions
	EmbeddedEtcd       *EmbeddedEtcd
	Extra              *ExtraConfig

	StdOut io.Writer
	StdErr io.Writer
}

func NewServerOptions(out, errOut io.Writer) *ServerOptions {
	ops := genericoptions.NewRecommendedOptions(
		defaultEtcdPathPrefix,
		nil,
	)
	// disable the watch cache
	ops.Etcd.EnableWatchCache = false
	// Overwrite the default for storage data format.
	ops.Etcd.DefaultStorageMediaType = "application/vnd.kubernetes.protobuf"

	o := &ServerOptions{
		RecommendedOptions: ops,
		EmbeddedEtcd:       NewEmbeddedEtcd(),
		Extra: &ExtraConfig{
			RootDirectory: DefaultDirectory,
		},
		StdOut: out,
		StdErr: errOut,
	}
	o.RecommendedOptions.Etcd.StorageConfig.Transport.ServerList = []string{"embedded"}

	return o
}

func (o ServerOptions) Validate(args []string) error {
	errors := []error{}
	// errors = append(errors, o.RecommendedOptions.Validate()...)
	errors = append(errors, o.EmbeddedEtcd.Validate()...)
	return utilerrors.NewAggregate(errors)
}

func (o *ServerOptions) Complete() (*CompeletedServerOptions, error) {

	if servers := o.RecommendedOptions.Etcd.StorageConfig.Transport.ServerList; len(servers) == 1 && servers[0] == "embedded" {
		o.RecommendedOptions.Etcd.StorageConfig.Transport.ServerList = []string{"localhost:" + o.EmbeddedEtcd.ClientPort}
		o.EmbeddedEtcd.Enabled = true
	} else {
		o.EmbeddedEtcd.Enabled = false
	}

	if !filepath.IsAbs(o.Extra.RootDirectory) {
		pwd, err := os.Getwd()
		if err != nil {
			return nil, err
		}
		o.Extra.RootDirectory = filepath.Join(pwd, o.Extra.RootDirectory)
	}
	if !filepath.IsAbs(o.EmbeddedEtcd.Directory) {
		o.EmbeddedEtcd.Directory = filepath.Join(o.Extra.RootDirectory, o.EmbeddedEtcd.Directory)
	}

	return &CompeletedServerOptions{
		RecommendedOptions: o.RecommendedOptions,
		EmbeddedEtcd:       o.EmbeddedEtcd,
		Extra:              o.Extra,
		StdOut:             o.StdOut,
		StdErr:             o.StdErr,
	}, nil
}

func (o *CompeletedServerOptions) Config(ctx context.Context) (*Config, error) {
	if dir := o.Extra.RootDirectory; len(dir) != 0 {
		if fi, err := os.Stat(dir); err != nil {
			if !os.IsNotExist(err) {
				return nil, err
			}
			if err := os.MkdirAll(dir, 0755); err != nil {
				return nil, err
			}
		} else {
			if !fi.IsDir() {
				return nil, fmt.Errorf("%q is a file, please delete or select another location", dir)
			}
		}
	}

	if o.EmbeddedEtcd.Enabled {
		es := &etcd.Server{
			Dir: o.EmbeddedEtcd.Directory,
		}
		embeddedClientInfo, err := es.Run(ctx, o.EmbeddedEtcd.PeerPort, o.EmbeddedEtcd.ClientPort, o.EmbeddedEtcd.WalSizeBytes)
		if err != nil {
			return nil, err
		}

		o.RecommendedOptions.Etcd.StorageConfig.Transport.ServerList = embeddedClientInfo.Endpoints
		o.RecommendedOptions.Etcd.StorageConfig.Transport.KeyFile = embeddedClientInfo.KeyFile
		o.RecommendedOptions.Etcd.StorageConfig.Transport.CertFile = embeddedClientInfo.CertFile
		o.RecommendedOptions.Etcd.StorageConfig.Transport.TrustedCAFile = embeddedClientInfo.TrustedCAFile
	}

	// TODO have a "real" external address
	if err := o.RecommendedOptions.SecureServing.MaybeDefaultWithSelfSignedCerts("localhost", nil, []net.IP{netutils.ParseIPSloppy("127.0.0.1")}); err != nil {
		return nil, fmt.Errorf("error creating self-signed certificates: %v", err)
	}

	// Build new server config using codecs
	serverConfig := genericapiserver.NewRecommendedConfig(Codecs)

	// apply changes to server config
	if err := o.RecommendedOptions.ApplyTo(serverConfig); err != nil {
		return nil, err
	}

	config := New(serverConfig)

	return config, nil
}

func (o CompeletedServerOptions) RunServer(ctx context.Context) error {
	config, err := o.Config(ctx)
	if err != nil {
		return err
	}

	server, err := config.Complete().New()
	if err != nil {
		return err
	}

	// server.GenericAPIServer.AddPostStartHookOrDie("start-OCM-api-server-informers", func(context genericapiserver.PostStartHookContext) error {
	// 	config.GenericConfig.SharedInformerFactory.Start(context.StopCh)
	// 	// o.SharedInformerFactory.Start(context.StopCh)
	// 	return nil
	// })

	return server.GenericAPIServer.PrepareRun().Run(ctx.Done())
}
