#!/bin/bash

# use this on physical machine to update files
# USAGE:
# execute below in at any host (emp-09, emp-10, emp-11) 
# cd ~/cb-bootstrap && git pull && sh ~/cb-bootstrap/shared-files/host-update-cluster.sh

# # executing concatenated commands
# cmd1="echo xx"
# cmd2="echo yy"
# cmd="$cmd1; $cmd2"
# bash -c "$cmd"

l1Hostname="emp-09"
l1Operator="emp-09"

l1Hostname="routed-93"
l2Operator="devops"
cmdHead=""

bash -c '
# executed at the physical machine
echo "."
echo "."
echo "."
echo "--------$(hostname)/STARTING host-update-cluster.sh"
echo "--------$(hostname)/cluster-init-user.sh: whoami: $(whoami)"
echo "--------$(hostname)/host-update-cluster.sh: executing at the physical machine"
adminUser="emp-09"
operator="devops"
clusterMember="routed-93"
if [ -d "/home/$adminUser/cb-bootstrap" ] 
then
    echo "--------$(hostname)/host-update-cluster.sh: cloud-brix files for $adminUser will be updated"
    cd /home/$adminUser/cb-bootstrap
    git fetch --all
    cd /home/$adminUser/
else
    echo "--------$(hostname)/host-update-cluster.sh: updating source files for $adminUser"
    git clone https://github.com/cloud-brix/cb-bootstrap.git
fi

# -------------------------------------------------------------------------------------------------------------------------------
# DELETE INITIAL FILES FROM $clusterMember/tmp DIRECTORY
# -------------------------------------------------------------------------------------------------------------------------------
echo "--------$(hostname)/host-update-cluster.sh: remove worker-init-user.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/worker-init-user.sh

echo "--------$(hostname)/host-update-cluster.sh: remove cluster-init-user.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/cluster-init-user.sh

echo "--------$(hostname)/host-update-cluster.sh: remove shared-files/pre-init-user.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/pre-init-user.sh

echo "--------$(hostname)/host-update-cluster.sh: remove shared-files/ssh-key.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/ssh-key.sh

echo "--------$(hostname)/host-update-cluster.sh: remove shared-files/ssh-copy-id.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/ssh-copy-id.sh

echo "--------$(hostname)/host-update-cluster.sh: remove shared-files/p from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/p



# -------------------------------------------------------------------------------------------------------------------------------
# PUSH INITIAL FILES TO $clusterMember/tmp DIRECTORY
# -------------------------------------------------------------------------------------------------------------------------------
echo "--------$(hostname)/host-update-cluster.sh: pushing worker-init-user.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/worker-init-user.sh
lxc file push /home/$adminUser/cb-bootstrap/shared-files/worker-init-user.sh  $clusterMember/tmp/worker-init-user.sh

echo "--------$(hostname)/host-update-cluster.sh: pushing cluster-init-user.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/cluster-init-user.sh
lxc file push /home/$adminUser/cb-bootstrap/shared-files/cluster-init-user.sh  $clusterMember/tmp/cluster-init-user.sh

echo "--------$(hostname)/host-update-cluster.sh: pushing shared-files/pre-init-user.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/pre-init-user.sh
lxc file push /home/$adminUser/cb-bootstrap/shared-files/pre-init-user.sh  $clusterMember/tmp/pre-init-user.sh

echo "--------$(hostname)/host-update-cluster.sh: pushing shared-files/ssh-key.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/ssh-key.sh
lxc file push /home/$adminUser/cb-bootstrap/shared-files/ssh-key.sh  $clusterMember/tmp/ssh-key.sh

echo "--------$(hostname)/host-update-cluster.sh: pushing shared-files/ssh-copy-id.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/sh-copy-id.sh
lxc file push /home/$adminUser/cb-bootstrap/shared-files/ssh-copy-id.sh  $clusterMember/tmp/ssh-copy-id.sh

echo "--------$(hostname)/host-update-cluster.sh: pushing shared-files/p from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/p
lxc file push /home/$adminUser/cb-bootstrap/shared-files/p  $clusterMember/tmp/p

echo "--------$(hostname)/host-update-cluster.sh: pushing worker-init-user.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/worker-init-user.sh
lxc file push /home/$adminUser/cb-bootstrap/shared-files/worker-init-user.sh  $clusterMember/tmp/worker-init-user.sh

echo "--------$(hostname)/host-update-cluster.sh: pushing cluster-update-dirs.sh from $adminUser to $clusterMember"
lxc exec $clusterMember -- rm -f /tmp/cluster-update-dirs.sh
lxc file push /home/$adminUser/cb-bootstrap/shared-files/cluster-update-dirs.sh  $clusterMember/tmp/cluster-update-dirs.sh

lxc exec $clusterMember -- sh /tmp/cluster-init-user.sh
# -------------------------------------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------------------------
# PUSH POST-INITIAL FILES TO $clusterMember/home/$operator/.cb/ DIRECTORY
# -------------------------------------------------------------------------------------------------------------------------------
echo "--------$(hostname)/host-update-cluster.sh: pushing shared-files/cluster-init-user.sh from $adminUser to $clusterMember"
lxc file push /home/$adminUser/cb-bootstrap/shared-files/cluster-init-user.sh   $clusterMember/home/$operator/.cb/cluster-init-user.sh 
echo "--------$(hostname)/host-update-cluster.sh: pushing shared-files/p from $adminUser to $clusterMember"
lxc file push /home/$adminUser/cb-bootstrap/shared-files/p                        $clusterMember/home/$operator/.cb/p
echo "--------$(hostname)/host-update-cluster.sh: pushing shared-files/cluster-update-worker.sh from $adminUser to $clusterMember"
lxc file push /home/$adminUser/cb-bootstrap/shared-files/cluster-update-worker.sh $clusterMember/home/$operator/.cb/cluster-update-worker.sh
echo "--------$(hostname)/host-update-cluster.sh: moving cluster-update-dirs.sh to controller machine"
lxc file push /home/$adminUser/cb-bootstrap/shared-files/cluster-update-dirs.sh   $clusterMember/home/$operator/.cb/cluster-update-dirs.sh
echo "--------$(hostname)/host-update-cluster.sh: pushing init_cluster.js from $adminUser to $clusterMember"
lxc file push /home/$adminUser/cb-bootstrap/shared-files/init_cluster.js     $clusterMember/home/devops/.cb/mysql-shell-scripts/init_cluster.js
echo "--------$(hostname)/host-update-cluster.sh: pushing init_build_cluster.js from $adminUser to $clusterMember"
lxc file push /home/$adminUser/cb-bootstrap/shared-files/build_cluster.js    $clusterMember/home/devops/.cb/mysql-shell-scripts/build_cluster.js

lxc exec $clusterMember -- chown -R devops:devops /home/devops/
lxc exec $clusterMember -- chmod -R 775 /home/devops/
lxc exec $clusterMember -- sh /home/$operator/.cb/cluster-update-worker.sh
'
