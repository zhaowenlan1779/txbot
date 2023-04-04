#!/bin/bash -e

apt-get install -y jq

homedir=$( getent passwd "$USER" | cut -d: -f6 )
echo "USER is $USER, Home directory is $homedir"
mkdir -p -m 0700 $homedir/.ssh
curl --silent https://api.github.com/meta  | jq --raw-output '"github.com "+.ssh_keys[]' > $homedir/.ssh/known_hosts
chmod 600 $homedir/.ssh/known_hosts
cat $homedir/.ssh/known_hosts
