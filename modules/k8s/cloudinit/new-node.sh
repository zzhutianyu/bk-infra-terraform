#!/bin/bash
set +x

# mount disk
mkfs -t ext4 /dev/vdb
mkdir /data
mount /dev/vdb /data

export PATH="/root/.local/bin:$PATH"
export HOME="/root"

_retry () {
    local n=1
    local max=2
    local delay=1
    while true; do
        if "$@"; then
            break
        elif (( n < max )); then
                ((n++))
                warning "Command failed. Attempt $n/$max:"
                sleep $delay;
        else
                error "The command $* has failed after $n attempts."
        fi
    done
}
# setup tccli
yum install -y python3
yum install -y python3-pip
yum install -y jq

# pip source
pip3  install -i https://mirrors.cloud.tencent.com/pypi/simple tccli
# pip3  install  tccli

# get install env
tccli ssm GetSecretValue --cli-unfold-argument --region ${region} --SecretName ${sm_name} --VersionId ${version_id} --use-cvm-role | jq -r '.SecretString' > /tmp/join.sh

chmod +x /tmp/join.sh

if [ -n "${dedicated}" ];then
    export K8S_EXTRA_ARGS="$(cat <<EOF
allowed-unsafe-sysctls: 'net.ipv4.tcp_tw_reuse'
    node-labels: 'group=${group}'
    register-with-taints: 'group=${group}:NoSchedule'
EOF
)"
    _retry sh /tmp/join.sh
    rm -rf /tmp/join.sh
    exit 0
fi

export K8S_EXTRA_ARGS="$(cat <<EOF
allowed-unsafe-sysctls: 'net.ipv4.tcp_tw_reuse'
    node-labels: 'group=${group}'
EOF
)"
_retry sh /tmp/join.sh

rm -rf /tmp/join.sh
