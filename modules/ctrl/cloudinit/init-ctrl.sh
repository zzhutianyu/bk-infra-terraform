#!/bin/bash

# mount disk
mkfs -t ext4 /dev/vdb
mkdir /data
mount /dev/vdb /data

# follow https://bk.tencent.com/docs/document/7.0/172/29311

export HOME="/root"
yum install -y jq unzip uuid
curl -fsSL https://bkopen-1252002024.file.myqcloud.com/ce7/bcs.sh | bash -s -- -i k8s
curl -sSf https://bkopen-1252002024.file.myqcloud.com/ce7/7.0-stable/bkdl-7.0-stable.sh | bash -s -- -ur latest base cert
