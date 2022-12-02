#!/bin/bash
set +x

# ssh key
cat >> /root/.ssh/authorized_keys << EOF
${pub_keys}
EOF