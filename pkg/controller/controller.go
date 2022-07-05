package controller

import (
	"context"
	_ "net/http/pprof"

	"github.com/openshift/library-go/pkg/controller/controllercmd"
	"github.com/openshift/library-go/pkg/operator/events"
	"k8s.io/client-go/rest"

	"open-cluster-management.io/registration/pkg/hub"

	confighub "open-cluster-management.io/ocm-controlplane/config/hub"
)

func InstallOCMHubControllers(ctx context.Context, kubeConfig *rest.Config) error {

	protoConfig := rest.CopyConfig(kubeConfig)
	protoConfig.AcceptContentTypes = "application/vnd.kubernetes.protobuf,application/json"
	protoConfig.ContentType = "application/vnd.kubernetes.protobuf"

	// var server *genericapiserver.GenericAPIServer

	eventRecorder := events.NewInMemoryRecorder("registration-controller")

	controllerContext := &controllercmd.ControllerContext{
		// ComponentConfig:   config,
		KubeConfig:      kubeConfig,
		ProtoKubeConfig: protoConfig,
		EventRecorder:   eventRecorder,
		// Server:            server,
		OperatorNamespace: confighub.HubNameSpace,
	}

	hub.RunControllerManager(ctx, controllerContext)

	return nil
}
