#!/bin/bash

operator="devops"
clusterMember="routed-93"
echo "--------$(hostname)/pre-init-user.sh: updating $clusterMember"
sudo apt update
echo "--------$(hostname)/pre-init-user.sh: upgradinig $clusterMember"
sudo apt upgrade -y
echo "--------$(hostname)/pre-init-user.sh: installing git"
sudo apt install git -y
echo "--------$(hostname)/pre-init-user.sh: installing net-tools"
sudo apt install net-tools -y
echo "--------$(hostname)/pre-init-user.sh: installing telnet"
sudo apt install telnet -y
echo "--------$(hostname)/pre-init-user.sh: installing sshpass"
sudo apt install sshpass -y
echo "--------$(hostname)/pre-init-user.sh: installing tree"
sudo apt install tree -y
echo "--------$(hostname)/pre-init-user.sh: installing fish"
sudo apt install fish -y
echo "--------$(hostname)/pre-init-user.sh: installing jq"
sudo apt install jq -y
echo "--------$(hostname)/pre-init-user.sh: installing tracetoute"
sudo apt install traceroute  -y
