#!/bin/bash

# Automation stretegies:
# - profile based presetting
#     - https://gist.github.com/jeanlouisferey/15be1f421eb9f9a66f1c74d410de2675 
# - shell script
# - lxd coud-init
#     - https://cloudinit.readthedocs.io/en/latest/tutorial/lxd.html
#     - https://documentation.ubuntu.com/lxd/en/latest/cloud-init/
# - lxd gist: 
#     - https://gist.github.com/mob-sakai/174a32b95572e7d8fdbf8e6f43a528f6
    

# global variables
export HOST_USER="emp-09"
export HOST_NAME="emp-09"
export CB_OPERATOR="devops"
export CLUSTER_MEMBER="routed-93"
export EXEC_FILE="cluster-update-workers.sh"
export SHARED_FILES_HOST="/home/${HOST_USER}/cb-bootstrap/shared-files"
export SHARED_FILES_CLUSTER_MEMBER="/home/${CB_OPERATOR}/cb-bootstrap/shared-files"
export P_SECR=`cat /tmp/p`
export FX_DIR="/tmp/fx.sh"




# executed at the physical machine

# operator="devops"
# clusterMember="routed-93"
# echo "."
# echo "."
# echo "."
# echo "--------$(hostname)/STARTING cluster-update-worker.sh"
# echo "--------$(hostname)/cluster-init-user.sh: whoami: $(whoami)"
# echo "--------$(hostname)/cluster-update-worker.sh: executing at the cluster member $clusterMember"
# echo "--------$(hostname)/cluster-update-worker.sh: setting up initial user for $clusterMember"
# echo "--------$(hostname)/cluster-update-worker.sh: check if cluster-init-user.sh is avilable"
# print header
cmdHead='
    source ${FX_DIR}
    fxHeader'

# this iteration should be based on json file
# json data:
# name
# cb-user
# parent project
# define container 
# networking strategy (default, routed, mcvlan)
# name of project
# applicatiion type
# brand name
# number of instances
# preferred dns records
# the dns records should allow rereation of container if it crushes
# define container storage
# list of files to place in /tmp/file of each instance
# this can be done via gist, cloud-init or manual
# 
count=3
i=0;
while [ "$i" -lt $count ]
do
    j=$(($i + 1))

    # create container as per json description

    # create or restore containier storage as per json description

    # register container in dns (container should be replacable without loosing identity)

    # -------------------------------------------------------------------------------------------------------------------------------
    # remove stale application files to worker container /home/$operator/.cb/ DIRECTORY
    # -------------------------------------------------------------------------------------------------------------------------------
    # 1. install fx.sh file
    # 2. install application specific files based on json file
    # sudo lxc exec cd-db-0$j -- rm -f /home/devops/.cb/worker-init-user.sh
    sudo lxc exec cd-db-0$j -- rm -f /home/devops/.cb/mysql-shell-scripts/init_cluster.js
    sudo lxc exec cd-db-0$j -- rm -f /home/devops/.cb/mysql-shell-scripts/build_cluster.js

    # -------------------------------------------------------------------------------------------------------------------------------
    # PUSH INITIAL FILES TO worker container /home/$operator/.cb/ DIRECTORY
    # -------------------------------------------------------------------------------------------------------------------------------
    # echo "--------$(hostname)/cluster-update-worker.sh: pushing shared-files/pre-init-user.sh from $clusterMember to cd-db-0$j"
    # lxc file push /tmp/pre-init-user.sh  cd-db-0$j/tmp/pre-init-user.sh
    # sudo lxc exec cd-db-0$j -- sh /tmp/worker-init-user.sh

    echo "--------$(hostname)/cluster-update-worker.sh: pushing shared-files/p from $clusterMember to cd-db-0$j"
    # remove destination file
    lxc exec cd-db-0$j -- rm -f /tmp/p
    # send file
    lxc file push /tmp/p cd-db-0$j/tmp/p
    echo "--------$(hostname)/cluster-update-worker.sh: pushing worker-init-user.sh from $clusterMember to cd-db-0$j"
    # remove destination file
    lxc exec cd-db-0$j -- rm -f /tmp/worker-init-user.sh 
    # send file
    lxc file push /tmp/worker-init-user.sh      cd-db-0$j/tmp/worker-init-user.sh
    echo "--------$(hostname)/cluster-update-worker.sh: setting up initial user at cd-db-0$j"
    sudo lxc exec cd-db-0$j -- sh /tmp/worker-init-user.sh
    echo "--------$(hostname)/cluster-update-worker.sh: pushing init_cluster.js from $clusterMember to cd-db-0$j"
    sudo lxc file push /home/devops/.cb/mysql-shell-scripts/init_cluster.js             cd-db-0$j/home/devops/.cb/mysql-shell-scripts/init_cluster.js
    echo "--------$(hostname)/cluster-update-worker.sh: pushing init_build_cluster.js from $clusterMember to cd-db-0$j"
    sudo lxc file push /home/devops/.cb/mysql-shell-scripts/build_cluster.js            cd-db-0$j/home/devops/.cb/mysql-shell-scripts/build_cluster.js
    sudo lxc exec cd-db-0$j -- chown -R devops:devops /home/devops/
    sudo lxc exec cd-db-0$j -- chmod -R 775 /home/devops/
    i=$(($i + 1))
done