package apiserver

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
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

func init() {
	// we need to add the options to empty v1
	// TODO fix the server code to avoid this
	metav1.AddToGroupVersion(Scheme, schema.GroupVersion{Version: "v1"})

	// TODO: keep the generic API server from wanting this
	unversioned := schema.GroupVersion{Group: "", Version: "v1"}
	Scheme.AddUnversionedTypes(unversioned,
		&metav1.Status{},
		&metav1.APIVersions{},
		&metav1.APIGroupList{},
		&metav1.APIGroup{},
		&metav1.APIResourceList{},
	)
}

const DefaultDirectory = ".ocmconfig"

// Config defines the config for the apiserver
type Config struct {
	GenericConfig *genericapiserver.RecommendedConfig
}

type completedConfig struct {
	CompletedConfig genericapiserver.CompletedConfig
}

// CompletedConfig embeds a private pointer that cannot be instantiated outside of this package.
type CompletedConfig struct {
	*completedConfig
}

// Server contains state for a Kubernetes cluster master/api server.
type Server struct {
	GenericAPIServer *genericapiserver.GenericAPIServer
}

func New(cfg *genericapiserver.RecommendedConfig) *Config {
	return &Config{
		GenericConfig: cfg,
	}
}

// Complete fills in any fields not set that are required to have valid data. It's mutating the receiver.
func (cfg *Config) Complete() CompletedConfig {
	// kubeclient, err := kubernetes.NewForConfig(cfg.GenericConfig.LoopbackClientConfig)
	// if err != nil {
	// 	panic(fmt.Sprintln("build kubeclient from config failed"))
	// }

	// // TODO(ycyaoxdu): resync period?
	// // coreAPI have set factory in Recommend
	// sif := informers.NewSharedInformerFactory(kubeclient, time.Second)

	c := completedConfig{
		// CompletedConfig: cfg.GenericConfig.Config.Complete(sif),
		CompletedConfig: cfg.GenericConfig.Complete(),
	}

	c.CompletedConfig.Version = &version.Info{
		Major: "1",
		Minor: "0",
	}

	return CompletedConfig{&c}
}

// New returns a new instance of Server from the given config.
func (c completedConfig) New() (*Server, error) {
	// build generic server from completed config
	genericServer, err := c.CompletedConfig.New("ocm-apiserver", genericapiserver.NewEmptyDelegate())
	if err != nil {
		return nil, err
	}

	s := &Server{
		GenericAPIServer: genericServer,
	}

	return s, nil
}
