#!/bin/bash

# Copyright 2022 Isovalent, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euxo pipefail

ROOT="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Wait for the KUBECONFIG file to be created.
COUNT=1
until [[ -f "${KUBECONFIG}" ]];
do
  if [[ ${COUNT} -gt 1800 ]];
  then
    echo "Failed to find KUBECONFIG."
    exit 1
  else
    COUNT=$((COUNT+1))
    sleep 1
  fi
done

# Create the target namespace if it does not exist.
if ! kubectl get ns "${CILIUM_NAMESPACE}";
then
    kubectl create ns "${CILIUM_NAMESPACE}"
fi

# Upsert or delete the IPsec secret to be used for transparent encryption.
IPSEC_ENABLED=""
IPSEC_SECRET_NAME="cilium-ipsec-keys"
if [[ "${IPSEC_KEY}" != "" ]];
then
  IPSEC_ENABLED="true"
  kubectl -n "${CILIUM_NAMESPACE}" create secret generic "${IPSEC_SECRET_NAME}" --from-literal=keys="${IPSEC_KEY}" --dry-run=client -o yaml | kubectl apply -f-
else
  IPSEC_ENABLED="false"
  kubectl -n "${CILIUM_NAMESPACE}" delete secret "${IPSEC_SECRET_NAME}" --ignore-not-found
fi
export IPSEC_ENABLED

# Manually create the 'ServiceMonitor' CRD from 'kube-prometheus' so we can enable the creation of 'ServiceMonitor' resources in the Cilium Helm chart.
if [[ "${INSTALL_KUBE_PROMETHEUS_CRDS}" == "true" ]];
then
  kubectl apply -f "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/release-0.11/manifests/setup/0servicemonitorCustomResourceDefinition.yaml"
  until kubectl get servicemonitors --all-namespaces;
  do
      echo "Waiting for the 'servicemonitors' CRD...";
      sleep 1;
  done
fi

# Deploy an 'etcd' cluster suitable for usage as the Cilium key-value store.
# This will be deployed to the same namespace as Cilium itself.
if [[ "${DEPLOY_ETCD_CLUSTER}" == "true" ]];
then
  envsubst < "${ROOT}/manifests/etcd.yaml" | kubectl apply -f-
fi

# Run any pre-install script we may have been provided with.
if [[ "${PRE_CILIUM_INSTALL_SCRIPT}" != "" ]];
then
  base64 --decode <<< "${PRE_CILIUM_INSTALL_SCRIPT}" | bash
fi

# Get the latest information about charts from the respective chart repositories.
helm repo update

# Replace variables in the values file and pipe it to 'helm upgrade --install'.
envsubst < "${CILIUM_HELM_VALUES_FILE}" | \
  helm upgrade --install "${CILIUM_HELM_RELEASE_NAME}" "${CILIUM_HELM_CHART}" \
    --version "${CILIUM_HELM_VERSION}" -n "${CILIUM_NAMESPACE}" -f /dev/stdin ${CILIUM_HELM_EXTRA_ARGS}

# Run any post-install script we may have been provided with.
if [[ "${POST_CILIUM_INSTALL_SCRIPT}" != "" ]];
then
  base64 --decode <<< "${POST_CILIUM_INSTALL_SCRIPT}" | bash
fi
