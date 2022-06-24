#!/usr/bin/env bash


KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
# Usage: `hack/local-up-cluster.sh`.
# set runtime config to disable some apis 
RUNTIME_CONFIG=${RUNTIME_CONFIG:-"apps/v1=false,autoscaling/v2=false,batch/v1=false,events.k8s.io/v1=false,flowcontrol.apiserver.k8s.io/v1beta2=false,networking.k8s.io/v1=false,node.k8s.io/v1=false,policy/v1=false,scheduling.k8s.io/v1=false,storage.k8s.io/v1=false"}
### Allow user to supply the source directory.
GO_OUT=${GO_OUT:-"${KUBE_ROOT}/bin"}
#  set log lovel to 7
LOG_LEVEL=${LOG_LEVEL:-7}
# This is the default dir and filename where the apiserver will generate a self-signed cert
# which should be able to be used as the CA to verify itself
CERT_DIR=${CERT_DIR:-"${KUBE_ROOT}/.ocmconfig/cert"}



DOCKER_OPTS=${DOCKER_OPTS:-""}
export DOCKER=(docker "${DOCKER_OPTS[@]}")
DOCKER_ROOT=${DOCKER_ROOT:-""}
ALLOW_PRIVILEGED=${ALLOW_PRIVILEGED:-""}
DENY_SECURITY_CONTEXT_ADMISSION=${DENY_SECURITY_CONTEXT_ADMISSION:-""}

KUBELET_AUTHORIZATION_WEBHOOK=${KUBELET_AUTHORIZATION_WEBHOOK:-""}
KUBELET_AUTHENTICATION_WEBHOOK=${KUBELET_AUTHENTICATION_WEBHOOK:-""}
POD_MANIFEST_PATH=${POD_MANIFEST_PATH:-"/var/run/kubernetes/static-pods"}
KUBELET_FLAGS=${KUBELET_FLAGS:-""}
KUBELET_IMAGE=${KUBELET_IMAGE:-""}
# many dev environments run with swap on, so we don't fail in this env
FAIL_SWAP_ON=${FAIL_SWAP_ON:-"false"}
# Name of the dns addon, eg: "kube-dns" or "coredns"
DNS_ADDON=${DNS_ADDON:-"coredns"}
CLUSTER_CIDR=${CLUSTER_CIDR:-10.1.0.0/16}
SERVICE_CLUSTER_IP_RANGE=${SERVICE_CLUSTER_IP_RANGE:-10.0.0.0/24}
FIRST_SERVICE_CLUSTER_IP=${FIRST_SERVICE_CLUSTER_IP:-10.0.0.1}
# if enabled, must set CGROUP_ROOT
CGROUPS_PER_QOS=${CGROUPS_PER_QOS:-true}
# name of the cgroup driver, i.e. cgroupfs or systemd
CGROUP_DRIVER=${CGROUP_DRIVER:-""}
# if cgroups per qos is enabled, optionally change cgroup root
CGROUP_ROOT=${CGROUP_ROOT:-""}
# owner of client certs, default to current user if not specified
USER=${USER:-$(whoami)}

# required for cni installation
CNI_CONFIG_DIR=${CNI_CONFIG_DIR:-/etc/cni/net.d}
CNI_PLUGINS_VERSION=${CNI_PLUGINS_VERSION:-"v1.0.1"}
CNI_TARGETARCH=${CNI_TARGETARCH:-amd64}
CNI_PLUGINS_TARBALL="${CNI_PLUGINS_VERSION}/cni-plugins-linux-${CNI_TARGETARCH}-${CNI_PLUGINS_VERSION}.tgz"
CNI_PLUGINS_URL="https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_TARBALL}"
CNI_PLUGINS_AMD64_SHA256SUM=${CNI_PLUGINS_AMD64_SHA256SUM:-"5238fbb2767cbf6aae736ad97a7aa29167525dcd405196dfbc064672a730d3cf"}
CNI_PLUGINS_ARM64_SHA256SUM=${CNI_PLUGINS_ARM64_SHA256SUM:-"2d4528c45bdd0a8875f849a75082bc4eafe95cb61f9bcc10a6db38a031f67226"}
CNI_PLUGINS_PPC64LE_SHA256SUM=${CNI_PLUGINS_PPC64LE_SHA256SUM:-"f078e33067e6daaef3a3a5010d6440f2464b7973dec3ca0b5d5be22fdcb1fd96"}
CNI_PLUGINS_S390X_SHA256SUM=${CNI_PLUGINS_S390X_SHA256SUM:-"468d33e16440d9ca4395c6bb2d5b71b35ae4a4df26301e4da85ac70c5ce56822"}

# enables testing eviction scenarios locally.
EVICTION_HARD=${EVICTION_HARD:-"memory.available<100Mi,nodefs.available<10%,nodefs.inodesFree<5%"}
EVICTION_SOFT=${EVICTION_SOFT:-""}
EVICTION_PRESSURE_TRANSITION_PERIOD=${EVICTION_PRESSURE_TRANSITION_PERIOD:-"1m"}

# This script uses docker0 (or whatever container bridge docker is currently using)
# and we don't know the IP of the DNS pod to pass in as --cluster-dns.
# To set this up by hand, set this flag and change DNS_SERVER_IP.
# Note also that you need API_HOST (defined below) for correct DNS.
KUBE_PROXY_MODE=${KUBE_PROXY_MODE:-""}
ENABLE_CLUSTER_DNS=${KUBE_ENABLE_CLUSTER_DNS:-true}
ENABLE_NODELOCAL_DNS=${KUBE_ENABLE_NODELOCAL_DNS:-false}
DNS_SERVER_IP=${KUBE_DNS_SERVER_IP:-10.0.0.10}
LOCAL_DNS_IP=${KUBE_LOCAL_DNS_IP:-169.254.20.10}
DNS_MEMORY_LIMIT=${KUBE_DNS_MEMORY_LIMIT:-170Mi}
DNS_DOMAIN=${KUBE_DNS_NAME:-"cluster.local"}
KUBECTL=${KUBECTL:-"${KUBE_ROOT}/cluster/kubectl.sh"}
WAIT_FOR_URL_API_SERVER=${WAIT_FOR_URL_API_SERVER:-60}
MAX_TIME_FOR_URL_API_SERVER=${MAX_TIME_FOR_URL_API_SERVER:-1}
ENABLE_DAEMON=${ENABLE_DAEMON:-false}
HOSTNAME_OVERRIDE=${HOSTNAME_OVERRIDE:-"127.0.0.1"}
EXTERNAL_CLOUD_PROVIDER=${EXTERNAL_CLOUD_PROVIDER:-false}
EXTERNAL_CLOUD_PROVIDER_BINARY=${EXTERNAL_CLOUD_PROVIDER_BINARY:-""}
EXTERNAL_CLOUD_VOLUME_PLUGIN=${EXTERNAL_CLOUD_VOLUME_PLUGIN:-""}
CONFIGURE_CLOUD_ROUTES=${CONFIGURE_CLOUD_ROUTES:-true}
CLOUD_CTLRMGR_FLAGS=${CLOUD_CTLRMGR_FLAGS:-""}
CLOUD_PROVIDER=${CLOUD_PROVIDER:-""}
CLOUD_CONFIG=${CLOUD_CONFIG:-""}
KUBELET_PROVIDER_ID=${KUBELET_PROVIDER_ID:-"$(hostname)"}
FEATURE_GATES=${FEATURE_GATES:-"AllAlpha=false"}
STORAGE_BACKEND=${STORAGE_BACKEND:-"etcd3"}
STORAGE_MEDIA_TYPE=${STORAGE_MEDIA_TYPE:-"application/vnd.kubernetes.protobuf"}
# preserve etcd data. you also need to set ETCD_DIR.
PRESERVE_ETCD="${PRESERVE_ETCD:-false}"

# enable Kubernetes-CSI snapshotter
ENABLE_CSI_SNAPSHOTTER=${ENABLE_CSI_SNAPSHOTTER:-false}

# RBAC Mode options
AUTHORIZATION_MODE=${AUTHORIZATION_MODE:-"Node,RBAC"}
KUBECONFIG_TOKEN=${KUBECONFIG_TOKEN:-""}
AUTH_ARGS=${AUTH_ARGS:-""}

# WebHook Authentication and Authorization
AUTHORIZATION_WEBHOOK_CONFIG_FILE=${AUTHORIZATION_WEBHOOK_CONFIG_FILE:-""}
AUTHENTICATION_WEBHOOK_CONFIG_FILE=${AUTHENTICATION_WEBHOOK_CONFIG_FILE:-""}

# Install a default storage class (enabled by default)
DEFAULT_STORAGE_CLASS=${KUBE_DEFAULT_STORAGE_CLASS:-true}

# Do not run the mutation detector by default on a local cluster.
# It is intended for a specific type of testing and inherently leaks memory.
KUBE_CACHE_MUTATION_DETECTOR="${KUBE_CACHE_MUTATION_DETECTOR:-false}"
export KUBE_CACHE_MUTATION_DETECTOR

# panic the server on watch decode errors since they are considered coder mistakes
KUBE_PANIC_WATCH_DECODE_ERROR="${KUBE_PANIC_WATCH_DECODE_ERROR:-true}"
export KUBE_PANIC_WATCH_DECODE_ERROR

# Default list of admission Controllers to invoke prior to persisting objects in cluster
# The order defined here does not matter.
ENABLE_ADMISSION_PLUGINS=${ENABLE_ADMISSION_PLUGINS:-"NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,Priority,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,NodeRestriction"}
DISABLE_ADMISSION_PLUGINS=${DISABLE_ADMISSION_PLUGINS:-""}
ADMISSION_CONTROL_CONFIG_FILE=${ADMISSION_CONTROL_CONFIG_FILE:-""}

# START_MODE can be 'all', 'kubeletonly', 'nokubelet', 'nokubeproxy', or 'nokubelet,nokubeproxy'
START_MODE=${START_MODE:-"all"}

# A list of controllers to enable
KUBE_CONTROLLERS="${KUBE_CONTROLLERS:-"*"}"

# Audit policy
AUDIT_POLICY_FILE=${AUDIT_POLICY_FILE:-""}

# sanity check for OpenStack provider
if [ "${CLOUD_PROVIDER}" == "openstack" ]; then
    if [ "${CLOUD_CONFIG}" == "" ]; then
        echo "Missing CLOUD_CONFIG env for OpenStack provider!"
        exit 1
    fi
    if [ ! -f "${CLOUD_CONFIG}" ]; then
        echo "Cloud config ${CLOUD_CONFIG} doesn't exist"
        exit 1
    fi
fi

# Stop right away if the build fails
set -e

source "${KUBE_ROOT}/hack/lib/init.sh"
kube::util::ensure-gnu-sed

function usage {
            echo "This script starts a local kube cluster. "
            echo "Example 0: hack/local-up-cluster.sh -h  (this 'help' usage description)"
            echo "Example 1: hack/local-up-cluster.sh -o _output/dockerized/bin/linux/amd64/ (run from docker output)"
            echo "Example 2: hack/local-up-cluster.sh -O (auto-guess the bin path for your platform)"
            echo "Example 3: hack/local-up-cluster.sh (build a local copy of the source)"
}


# Shut down anyway if there's an error.
set +e

API_PORT=${API_PORT:-0}
API_SECURE_PORT=${API_SECURE_PORT:-6443}

# WARNING: For DNS to work on most setups you should export API_HOST as the docker0 ip address,
API_HOST=${API_HOST:-localhost}
API_HOST_IP=${API_HOST_IP:-"127.0.0.1"}
ADVERTISE_ADDRESS=${ADVERTISE_ADDRESS:-""}
NODE_PORT_RANGE=${NODE_PORT_RANGE:-""}
API_BIND_ADDR=${API_BIND_ADDR:-"0.0.0.0"}
EXTERNAL_HOSTNAME=${EXTERNAL_HOSTNAME:-localhost}

KUBELET_HOST=${KUBELET_HOST:-"127.0.0.1"}
KUBELET_RESOLV_CONF=${KUBELET_RESOLV_CONF:-"/etc/resolv.conf"}
# By default only allow CORS for requests on localhost
API_CORS_ALLOWED_ORIGINS=${API_CORS_ALLOWED_ORIGINS:-/127.0.0.1(:[0-9]+)?$,/localhost(:[0-9]+)?$}
KUBELET_PORT=${KUBELET_PORT:-10250}
# By default we use 0(close it) for it's insecure
KUBELET_READ_ONLY_PORT=${KUBELET_READ_ONLY_PORT:-0}

# Use to increase verbosity on particular files, e.g. LOG_SPEC=token_controller*=5,other_controller*=4
LOG_SPEC=${LOG_SPEC:-""}
LOG_DIR=${LOG_DIR:-"/tmp"}
CONTAINER_RUNTIME=${CONTAINER_RUNTIME:-"remote"}
CONTAINER_RUNTIME_ENDPOINT=${CONTAINER_RUNTIME_ENDPOINT:-"unix:///run/containerd/containerd.sock"}
RUNTIME_REQUEST_TIMEOUT=${RUNTIME_REQUEST_TIMEOUT:-"2m"}
IMAGE_SERVICE_ENDPOINT=${IMAGE_SERVICE_ENDPOINT:-""}
CPU_CFS_QUOTA=${CPU_CFS_QUOTA:-true}
ENABLE_HOSTPATH_PROVISIONER=${ENABLE_HOSTPATH_PROVISIONER:-"false"}
CLAIM_BINDER_SYNC_PERIOD=${CLAIM_BINDER_SYNC_PERIOD:-"15s"} # current k8s default
ENABLE_CONTROLLER_ATTACH_DETACH=${ENABLE_CONTROLLER_ATTACH_DETACH:-"true"} # current default

ROOT_CA_FILE=${CERT_DIR}/server-ca.crt
CLUSTER_SIGNING_CERT_FILE=${CLUSTER_SIGNING_CERT_FILE:-"${CERT_DIR}/client-ca.crt"}
CLUSTER_SIGNING_KEY_FILE=${CLUSTER_SIGNING_KEY_FILE:-"${CERT_DIR}/client-ca.key"}
# Reuse certs will skip generate new ca/cert files under CERT_DIR
# it's useful with PRESERVE_ETCD=true because new ca will make existed service account secrets invalided
REUSE_CERTS=${REUSE_CERTS:-false}


# Ensure CERT_DIR is created for auto-generated crt/key and kubeconfig
mkdir -p "${CERT_DIR}" &>/dev/null || sudo mkdir -p "${CERT_DIR}"
CONTROLPLANE_SUDO=$(test -w "${CERT_DIR}" || echo "sudo -E")

function test_apiserver_off {
    # For the common local scenario, fail fast if server is already running.
    # this can happen if you run local-up-cluster.sh twice and kill etcd in between.
    if [[ "${API_PORT}" -gt "0" ]]; then
        if ! curl --silent -g "${API_HOST}:${API_PORT}" ; then
            echo "API SERVER insecure port is free, proceeding..."
        else
            echo "ERROR starting API SERVER, exiting. Some process on ${API_HOST} is serving already on ${API_PORT}"
            exit 1
        fi
    fi

    if ! curl --silent -k -g "${API_HOST}:${API_SECURE_PORT}" ; then
        echo "API SERVER secure port is free, proceeding..."
    else
        echo "ERROR starting API SERVER, exiting. Some process on ${API_HOST} is serving already on ${API_SECURE_PORT}"
        exit 1
    fi
}

cleanup()
{
  echo "Cleaning up..."
  # delete running images
  # if [[ "${ENABLE_CLUSTER_DNS}" == true ]]; then
  # Still need to figure why this commands throw an error: Error from server: client: etcd cluster is unavailable or misconfigured
  #     ${KUBECTL} --namespace=kube-system delete service kube-dns
  # And this one hang forever:
  #     ${KUBECTL} --namespace=kube-system delete rc kube-dns-v10
  # fi

  # Check if the API server is still running
  [[ -n "${APISERVER_PID-}" ]] && kube::util::read-array APISERVER_PIDS < <(pgrep -P "${APISERVER_PID}" ; ps -o pid= -p "${APISERVER_PID}")
  [[ -n "${APISERVER_PIDS-}" ]] && sudo kill "${APISERVER_PIDS[@]}" 2>/dev/null
  exit 0
}


function healthcheck {
  if [[ -n "${APISERVER_PID-}" ]] && ! sudo kill -0 "${APISERVER_PID}" 2>/dev/null; then
    warning_log "API server terminated unexpectedly, see ${APISERVER_LOG}"
    APISERVER_PID=
  fi
}

function print_color {
  message=$1
  prefix=${2:+$2: } # add colon only if defined
  color=${3:-1}     # default is red
  echo -n "$(tput bold)$(tput setaf "${color}")"
  echo "${prefix}${message}"
  echo -n "$(tput sgr0)"
}

function warning_log {
  print_color "$1" "W$(date "+%m%d %H:%M:%S")]" 1
}

function set_service_accounts {
    SERVICE_ACCOUNT_LOOKUP=${SERVICE_ACCOUNT_LOOKUP:-true}
    SERVICE_ACCOUNT_KEY="${KUBE_ROOT}/.ocmconfig/sak/kube-serviceaccount.key"
    # Generate ServiceAccount key if needed
    if [[ ! -f "${SERVICE_ACCOUNT_KEY}" ]]; then
      mkdir -p "$(dirname "${SERVICE_ACCOUNT_KEY}")"
      openssl genrsa -out "${SERVICE_ACCOUNT_KEY}" 2048 2>/dev/null
    fi
}

function generate_certs {
    # Create CA signers
    if [[ "${ENABLE_SINGLE_CA_SIGNER:-}" = true ]]; then
        kube::util::create_signing_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" server '"client auth","server auth"'
        sudo cp "${CERT_DIR}/server-ca.key" "${CERT_DIR}/client-ca.key"
        sudo cp "${CERT_DIR}/server-ca.crt" "${CERT_DIR}/client-ca.crt"
        sudo cp "${CERT_DIR}/server-ca-config.json" "${CERT_DIR}/client-ca-config.json"
    else
        kube::util::create_signing_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" server '"server auth"'
        kube::util::create_signing_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" client '"client auth"'
    fi

    # Create auth proxy client ca
    kube::util::create_signing_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" request-header '"client auth"'

    # serving cert for kube-apiserver
    kube::util::create_serving_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" "server-ca" kube-apiserver kubernetes.default kubernetes.default.svc "localhost" "${API_HOST_IP}" "${API_HOST}" "${FIRST_SERVICE_CLUSTER_IP}"

    # Create client certs signed with client-ca, given id, given CN and a number of groups
    kube::util::create_client_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" 'client-ca' controller system:kube-controller-manager
    kube::util::create_client_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" 'client-ca' scheduler  system:kube-scheduler
    kube::util::create_client_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" 'client-ca' admin system:admin system:masters
    kube::util::create_client_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" 'client-ca' kube-apiserver kube-apiserver

    # Create matching certificates for kube-aggregator
    kube::util::create_serving_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" "server-ca" kube-aggregator api.kube-public.svc "localhost" "${API_HOST_IP}"
    kube::util::create_client_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" request-header-ca auth-proxy system:auth-proxy

    # TODO remove masters and add rolebinding
    kube::util::create_client_certkey "${CONTROLPLANE_SUDO}" "${CERT_DIR}" 'client-ca' kube-aggregator system:kube-aggregator system:masters
    kube::util::write_client_kubeconfig "${CONTROLPLANE_SUDO}" "${CERT_DIR}" "${ROOT_CA_FILE}" "${API_HOST}" "${API_SECURE_PORT}" kube-aggregator
}

function start_apiserver {
    security_admission=""
    if [[ -n "${DENY_SECURITY_CONTEXT_ADMISSION}" ]]; then
      security_admission=",SecurityContextDeny"
    fi

    # Append security_admission plugin
    ENABLE_ADMISSION_PLUGINS="${ENABLE_ADMISSION_PLUGINS}${security_admission}"

    authorizer_arg=""
    if [[ -n "${AUTHORIZATION_MODE}" ]]; then
      authorizer_arg="--authorization-mode=${AUTHORIZATION_MODE}"
    fi
    priv_arg=""
    if [[ -n "${ALLOW_PRIVILEGED}" ]]; then
      priv_arg="--allow-privileged=${ALLOW_PRIVILEGED}"
    fi

    runtime_config=""
    if [[ -n "${RUNTIME_CONFIG}" ]]; then
      runtime_config="--runtime-config=${RUNTIME_CONFIG}"
    fi

    # Let the API server pick a default address when API_HOST_IP
    # is set to 127.0.0.1
    advertise_address=""
    if [[ "${API_HOST_IP}" != "127.0.0.1" ]]; then
        advertise_address="--advertise-address=${API_HOST_IP}"
    fi
    if [[ "${ADVERTISE_ADDRESS}" != "" ]] ; then
        advertise_address="--advertise-address=${ADVERTISE_ADDRESS}"
    fi
    node_port_range=""
    if [[ "${NODE_PORT_RANGE}" != "" ]] ; then
        node_port_range="--service-node-port-range=${NODE_PORT_RANGE}"
    fi

    if [[ "${REUSE_CERTS}" != true ]]; then
      # Create Certs
      generate_certs
    fi

    cloud_config_arg="--cloud-provider=${CLOUD_PROVIDER} --cloud-config=${CLOUD_CONFIG}"
    if [[ "${EXTERNAL_CLOUD_PROVIDER:-}" == "true" ]]; then
      cloud_config_arg="--cloud-provider=external"
    fi

    if [[ -z "${EGRESS_SELECTOR_CONFIG_FILE:-}" ]]; then
      cat <<EOF > /tmp/kube_egress_selector_configuration.yaml
apiVersion: apiserver.k8s.io/v1beta1
kind: EgressSelectorConfiguration
egressSelections:
- name: cluster
  connection:
    proxyProtocol: Direct
- name: controlplane
  connection:
    proxyProtocol: Direct
- name: etcd
  connection:
    proxyProtocol: Direct
EOF
      EGRESS_SELECTOR_CONFIG_FILE="/tmp/kube_egress_selector_configuration.yaml"
    fi

    if [[ -z "${AUDIT_POLICY_FILE}" ]]; then
      cat <<EOF > /tmp/kube-audit-policy-file
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF
      AUDIT_POLICY_FILE="/tmp/kube-audit-policy-file"
    fi

    APISERVER_LOG=${LOG_DIR}/kube-apiserver.log
    # shellcheck disable=SC2086
    ${CONTROLPLANE_SUDO} "${GO_OUT}/ocm-controlplane" "${authorizer_arg}" "${priv_arg}" ${runtime_config} \
      ${cloud_config_arg} \
      "${advertise_address}" \
      "${node_port_range}" \
      --v="${LOG_LEVEL}" \
      --vmodule="${LOG_SPEC}" \
      --audit-policy-file="${AUDIT_POLICY_FILE}" \
      --audit-log-path="${LOG_DIR}/kube-apiserver-audit.log" \
      --authorization-webhook-config-file="${AUTHORIZATION_WEBHOOK_CONFIG_FILE}" \
      --authentication-token-webhook-config-file="${AUTHENTICATION_WEBHOOK_CONFIG_FILE}" \
      --cert-dir="${CERT_DIR}" \
      --egress-selector-config-file="${EGRESS_SELECTOR_CONFIG_FILE:-}" \
      --client-ca-file="${CERT_DIR}/client-ca.crt" \
      --kubelet-client-certificate="${CERT_DIR}/client-kube-apiserver.crt" \
      --kubelet-client-key="${CERT_DIR}/client-kube-apiserver.key" \
      --service-account-key-file="${SERVICE_ACCOUNT_KEY}" \
      --service-account-lookup="${SERVICE_ACCOUNT_LOOKUP}" \
      --service-account-issuer="https://kubernetes.default.svc" \
      --service-account-jwks-uri="https://kubernetes.default.svc/openid/v1/jwks" \
      --service-account-signing-key-file="${SERVICE_ACCOUNT_KEY}" \
      --enable-admission-plugins="${ENABLE_ADMISSION_PLUGINS}" \
      --disable-admission-plugins="${DISABLE_ADMISSION_PLUGINS}" \
      --admission-control-config-file="${ADMISSION_CONTROL_CONFIG_FILE}" \
      --bind-address="${API_BIND_ADDR}" \
      --secure-port="${API_SECURE_PORT}" \
      --tls-cert-file="${CERT_DIR}/serving-kube-apiserver.crt" \
      --tls-private-key-file="${CERT_DIR}/serving-kube-apiserver.key" \
      --storage-backend="${STORAGE_BACKEND}" \
      --storage-media-type="${STORAGE_MEDIA_TYPE}" \
      # --etcd-servers="http://${ETCD_HOST}:${ETCD_PORT}" \
      --service-cluster-ip-range="${SERVICE_CLUSTER_IP_RANGE}" \
      --feature-gates="${FEATURE_GATES}" \
      --external-hostname="${EXTERNAL_HOSTNAME}" \
      --requestheader-username-headers=X-Remote-User \
      --requestheader-group-headers=X-Remote-Group \
      --requestheader-extra-headers-prefix=X-Remote-Extra- \
      --requestheader-client-ca-file="${CERT_DIR}/request-header-ca.crt" \
      --requestheader-allowed-names=system:auth-proxy \
      --proxy-client-cert-file="${CERT_DIR}/client-auth-proxy.crt" \
      --proxy-client-key-file="${CERT_DIR}/client-auth-proxy.key" \
      --cors-allowed-origins="${API_CORS_ALLOWED_ORIGINS}" >"${APISERVER_LOG}" 2>&1 &
    APISERVER_PID=$!

    # Wait for kube-apiserver to come up before launching the rest of the components.
    echo "Waiting for apiserver to come up"
    kube::util::wait_for_url "https://${API_HOST_IP}:${API_SECURE_PORT}/healthz" "apiserver: " 1 "${WAIT_FOR_URL_API_SERVER}" "${MAX_TIME_FOR_URL_API_SERVER}" \
        || { echo "check apiserver logs: ${APISERVER_LOG}" ; exit 1 ; }

    # Create kubeconfigs for all components, using client certs
    kube::util::write_client_kubeconfig "${CONTROLPLANE_SUDO}" "${CERT_DIR}" "${ROOT_CA_FILE}" "${API_HOST}" "${API_SECURE_PORT}" admin
    ${CONTROLPLANE_SUDO} chown "${USER}" "${CERT_DIR}/client-admin.key" # make readable for kubectl

    if [[ -z "${AUTH_ARGS}" ]]; then
        AUTH_ARGS="--client-key=${CERT_DIR}/client-admin.key --client-certificate=${CERT_DIR}/client-admin.crt"
    fi
    # Grant apiserver permission to speak to the kubelet
    ${KUBECTL} --kubeconfig "${CERT_DIR}/admin.kubeconfig" create clusterrolebinding kube-apiserver-kubelet-admin --clusterrole=system:kubelet-api-admin --user=kube-apiserver

    # Grant kubelets permission to request client certificates
    ${KUBECTL} --kubeconfig "${CERT_DIR}/admin.kubeconfig" create clusterrolebinding kubelet-csr --clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeclient --group=system:nodes

    ${CONTROLPLANE_SUDO} cp "${CERT_DIR}/admin.kubeconfig" "${CERT_DIR}/admin-kube-aggregator.kubeconfig"
    ${CONTROLPLANE_SUDO} chown -R "$(whoami)" "${CERT_DIR}"
    ${KUBECTL} config set-cluster local-up-cluster --kubeconfig="${CERT_DIR}/admin-kube-aggregator.kubeconfig" --server="https://${API_HOST_IP}:31090"
    echo "use 'kubectl --kubeconfig=${CERT_DIR}/admin-kube-aggregator.kubeconfig' to use the aggregated API server"

}

function print_success {
if [[ "${START_MODE}" != "kubeletonly" ]]; then
  if [[ "${ENABLE_DAEMON}" = false ]]; then
    echo "Local Kubernetes cluster is running. Press Ctrl-C to shut it down."
  else
    echo "Local Kubernetes cluster is running."
  fi
  cat <<EOF

Logs:
  ${APISERVER_LOG:-}
  ${CTLRMGR_LOG:-}
  ${CLOUD_CTLRMGR_LOG:-}
  ${PROXY_LOG:-}
  ${SCHEDULER_LOG:-}
EOF
fi

if [[ "${START_MODE}" == "all" ]]; then
  echo "  ${KUBELET_LOG}"
elif [[ "${START_MODE}" == *"nokubelet"* ]]; then
  echo
  echo "No kubelet was started because you set START_MODE=nokubelet"
  echo "Run this script again with START_MODE=kubeletonly to run a kubelet"
fi

if [[ "${START_MODE}" != "kubeletonly" ]]; then
  echo
  if [[ "${ENABLE_DAEMON}" = false ]]; then
    echo "To start using your cluster, you can open up another terminal/tab and run:"
  else
    echo "To start using your cluster, run:"
  fi
  cat <<EOF

  export KUBECONFIG=${CERT_DIR}/admin.kubeconfig
  cluster/kubectl.sh

Alternatively, you can write to the default kubeconfig:

  export KUBERNETES_PROVIDER=local

  cluster/kubectl.sh config set-cluster local --server=https://${API_HOST}:${API_SECURE_PORT} --certificate-authority=${ROOT_CA_FILE}
  cluster/kubectl.sh config set-credentials myself ${AUTH_ARGS}
  cluster/kubectl.sh config set-context local --cluster=local --user=myself
  cluster/kubectl.sh config use-context local
  cluster/kubectl.sh
EOF
else
  cat <<EOF
The kubelet was started.

Logs:
  ${KUBELET_LOG}
EOF
fi
}


# 
if [[ "${START_MODE}" != "kubeletonly" ]]; then
  test_apiserver_off
fi

kube::util::test_openssl_installed
kube::util::ensure-cfssl

export KUBELET_CIDFILE=/tmp/kubelet.cid
if [[ "${ENABLE_DAEMON}" = false ]]; then
  trap cleanup EXIT
fi

echo "Starting services now!"
if [[ "${START_MODE}" != "kubeletonly" ]]; then
  set_service_accounts
  start_apiserver
fi

print_success

if [[ "${ENABLE_DAEMON}" = false ]]; then
  while true; do sleep 1; healthcheck; done
fi
