#!/bin/bash -e

apt-get install -y jq

mkdir -p -m 0700 /root/.ssh
curl --silent https://api.github.com/meta  | jq --raw-output '"github.com "+.ssh_keys[]' > /root/.ssh/known_hosts
chmod 600 /root/.ssh/known_hosts
cat /root/.ssh/known_hosts
