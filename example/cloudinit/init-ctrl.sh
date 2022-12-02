#!/bin/bash
# follow https://bk.tencent.com/docs/document/7.0/172/29311

export HOME="/root"
yum install -y jq unzip uuid
curl -sSf https://bkopen-1252002024.file.myqcloud.com/ce7/7.0-stable/bkdl-7.0-stable.sh | bash -s -- -ur latest base cert
