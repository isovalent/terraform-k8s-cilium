// Copyright 2022 Isovalent, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

locals {
  provisioner_environment = merge(var.extra_provisioner_environment_variables, local.provisioner_environment_variables)           // The full set of environment variables passed to the provisioning script.
  provisioner_environment_variables = {                                                                                           // The set of environment variables set by this module on the provisioning script.
    CILIUM_HELM_CHART                  = var.cilium_helm_chart,                                                                   // The Cilium Helm chart to deploy.
    CILIUM_HELM_EXTRA_ARGS             = var.cilium_helm_extra_args                                                               // Extra arguments to be passed to the 'helm upgrade --install' command that installs Cilium.
    CILIUM_HELM_RELEASE_NAME           = var.cilium_helm_release_name,                                                            // The name to use for the Cilium Helm release.
    CILIUM_HELM_VALUES_FILE            = var.cilium_helm_values_file_path,                                                        // The path to the Helm values file to use when installing Cilium.
    CILIUM_HELM_VALUES_OVERRIDE_FILE   = var.cilium_helm_values_override_file_path,                                               // The path to the Helm values override file to use when installing Cilium.
    CILIUM_HELM_VERSION                = var.cilium_helm_version,                                                                 // The version of the Cilium Helm chart to deploy.
    CILIUM_NAMESPACE                   = var.cilium_namespace,                                                                    // The namespace where to deploy Cilium.
    CONTROL_PLANE_NODES_LABEL_SELECTOR = var.control_plane_nodes_label_selector,                                                  // The label selector used to filter control-plane nodes.
    DEPLOY_ETCD_CLUSTER                = var.deploy_etcd_cluster                                                                  // Whether to deploy an 'etcd' cluster suitable for usage as the Cilium key-value store.
    INSTALL_KUBE_PROMETHEUS_CRDS       = var.install_kube_prometheus_servicemonitor_crd,                                          // Whether to install the 'kube-prometheus' ServiceMonitor CRD.
    KUBE_PROMETHEUS_CRDS_VERSION       = var.kube_prometheus_crds_version,                                                        // Version of the 'kube-prometheus' ServiceMonitor CRD to install.
    IPSEC_KEY                          = var.ipsec_key,                                                                           // The IPsec key to be used for transparent encryption.
    KUBECONFIG                         = var.path_to_kubeconfig_file                                                              // The path to the kubeconfig file that will be created and output.
    PRE_CILIUM_INSTALL_SCRIPT          = var.pre_cilium_install_script != "" ? base64encode(var.pre_cilium_install_script) : ""   // The script to execute before installing Cilium.
    POST_CILIUM_INSTALL_SCRIPT         = var.post_cilium_install_script != "" ? base64encode(var.post_cilium_install_script) : "" // The script to execute after installing Cilium.
    TOTAL_CONTROL_PLANE_NODES          = var.total_control_plane_nodes                                                            // The number of control-plane nodes expected in the cluster.
    WAIT_FOR_TOTAL_CONTROL_PLANE_NODES = var.wait_for_total_control_plane_nodes                                                   // Whether to wait for the expected number of control-plane nodes to be registered before applying any changes.
    DISABLE_KUBE_PROXY                 = var.disable_kube_proxy                                                                   // Wether to disable the kube proxy after the cilium
    KUBE_PROXY_NAMESPACE               = var.kube_proxy_namespace                                                                 // the namespace contains the kube-proxy, it should be kube-system most of the case but leave this as the var in case we found some k8s distribution use something else
  }
  provisioner_path = "${abspath(path.module)}/scripts/provisioner.sh"
}
