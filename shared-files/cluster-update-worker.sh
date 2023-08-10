#!/bin/bash
# executed at the physical machine

operator="devops"
clusterMember="routed-93"
echo "."
echo "."
echo "."
echo "--------$(hostname)/STARTING cluster-update-worker.sh"
echo "--------$(hostname)/cluster-init-user.sh: whoami: $(whoami)"
echo "--------$(hostname)/cluster-update-worker.sh: executing at the cluster member $clusterMember"
echo "--------$(hostname)/cluster-update-worker.sh: setting up initial user for $clusterMember"
echo "--------$(hostname)/cluster-update-worker.sh: check if cluster-init-user.sh is avilable"
# ls -la /home/devops/.cb/
# git config --global --add safe.directory /home/devops/cb-bootstrap
# sh /home/devops/.cb/cluster-init-user.sh
# if [ -d "/home/$operator/cb-bootstrap" ] 
# then
#     echo "--------$(hostname)/cluster-update-worker.sh: cloud-brix files for $clusterMember will be updated"
#     cd /home/$operator/cb-bootstrap
#     sudo -H -u devops bash -c 'git fetch --all'
#     # git pull --force "@{u}:HEAD"
#     cd /home/$operator/
# else
#     echo "--------$(hostname)/cluster-update-worker.sh: updating source files for $clusterMember"
#     cd /home/$operator/
#     # git clone https://github.com/cloud-brix/cb-bootstrap.git
#     sudo -H -u devops bash -c 'git clone https://github.com/cloud-brix/cb-bootstrap.git'
# fi


# ***********************************************************************************************************************
# # ----------------------------------------------
# # initialize worker node

# # for i in {1..3}
# count=3
# i=0
# while [ $i -lt $count ]
# do
#     j=$(($i + 1))

#     # -----------------------------------------------------
#     # REMOVE FILES
#     # -----------------------------------------------------
#     echo "--------$(hostname)/cluster-init-user.sh: delete file pre-init-user.sh from cd-db-0$j"
#     lxc exec cd-db-0$j -- rm -f /tmp/pre-init-user.sh
#     echo "--------$(hostname)/cluster-init-user.sh: delete file worker-init-user.sh from cd-db-0$j"
#     lxc exec cd-db-0$j -- rm -f /tmp/worker-init-user.sh

#     # -----------------------------------------------------
#     # ADD FILES
#     # -----------------------------------------------------
#     echo "--------$(hostname)/cluster-init-user.sh: pushing pre-init-user.sh from cluster member to cd-db-0$j"
#     lxc file push /tmp/pre-init-user.sh  cd-db-0$j/tmp/pre-init-user.sh
#     echo "--------$(hostname)/cluster-init-user.sh: pushing worker-init-user.sh from clulster member to  cd-db-0$j"
#     lxc file push /tmp/worker-init-user.sh  cd-db-0$j/tmp/worker-init-user.sh

#     # -----------------------------------------------------
#     # SET PERMISSIONS
#     # -----------------------------------------------------
#     echo "--------$(hostname)/cluster-init-user.sh: delete file pre-init-user.sh from cd-db-0$j"
#     lxc exec cd-db-0$j -- chmod 775 /tmp/pre-init-user.sh
#     lxc exec cd-db-0$j -- chown root:root /tmp/pre-init-user.sh
#     echo "--------$(hostname)/cluster-init-user.sh: delete file worker-init-user.sh from cd-db-0$j"
#     lxc exec cd-db-0$j -- chmod 775 /tmp/worker-init-user.sh
#     lxc exec cd-db-0$j -- chown root:root /tmp/pre-init-user.sh

    
#     echo "--------$(hostname)/cluster-init-user.sh: running pre-init-user.sh on cd-db-0$j"
#     lxc exec cd-db-0$j -- sh /tmp/pre-init-user.sh
#     echo "--------$(hostname)/cluster-init-user.sh: running worker-init-user.sh cd-db-0$j"
#     lxc exec cd-db-0$j -- sh /tmp/worker-init-user.sh

#     # ssh copy to app container
#     echo "--------$(hostname)/cluster-init-user.sh: ssh-copy-id to cd-db-0$j"
#     sh /tmp/ssh-copy-id.sh cd-db-0$j
#     i=$(($i + 1))
# done
# *********************************************************************************************************************************

# for i in {1..3}
count=3
i=0;
while [ "$i" -lt $count ]
do
    j=$(($i + 1))

    # -------------------------------------------------------------------------------------------------------------------------------
    # PUSH INITIAL FILES TO worker container /home/$operator/.cb/ DIRECTORY
    # -------------------------------------------------------------------------------------------------------------------------------
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