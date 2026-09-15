// SPDX-FileCopyrightText: SAP SE or an SAP affiliate company and IronCore contributors
// SPDX-License-Identifier: Apache-2.0

package config

import (
	"context"
	"fmt"

	"github.com/go-logr/logr"
	"github.com/ironcore-dev/ironcore/utils/client/config"
	"k8s.io/apiserver/pkg/server/egressselector"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	ctrl "sigs.k8s.io/controller-runtime"
)

// BrokerGetter is a lightweight config getter for broker components that only
// need a *rest.Config, without certificate rotation or CSR bootstrapping.
//
// It was previously provided by github.com/ironcore-dev/ironcore/utils/client/config
// and moved here when the brokers were split into their own repository.
type BrokerGetter struct {
	name           string
	logConstructor func() logr.Logger
	networkContext egressselector.NetworkContext
}

// NewBrokerGetter creates a new BrokerGetter from the given options.
func NewBrokerGetter(opts config.GetterOptions) (*BrokerGetter, error) {
	logConstructor := opts.LogConstructor
	if logConstructor == nil {
		l := ctrl.Log.WithName("client").WithName("config").WithValues("getter", opts.Name)
		logConstructor = func() logr.Logger { return l }
	}
	return &BrokerGetter{
		name:           opts.Name,
		logConstructor: logConstructor,
		networkContext: opts.NetworkContext,
	}, nil
}

// GetConfig returns a *rest.Config based on the given options.
func (bg *BrokerGetter) GetConfig(ctx context.Context, opts ...config.GetConfigOption) (*rest.Config, error) {
	o := &config.GetConfigOptions{}
	o.ApplyOptions(opts)

	if o.Kubeconfig != "" && o.KubeconfigSecretName != "" {
		return nil, fmt.Errorf("cannot specify kubeconfig and kubeconfig-secret-name")
	}

	bg.logConstructor().Info("Getting config")

	loader, err := config.LoaderFromOptions(o)
	if err != nil {
		return nil, fmt.Errorf("error getting loader: %w", err)
	}

	var cfg *rest.Config
	if loader != nil {
		cfg, err = loader.Load(ctx, &clientcmd.ConfigOverrides{
			CurrentContext: o.Context,
		})
	} else {
		cfg, err = config.LoadDefaultConfig(o.Context)
	}
	if err != nil {
		return nil, err
	}

	dialFunc, err := config.GetEgressSelectorDial(bg.networkContext, o.EgressSelectorConfig)
	if err != nil {
		return nil, err
	}

	cfg.Dial = dialFunc
	cfg.QPS = o.QPS
	cfg.Burst = o.Burst

	return cfg, nil
}
