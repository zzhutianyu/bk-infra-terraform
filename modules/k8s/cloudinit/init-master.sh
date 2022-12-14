#!/bin/bash
set +x

# mount disk
mkfs -t ext4 /dev/vdb
mkdir /data
mount /dev/vdb /data

export PATH="/root/.local/bin:$PATH"
export HOME="/root"
# setup tccli
yum install -y python3
yum install -y python3-pip

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

# pip source
pip3 install -i https://mirrors.cloud.tencent.com/pypi/simple tccli --user
# pip3 install tccli --user

# 去除K8S_EXTRA_ARGS 让节点可以配置
_retry curl -fsSL ${k8s_sh_url} | sed 's/\^source |\^export /\^source |\^export |K8S_EXTRA_ARGS/g' |bash -s -- -i k8s | tee /tmp/k8s_output

# upload join config
tccli ssm PutSecretValue --cli-unfold-argument --region ${region} --SecretName ${sm_name} --VersionId ${sm_version_id_for_control_plane} --SecretString "$(cat /tmp/k8s_output | grep 'k8s-control-plane' -B 4)" --use-cvm-role
tccli ssm PutSecretValue --cli-unfold-argument --region ${region} --SecretName ${sm_name} --VersionId ${sm_version_id_for_node} --SecretString "$(cat /tmp/k8s_output | grep 'k8s-node' -B 4)" --use-cvm-role

# clean
rm -rf /tmp/k8s_output

cat > /root/.bcs/update-token.sh << EOF
export PATH="/root/.local/bin:$PATH"
export HOME="/root"
curl -fsSL ${k8s_sh_url} | bash -s -- -i k8sctrl > /tmp/k8s_output
# upload join config
tccli ssm UpdateSecret --cli-unfold-argument --region ${region} --SecretName ${sm_name} --VersionId ${sm_version_id_for_control_plane} --SecretString "\$(cat /tmp/k8s_output | grep 'k8s-control-plane' -B 4)" --use-cvm-role
tccli ssm UpdateSecret --cli-unfold-argument --region ${region} --SecretName ${sm_name} --VersionId ${sm_version_id_for_node} --SecretString "\$(cat /tmp/k8s_output | grep 'k8s-node' -B 4)" --use-cvm-role
rm -rf /tmp/k8s_output
EOF

# add crontab to update token
crontab -l | { cat; echo "0 */12 * * * sh /root/.bcs/update-token.sh >> /var/log/bcs-update-token.log 2>&1"; } | crontab -