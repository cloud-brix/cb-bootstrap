#!/bin/bash

# script executed at a cluster member (ansible controller) assuming initial user(devops) has alreaydy been setup

clusterMember="routed-93"
sudo -H -u devops bash -c '
clusterMember="routed-93"
echo "."
echo "."
echo "."
echo "--------$(hostname)/STARTING cluster-update-dirs.sh"
echo "--------$(hostname)/cluster-init-user.sh: whoami: $(whoami)"
echo "--------$(hostname)/cluster-update-dirs.sh: executing at $(hostname)"
echo "--------$(hostname)/cluster-update-dirs.sh: executing at the cluster member $clusterMember"
if [ -d "/home/devops/cb-bootstrap" ] 
then
    echo "--------$(hostname)/cluster-update-dirs.sh: cloud-brix files will be updated at $(hostname)"
    cd /home/devops/cb-bootstrap
    git fetch --all
    cd /home/devops/
else
    echo "--------$(hostname)/cluster-update-dirs.sh: updating source files at $(hostname)"
    cd /home/devops/
    git clone https://github.com/cloud-brix/cb-bootstrap.git
fi

if [ -d "/home/devops/.cb" ] 
then
    echo "--------$(hostname)/cluster-update-dirs.sh: $(hostname): .cb dir exists"
else
    echo "--------$(hostname)/cluster-update-dirs.sh: $(hostname): creating new .cb dir"
    mkdir .cb
fi


if [ -d "/home/devops/.cb/mysql-shell-scripts/" ] 
then
    echo "--------$(hostname)/cluster-update-dirs.sh: $(hostname): /home/devops/.cb/mysql-shell-scripts/ dir exists"
else
    echo "--------$(hostname)/cluster-update-dirs.sh: $(hostname): creating new .cb/mysql-shell-scriptsdir"
    mkdir -p /home/devops/.cb/mysql-shell-scripts/
fi

'
