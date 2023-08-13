#!/bin/bash

# global variables
export HOST_USER="emp-09"
export HOST_NAME="emp-09"
export CB_OPERATOR="devops"
export CLUSTER_MEMBER="routed-93"
export EXEC_FILE="cluster-update-workers-mf.sh"
export SHARED_FILES_HOST="/home/${HOST_USER}/cb-bootstrap/shared-files"
export SHARED_FILES_CLUSTER_MEMBER="/home/${CB_OPERATOR}/cb-bootstrap/shared-files"
export P_SECR=`cat /tmp/p`
export FX_DIR="/tmp/fx.sh"
export APP_NAME="cd-api-0"




# executed at the physical machine

# operator="devops"
# clusterMember="routed-93"
# echo "."
# echo "."
# echo "."
# echo "--------$(hostname)/STARTING cluster-update-worker-mf.sh"
# echo "--------$(hostname)/cluster-init-user.sh: whoami: $(whoami)"
# echo "--------$(hostname)/cluster-update-worker-mf.sh: executing at the cluster member $clusterMember"
# echo "--------$(hostname)/cluster-update-worker-mf.sh: setting up initial user for $clusterMember"
# echo "--------$(hostname)/cluster-update-worker-mf.sh: check if cluster-init-user.sh is avilable"
# print header
cmdHead='
    source ${FX_DIR}
    fxHeader'

# this iteration should be based on json file
# set hosts file
# json data:
# name
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

# count=3
# i=0;
# while [ "$i" -lt $count ]
for instance in cd-shell-01 cd-user-01 cd-moduleman-01 cd-comm-01 cd-pub-01 cd-sio-01;
do

    # create container as per json description

    # create or restore containier storage as per json description

    # register container in dns (container should be replacable without loosing identity)

    # -------------------------------------------------------------------------------------------------------------------------------
    # remove stale application files to worker container /home/$operator/.cb/ DIRECTORY
    # -------------------------------------------------------------------------------------------------------------------------------
    # 1. install fx.sh file
    # 2. install application specific files based on json file
    # sudo lxc exec $instance -- rm -f /home/devops/.cb/worker-init-user.sh
    sudo lxc exec $instance -- rm -f /tmp/fx.sh
    # sudo lxc exec $instance -- rm -f /home/devops/.cb/mysql-shell-scripts/init_cluster.js
    # sudo lxc exec $instance -- rm -f /home/devops/.cb/mysql-shell-scripts/build_cluster.js

    # -------------------------------------------------------------------------------------------------------------------------------
    # PUSH INITIAL FILES TO worker container /home/$operator/.cb/ DIRECTORY
    # -------------------------------------------------------------------------------------------------------------------------------
    # echo "--------$(hostname)/cluster-update-worker-mf.sh: pushing shared-files/pre-init-user.sh from $clusterMember to $instance"
    # lxc file push /tmp/pre-init-user.sh  $instance/tmp/pre-init-user.sh
    # sudo lxc exec $instance -- sh /tmp/worker-init-user.sh
    sudo lxc file push /tmp/fx.sh $instance/tmp/fx.sh

    echo "--------$(hostname)/cluster-update-worker-mf.sh: pushing shared-files/p from $clusterMember to $instance"
    # remove destination file
    lxc exec $instance -- rm -f /tmp/p
    # send file
    lxc file push /tmp/p $instance/tmp/p
    echo "--------$(hostname)/cluster-update-worker-mf.sh: pushing worker-init-user.sh from $clusterMember to $instance"
    # remove destination file
    lxc exec $instance -- rm -f /tmp/worker-init-user.sh 
    # send file
    lxc file push /tmp/worker-init-user.sh      $instance/tmp/worker-init-user.sh
    echo "--------$(hostname)/cluster-update-worker-mf.sh: setting up initial user at $instance"
    sudo lxc exec $instance -- sh /tmp/worker-init-user.sh
    # echo "--------$(hostname)/cluster-update-worker-mf.sh: pushing init_cluster.js from $clusterMember to $instance"
    # sudo lxc file push /home/devops/.cb/mysql-shell-scripts/init_cluster.js             $instance/home/devops/.cb/mysql-shell-scripts/init_cluster.js
    # echo "--------$(hostname)/cluster-update-worker-mf.sh: pushing init_build_cluster.js from $clusterMember to $instance"
    # sudo lxc file push /home/devops/.cb/mysql-shell-scripts/build_cluster.js            $instance/home/devops/.cb/mysql-shell-scripts/build_cluster.js
    sudo lxc exec $instance -- chown -R devops:devops /home/devops/
    sudo lxc exec $instance -- chmod -R 775 /home/devops/
    i=$(($i + 1))
done