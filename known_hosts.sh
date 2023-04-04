#!/bin/bash -e

apt-get install -y jq

echo "Home directory is $HOME"
mkdir -p -m 0700 ~/.ssh
curl --silent https://api.github.com/meta  | jq --raw-output '"github.com "+.ssh_keys[]' > ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts
cat ~/.ssh/known_hosts
