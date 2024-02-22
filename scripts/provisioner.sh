#!/usr/bin/env bash

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

# Wait for Kubernetes API to stabilize
KAPI_REACHABILITY_COUNT=1
set +e
until kubectl get --raw='/readyz?verbose'
do
  if [[ ${KAPI_REACHABILITY_COUNT} -gt 180 ]];
  then
    echo "Failed to connect to the Kubernetes API or the Kubernetes API doesn't report an healthy state."
    exit 1
  else
    KAPI_REACHABILITY_COUNT=$((KAPI_REACHABILITY_COUNT+1))
    sleep 1
  fi
done
set -e

# If asked to, wait for the total number of control-plane nodes to be registered.
set +e
if [[ "${WAIT_FOR_TOTAL_CONTROL_PLANE_NODES}" == "true" ]];
then
  WAIT_FOR_TOTAL_CONTROL_PLANE_NODES_ATTEMPT_NUM=1
  until [[ $(kubectl get node -l "${CONTROL_PLANE_NODES_LABEL_SELECTOR}" --no-headers | wc -l | tr -d '[:space:]') == "${TOTAL_CONTROL_PLANE_NODES}" ]];
  do
    if [[ ${WAIT_FOR_TOTAL_CONTROL_PLANE_NODES_ATTEMPT_NUM} -gt 180 ]];
    then
      echo "Timed out while waiting for the total number of control-plane nodes."
      exit 1
    else
      WAIT_FOR_TOTAL_CONTROL_PLANE_NODES_ATTEMPT_NUM=$((WAIT_FOR_TOTAL_CONTROL_PLANE_NODES_ATTEMPT_NUM+1))
      sleep 1
    fi
  done
fi
set -e

# Create the target namespace if it does not exist.
kubectl create namespace "${CILIUM_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

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
  kubectl apply -f "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/${KUBE_PROMETHEUS_CRDS_VERSION}/manifests/setup/0servicemonitorCustomResourceDefinition.yaml"
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

# Substitute environment variables into the Cilium Helm values file.
envsubst < "${CILIUM_HELM_VALUES_FILE}" > tmp1 

if [[ "${CILIUM_HELM_VALUES_OVERRIDE_FILE}" != "" ]];
then
  # Substitute environment variables into the Cilium Helm values override file.
  envsubst < "${CILIUM_HELM_VALUES_OVERRIDE_FILE}" | \
  helm upgrade --install "${CILIUM_HELM_RELEASE_NAME}" "${CILIUM_HELM_CHART}" \
  --version "${CILIUM_HELM_VERSION}" -n "${CILIUM_NAMESPACE}" -f tmp1 -f /dev/stdin ${CILIUM_HELM_EXTRA_ARGS}
  rm -f tmp1
else
  envsubst < tmp1 | \
  helm upgrade --install "${CILIUM_HELM_RELEASE_NAME}" "${CILIUM_HELM_CHART}" \
  --version "${CILIUM_HELM_VERSION}" -n "${CILIUM_NAMESPACE}" -f /dev/stdin ${CILIUM_HELM_EXTRA_ARGS}
  rm -f tmp1
fi


# Run any post-install script we may have been provided with.
if [[ "${POST_CILIUM_INSTALL_SCRIPT}" != "" ]];
then
  base64 --decode <<< "${POST_CILIUM_INSTALL_SCRIPT}" | bash
fi

# try to delete the kube-proxy and clear the iptabls using the cilum pods after we install the cilium
if [[ "${DISABLE_KUBE_PROXY}" == "true" ]]; then
  kubectl -n "${KUBE_PROXY_NAMESPACE}" delete daemonset kube-proxy || true
  kubectl -n "${KUBE_PROXY_NAMESPACE}" delete cm kube-proxy || true
  kubectl wait --for=condition=Ready pod -l k8s-app=cilium -n "${CILIUM_NAMESPACE}" 
  pods=$(kubectl get pods -l k8s-app=cilium -o name -n "${CILIUM_NAMESPACE}")
  if [ -n "$pods" ]; then
      while IFS= read -r pod; do
          kubectl -n "${CILIUM_NAMESPACE}" exec $pod -- sh -c 'iptables-save | grep -v KUBE | iptables-restore' 
      done <<< "$pods"
  else
      echo "No pods found with label k8s-app=cilium in cilium namespace"
  fi
fi
