#!/bin/bash

set -x
export PATH="/root/.local/bin:$PATH"
export HOME="/root"
# setup tccli
yum install -y python3
yum install -y python3-pip

# pip source
# pip3 install -i https://mirrors.cloud.tencent.com/pypi/simple tccli --user
pip3 install tccli --user

curl -fsSL ${k8s_sh_url} | bash -s -- -i k8s | tee /tmp/k8s_output

# upload join config
tccli ssm PutSecretValue --cli-unfold-argument --region ${region} --SecretName ${sm_name} --VersionId ${sm_version_id_for_control_plane} --SecretString "$(cat /tmp/k8s_output | grep 'k8s-control-plane' -B 4)" --use-cvm-role
tccli ssm PutSecretValue --cli-unfold-argument --region ${region} --SecretName ${sm_name} --VersionId ${sm_version_id_for_node} --SecretString "$(cat /tmp/k8s_output | grep 'k8s-node' -B 4)" --use-cvm-role



# clean
rm -rf /tmp/k8s_output