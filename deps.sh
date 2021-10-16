#!/bin/bash -e

git config --global user.email "50136859+zhaobot@users.noreply.github.com"
git config --global user.name "zhaobot"

pip3 install transifex-client

# Setup RC file for tx
cat << EOF > ~/.transifexrc
[https://www.transifex.com]
hostname = https://www.transifex.com
username = api
password = $TRANSIFEX_API_TOKEN
EOF
