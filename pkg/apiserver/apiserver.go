package apiserver

import (
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/serializer"
	"k8s.io/apimachinery/pkg/version"
	genericapiserver "k8s.io/apiserver/pkg/server"
)

var (
	// Scheme defines methods for serializing and deserializing API objects.
	Scheme = runtime.NewScheme()
	// Codecs provides methods for retrieving codecs and serializers for specific
	// versions and content types.
	Codecs = serializer.NewCodecFactory(Scheme)
)

const DefaultDirectory = ".ocmconfig"

// ExtraConfig holds custom apiserver config
type ExtraConfig struct {
	RootDirectory string
}

// Config defines the config for the apiserver
type Config struct {
	GenericConfig *genericapiserver.RecommendedConfig
	// EmbeddedEtcd  EmbeddedEtcd

	// ExtraConfig ExtraConfig
}

type completedConfig struct {
	GenericConfig genericapiserver.CompletedConfig
	// EmbeddedEtcd  EmbeddedEtcd

	// ExtraConfig ExtraConfig
}

// CompletedConfig embeds a private pointer that cannot be instantiated outside of this package.
type CompletedConfig struct {
	*completedConfig
}

// Server contains state for a Kubernetes cluster master/api server.
type Server struct {
	GenericAPIServer *genericapiserver.GenericAPIServer
}

func New(cfg *genericapiserver.RecommendedConfig, dir string) *Config {
	return &Config{
		GenericConfig: cfg,
		// EmbeddedEtcd:  *NewEmbeddedEtcd(),
		// ExtraConfig: ExtraConfig{
		// 	RootDirectory: dir,
		// },
	}
}

// Complete fills in any fields not set that are required to have valid data. It's mutating the receiver.
func (cfg *Config) Complete() CompletedConfig {
	c := completedConfig{
		GenericConfig: cfg.GenericConfig.Complete(),
		// EmbeddedEtcd:  cfg.EmbeddedEtcd,
		// ExtraConfig:   cfg.ExtraConfig,
	}

	c.GenericConfig.Version = &version.Info{
		Major: "1",
		Minor: "0",
	}

	return CompletedConfig{&c}
}

// New returns a new instance of Server from the given config.
func (c completedConfig) New() (*Server, error) {
	// build generic server from completed config
	genericServer, err := c.GenericConfig.New("ocm-apiserver", genericapiserver.NewEmptyDelegate())
	if err != nil {
		return nil, err
	}

	s := &Server{
		GenericAPIServer: genericServer,
	}

	return s, nil
}
