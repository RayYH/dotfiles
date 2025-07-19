#!/usr/bin/env bash

curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sudo sh /tmp/get-docker.sh
rm /tmp/get-docker.sh
sudo usermod -aG docker $USER
