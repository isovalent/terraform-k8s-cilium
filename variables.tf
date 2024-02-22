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

variable "cilium_helm_chart" {
  default     = "cilium/cilium"
  description = "The name of the Helm chart to use to install Cilium. It is assumed that the Helm repository containing this chart has been added beforehand (e.g. using 'helm repo add')."
  type        = string
}

variable "cilium_helm_extra_args" {
  default     = ""
  description = "Extra arguments to be passed to the 'helm upgrade --install' command that installs Cilium."
  type        = string
}

variable "cilium_helm_release_name" {
  default     = "cilium"
  description = "The name of the Helm release to use for Cilium."
  type        = string
}

variable "cilium_helm_values_file_path" {
  description = "The path to the file containing the values to use when installing Cilium."
  type        = string
}

variable "cilium_helm_values_override_file_path" {
  description = "The path to the file containing the values to use when installing Cilium. These values will override the ones in 'cilium_helm_values_file_path'."
  type        = string
}

variable "cilium_helm_version" {
  description = "The version of the Cilium Helm chart to install."
  type        = string
}

variable "cilium_namespace" {
  default     = "kube-system"
  description = "The namespace in which to install Cilium."
  type        = string
}

variable "deploy_etcd_cluster" {
  default     = false
  description = "Whether to deploy an 'etcd' cluster suitable for usage as the Cilium key-value store (HIGHLY EXPERIMENTAL)."
  type        = bool
}

variable "control_plane_nodes_label_selector" {
  default     = "node-role.kubernetes.io/control-plane"
  description = "The label selector used to filter control-plane nodes."
  type        = string
}

variable "extra_provisioner_environment_variables" {
  default     = {}
  description = "A map of extra environment variables to include when executing the provisioning script."
  type        = map(string)
}

variable "ipsec_key" {
  default     = ""
  description = "The IPsec key to use for transparent encryption. Leave empty for none to be created (in which case encryption should be disabled in Helm as well)."
  type        = string
}

variable "path_to_kubeconfig_file" {
  description = "The path to the kubeconfig file to use."
  type        = string
}

variable "pre_cilium_install_script" {
  default     = ""
  description = "A script to be run right before installing Cilium."
  type        = string
}

variable "post_cilium_install_script" {
  default     = ""
  description = "A script to be run right after installing Cilium."
  type        = string
}

variable "total_control_plane_nodes" {
  default     = 3
  description = "The number of control-plane nodes expected in the cluster."
  type        = number
}

variable "wait_for_total_control_plane_nodes" {
  default     = false
  description = "Whether to wait for the expected number of control-plane nodes to be registered before applying any changes."
  type        = bool
}

variable "install_kube_prometheus_servicemonitor_crd" {
  default     = true
  description = "Whether to install the 'kube-prometheus' ServiceMonitor CRD."
  type        = bool
}

variable "disable_kube_proxy" {
  default     = false
  description = "Whether to disable the kube proxy so the cluster uses kube-proxy replacement"
  type        = bool
}

variable "kube_proxy_namespace" {
  default     = "kube-system"
  description = "Whether to disable the kube proxy so the cluster uses kube-proxy replacement"
  type        = string
}


variable "kube_prometheus_crds_version" {
  default     = "v0.13.0"
  description = "Version of the 'kube-prometheus' ServiceMonitor CRD to install."
  type        = string
}