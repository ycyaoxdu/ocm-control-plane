package apiserver

import (
	"context"
	"fmt"
	"net"
	"os"
	"path/filepath"

	utilerrors "k8s.io/apimachinery/pkg/util/errors"
	genericapiserver "k8s.io/apiserver/pkg/server"
	"k8s.io/kubernetes/cmd/kube-apiserver/app/options"
	netutils "k8s.io/utils/net"
	"open-cluster-management.io/ocm-controlplane/pkg/apiserver/kubeapiserver"
	"open-cluster-management.io/ocm-controlplane/pkg/etcd"
)

const DefaultDirectory = ".ocmconfig"

type ExtraConfig struct {
	RootDirectory string
}

type Options struct {
	ServerRunOptions *options.ServerRunOptions
	EmbeddedEtcd     *EmbeddedEtcd
	Extra            *ExtraConfig
}

type completedOptions struct {
	ServerRunOptions *kubeapiserver.CompletedServerRunOptions
	EmbeddedEtcd     *EmbeddedEtcd
	Extra            *ExtraConfig
}

type CompletedOptions struct {
	*completedOptions
}

func NewServerRunOptions() *Options {
	o := options.NewServerRunOptions()
	e := NewEmbeddedEtcd()

	o.Etcd.StorageConfig.Transport.ServerList = []string{"embedded"}

	s := Options{
		ServerRunOptions: o,
		EmbeddedEtcd:     e,
		Extra: &ExtraConfig{
			RootDirectory: DefaultDirectory,
		},
	}

	return &s
}

func (o *Options) Validate(args []string) error {
	errors := []error{}
	errors = append(errors, o.ServerRunOptions.Validate()...)
	errors = append(errors, o.EmbeddedEtcd.Validate()...)
	return utilerrors.NewAggregate(errors)
}

func (o *Options) Complete() (*CompletedOptions, error) {
	s, err := kubeapiserver.Complete(o.ServerRunOptions)
	if err != nil {
		return nil, err
	}
	// Enable Bootstrap Token Authentication
	s.ServerRunOptions.Authentication.BootstrapToken.Enable = true

	// check for directory
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

	// set embedded etcd port
	if servers := o.ServerRunOptions.Etcd.StorageConfig.Transport.ServerList; len(servers) == 1 && servers[0] == "embedded" {
		o.ServerRunOptions.Etcd.StorageConfig.Transport.ServerList = []string{"localhost:" + o.EmbeddedEtcd.ClientPort}
		o.EmbeddedEtcd.Enabled = true
	} else {
		o.EmbeddedEtcd.Enabled = false
	}

	c := completedOptions{
		ServerRunOptions: &s,
		EmbeddedEtcd:     o.EmbeddedEtcd,
		Extra:            o.Extra,
	}

	return &CompletedOptions{&c}, nil
}

func (c *CompletedOptions) Run() error {

	// check for directory
	if dir := c.Extra.RootDirectory; len(dir) != 0 {
		if fi, err := os.Stat(dir); err != nil {
			if !os.IsNotExist(err) {
				return err
			}
			if err := os.MkdirAll(dir, 0755); err != nil {
				return err
			}
		} else {
			if !fi.IsDir() {
				return fmt.Errorf("%q is a file, please delete or select another location", dir)
			}
		}
	}

	// set etcd to embeddedetcd info
	if c.EmbeddedEtcd.Enabled {
		es := &etcd.Server{
			Dir: c.EmbeddedEtcd.Directory,
		}
		embeddedClientInfo, err := es.Run(context.Background(), c.EmbeddedEtcd.PeerPort, c.EmbeddedEtcd.ClientPort, c.EmbeddedEtcd.WalSizeBytes)
		if err != nil {
			return err
		}

		c.ServerRunOptions.Etcd.StorageConfig.Transport.ServerList = embeddedClientInfo.Endpoints
		c.ServerRunOptions.Etcd.StorageConfig.Transport.KeyFile = embeddedClientInfo.KeyFile
		c.ServerRunOptions.Etcd.StorageConfig.Transport.CertFile = embeddedClientInfo.CertFile
		c.ServerRunOptions.Etcd.StorageConfig.Transport.TrustedCAFile = embeddedClientInfo.TrustedCAFile
	}

	// to generate self-signed certificates
	// TODO have a "real" external address
	if err := c.ServerRunOptions.SecureServing.MaybeDefaultWithSelfSignedCerts("localhost", nil, []net.IP{netutils.ParseIPSloppy("127.0.0.1")}); err != nil {
		return fmt.Errorf("error creating self-signed certificates: %v", err)
	}

	return kubeapiserver.Run(*c.ServerRunOptions, genericapiserver.SetupSignalHandler())
}
