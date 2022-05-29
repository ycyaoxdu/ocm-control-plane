package server

import (
	"context"

	"github.com/spf13/cobra"
	utilfeature "k8s.io/apiserver/pkg/util/feature"

	"open-cluster-management.io/ocm-controlplane/pkg/apiserver"
)

func NewCommandStartServer(defaults *apiserver.ServerOptions, ctx context.Context) *cobra.Command {
	o := *defaults
	cmd := &cobra.Command{
		Short: "Launch a API server",
		Long:  "Launch a API server",
		RunE: func(c *cobra.Command, args []string) error {
			var completed *apiserver.CompeletedServerOptions
			var err error
			if err = o.Validate(args); err != nil {
				return err
			}
			if completed, err = o.Complete(); err != nil {
				return err
			}
			if err := completed.RunServer(ctx); err != nil {
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
