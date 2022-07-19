package webhook

import (
	"context"
	"embed"

	"k8s.io/client-go/discovery"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/kubernetes"

	confighelpers "open-cluster-management.io/ocm-controlplane/config/helpers"
)

var WebhookSA = "managedcluster-admission-sa"
var ServiceName = "managedcluster-admission"
var HubNamespace = "open-cluster-management-hub"

//go:embed *.yaml
var fs embed.FS

func Bootstrap(ctx context.Context, discoveryClient discovery.DiscoveryInterface, dynamicClient dynamic.Interface, kubeClient kubernetes.Interface) error {
	// var sa = &corev1.ServiceAccount{
	// 	ObjectMeta: metav1.ObjectMeta{
	// 		Name: WebhookSA,
	// 	},
	// }
	// _, err := kubeClient.CoreV1().ServiceAccounts("default").Create(ctx, sa, metav1.CreateOptions{})
	// if err != nil {
	// 	klog.Errorf("failed to bootstrap hub serviceaccount: %v", err)
	// 	// nolint:nilerr
	// 	return nil // don't klog.Fatal. This only happens when context is cancelled.
	// }

	// selector := make(map[string]string)
	// selector["app"] = ServiceName
	// p := &corev1.ServicePort{
	// 	Port:       443,
	// 	TargetPort: intstr.FromInt(6443),
	// }

	// ser := &corev1.Service{
	// 	ObjectMeta: metav1.ObjectMeta{
	// 		Name:      ServiceName,
	// 		Namespace: HubNamespace,
	// 	},
	// 	Spec: corev1.ServiceSpec{
	// 		Selector: selector,
	// 		Ports:    []corev1.ServicePort{*p},
	// 	},
	// }
	// _, err = kubeClient.CoreV1().Services(HubNamespace).Create(ctx, ser, metav1.CreateOptions{})
	// if err != nil {
	// 	klog.Errorf("failed to bootstrap hub serviceaccount: %v", err)
	// 	// nolint:nilerr
	// 	return nil // don't klog.Fatal. This only happens when context is cancelled.
	// }

	return bootstrap(ctx, discoveryClient, dynamicClient)
}

func bootstrap(ctx context.Context, discoveryClient discovery.DiscoveryInterface, dynamicClient dynamic.Interface) error {
	return confighelpers.Bootstrap(ctx, discoveryClient, dynamicClient, fs)
}
