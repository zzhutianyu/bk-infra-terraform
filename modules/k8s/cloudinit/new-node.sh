#!/bin/bash
set -x
export PATH="/root/.local/bin:$PATH"
export HOME="/root"
# setup tccli
yum install -y python3
yum install -y python3-pip
yum install -y jq

# pip source
# pip3  install -i https://mirrors.cloud.tencent.com/pypi/simple tccli
pip3  install  tccli

# get install env
tccli ssm GetSecretValue --cli-unfold-argument --region ${region} --SecretName ${sm_name} --VersionId ${version_id} --use-cvm-role | jq -r '.SecretString' > /tmp/join.sh

chmod +x /tmp/join.sh

export K8S_EXTRA_ARGS="$(cat <<EOF
allowed-unsafe-sysctls: 'net.ipv4.tcp_tw_reuse'
node-labels: 'group=${group}'
EOF
)" 

. /tmp/join.sh

rm -rf /tmp/join.sh
