#!/bin/bash -e

apt-get install -y jq
mkdir -p -m 0700 /home/runner/.ssh

homedir=$( getent passwd "$USER" | cut -d: -f6 )
curl --silent https://api.github.com/meta  | jq --raw-output '"github.com "+.ssh_keys[]' > $homedir/.ssh/known_hosts
chmod 600 $homedir/.ssh/known_hosts
cat $homedir/.ssh/known_hosts
