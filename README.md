# terraform-k8s-cilium

An opinionated Terraform module that can be used to install and manage Cilium on top of a Kubernetes cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.main](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cilium_helm_chart"></a> [cilium\_helm\_chart](#input\_cilium\_helm\_chart) | The name of the Helm chart to use to install Cilium. It is assumed that the Helm repository containing this chart has been added beforehand (e.g. using 'helm repo add'). | `string` | `"cilium/cilium"` | no |
| <a name="input_cilium_helm_extra_args"></a> [cilium\_helm\_extra\_args](#input\_cilium\_helm\_extra\_args) | Extra arguments to be passed to the 'helm upgrade --install' command that installs Cilium. | `string` | `""` | no |
| <a name="input_cilium_helm_release_name"></a> [cilium\_helm\_release\_name](#input\_cilium\_helm\_release\_name) | The name of the Helm release to use for Cilium. | `string` | `"cilium"` | no |
| <a name="input_cilium_helm_values_file_path"></a> [cilium\_helm\_values\_file\_path](#input\_cilium\_helm\_values\_file\_path) | The path to the file containing the values to use when installing Cilium. | `string` | n/a | yes |
| <a name="input_cilium_helm_values_override_file_path"></a> [cilium\_helm\_values\_override\_file\_path](#input\_cilium\_helm\_values\_override\_file\_path) | The path to the file containing the values to use when installing Cilium. These values will override the ones in 'cilium\_helm\_values\_file\_path'. | `string` | n/a | yes |
| <a name="input_cilium_helm_version"></a> [cilium\_helm\_version](#input\_cilium\_helm\_version) | The version of the Cilium Helm chart to install. | `string` | n/a | yes |
| <a name="input_cilium_namespace"></a> [cilium\_namespace](#input\_cilium\_namespace) | The namespace in which to install Cilium. | `string` | `"kube-system"` | no |
| <a name="input_control_plane_nodes_label_selector"></a> [control\_plane\_nodes\_label\_selector](#input\_control\_plane\_nodes\_label\_selector) | The label selector used to filter control-plane nodes. | `string` | `"node-role.kubernetes.io/control-plane"` | no |
| <a name="input_deploy_etcd_cluster"></a> [deploy\_etcd\_cluster](#input\_deploy\_etcd\_cluster) | Whether to deploy an 'etcd' cluster suitable for usage as the Cilium key-value store (HIGHLY EXPERIMENTAL). | `bool` | `false` | no |
| <a name="input_disable_kube_proxy"></a> [disable\_kube\_proxy](#input\_disable\_kube\_proxy) | Whether to disable the kube proxy so the cluster uses kube-proxy replacement | `bool` | `false` | no |
| <a name="input_extra_provisioner_environment_variables"></a> [extra\_provisioner\_environment\_variables](#input\_extra\_provisioner\_environment\_variables) | A map of extra environment variables to include when executing the provisioning script. | `map(string)` | `{}` | no |
| <a name="input_install_kube_prometheus_servicemonitor_crd"></a> [install\_kube\_prometheus\_servicemonitor\_crd](#input\_install\_kube\_prometheus\_servicemonitor\_crd) | Whether to install the 'kube-prometheus' ServiceMonitor CRD. | `bool` | `true` | no |
| <a name="input_ipsec_key"></a> [ipsec\_key](#input\_ipsec\_key) | The IPsec key to use for transparent encryption. Leave empty for none to be created (in which case encryption should be disabled in Helm as well). | `string` | `""` | no |
| <a name="input_kube_prometheus_crds_version"></a> [kube\_prometheus\_crds\_version](#input\_kube\_prometheus\_crds\_version) | Version of the 'kube-prometheus' ServiceMonitor CRD to install. | `string` | `"v0.13.0"` | no |
| <a name="input_kube_proxy_namespace"></a> [kube\_proxy\_namespace](#input\_kube\_proxy\_namespace) | Whether to disable the kube proxy so the cluster uses kube-proxy replacement | `string` | `"kube-system"` | no |
| <a name="input_path_to_kubeconfig_file"></a> [path\_to\_kubeconfig\_file](#input\_path\_to\_kubeconfig\_file) | The path to the kubeconfig file to use. | `string` | n/a | yes |
| <a name="input_post_cilium_install_script"></a> [post\_cilium\_install\_script](#input\_post\_cilium\_install\_script) | A script to be run right after installing Cilium. | `string` | `""` | no |
| <a name="input_pre_cilium_install_script"></a> [pre\_cilium\_install\_script](#input\_pre\_cilium\_install\_script) | A script to be run right before installing Cilium. | `string` | `""` | no |
| <a name="input_total_control_plane_nodes"></a> [total\_control\_plane\_nodes](#input\_total\_control\_plane\_nodes) | The number of control-plane nodes expected in the cluster. | `number` | `3` | no |
| <a name="input_wait_for_total_control_plane_nodes"></a> [wait\_for\_total\_control\_plane\_nodes](#input\_wait\_for\_total\_control\_plane\_nodes) | Whether to wait for the expected number of control-plane nodes to be registered before applying any changes. | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## License

Copyright 2022 Isovalent, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
