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

// The resource used to run the provisioning script.
resource "null_resource" "main" {
  triggers = merge(local.provisioner_environment, {
    CILIUM_HELM_VALUES_FILE_SHA1 = sha1(file(var.cilium_helm_values_file_path)) // Use the contents of the Cilium (base) Helm values file as a trigger.
    PROVISIONER_SHA1             = sha1(file(local.provisioner_path)),          // Use the contents of the provisioning script as a trigger.
  })
  provisioner "local-exec" {
    command     = local.provisioner_path        // The path to the provisioning script.
    environment = local.provisioner_environment // The set of environment variables used when running the provisioning script.
  }
}
