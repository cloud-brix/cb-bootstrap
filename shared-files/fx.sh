#!/bin/bash

# execF: executing file
# used for tracking/debugging execution
fxHeader (){
    echo "."
    echo "."
    echo "."
    echo "# ******************************************************************************************************************************"
    echo "--------STARTING ${EXEC_FILE}"
    echo "--------$(hostname)/${EXEC_FILE}: whoami: $(whoami)"
    echo "# ******************************************************************************************************************************"
    echo ""
}

# t: the subheader
fxSubHeader (){
    t=$1
    echo ""
    echo "# ---------------------------------------------------------------------"
    echo "# ------$t"
    echo "# ---------------------------------------------------------------------"
    echo ""
}

fxGit(){
    projName=$1
    gitUrl=$2
    if [ -d "/home/${HOST_USER}/$projName" ] 
    then
        echo "--------$(hostname)/${EXEC_FILE}: cloud-brix files for ${HOST_USER}  will be updated"
        cd /home/${HOST_USER}/$projName
        git pull
        cd /home/emp-06/
    else
        echo "--------$(hostname)/${EXEC_FILE}: cloing $gitUrl"
        cd /home/${HOST_USER}
        git clone $gitUrl
    fi
}


# Executing from L1(physical machine), execute lxc at L2 (cluster member) to rermove
# temporary file /tmp/ file. 
# This can be used during clean up or
# while rerunning the bootstrap for cb. Else you are likely to run into Forbbiden Error
# when new file tries to overwrite the file from remote machine.
# subjectF=subject file
# # clusterMember=cluster member where lxc commands are run
# Example:
# echo "--------$(hostname)/host-update-cluster.sh: remove worker-init-user.sh from $adminUser"
# lxc exec ${CLUSTER_MEMBER} -- rm -f /tmp/worker-init-user.sh
fxRmClusterMemberTmpFile(){
    subjectF=$1
    echo "--------$(hostname)/${EXEC_FILE}: remove $subjectF from ${CLUSTER_MEMBER}"
    lxc exec ${CLUSTER_MEMBER} -- rm -f /tmp/$subjectF
}


# subjectF=subject file
# src=source directory
# Example:
# echo "--------$(hostname)/host-update-cluster.sh: pushing worker-init-user.sh from $adminUser to ${CLUSTER_MEMBER}"
# lxc exec ${CLUSTER_MEMBER} -- rm -f /tmp/worker-init-user.sh
# lxc file push /home/$adminUser/cb-bootstrap/shared-files/worker-init-user.sh  ${CLUSTER_MEMBER}/tmp/worker-init-user.sh
fxPushClusterTmpFile(){
    subjectF=$1
    echo "--------$(hostname)/${EXEC_FILE}: pushing $subjectF from ${HOST_NAME} to ${CLUSTER_MEMBER}"
    lxc exec ${CLUSTER_MEMBER} -- rm -f /tmp/$subjectF
    lxc file push ${SHARED_FILES_HOST}/$subjectF  ${CLUSTER_MEMBER}/tmp/$subjectF
}

# subjectF=subject file
# src=source directory
# Example:
# echo "--------$(hostname)/host-update-cluster.sh: pushing worker-init-user.sh from $adminUser to ${CLUSTER_MEMBER}"
# lxc exec ${CLUSTER_MEMBER} -- rm -f /tmp/worker-init-user.sh
# lxc file push /home/$adminUser/cb-bootstrap/shared-files/worker-init-user.sh  ${CLUSTER_MEMBER}/tmp/worker-init-user.sh
fxPushClusterCbFile(){
    subjectF=$1
    cbDir=$2
    echo "--------$(hostname)/${EXEC_FILE}: pushing $subjectF from ${HOST_NAME} to ${CLUSTER_MEMBER}/~/.cb"
    lxc exec ${CLUSTER_MEMBER} -- rm -f /home/${CB_OPERATOR}/.cb/$subjectF
    lxc file push ${SHARED_FILES_HOST}/$subjectF  ${CLUSTER_MEMBER}/home/${CB_OPERATOR}/.cb/$cbDir$subjectF
}


# subjectF=subject file
# # clusterMember=cluster member
# Example:
# lxc exec ${CLUSTER_MEMBER} -- sh /tmp/cluster-init-user.sh
fxExecClusterTmpFile(){
    subjectF=$1
    echo "--------$(hostname)/${EXEC_FILE}: exectuting $subjectF at ${CLUSTER_MEMBER}"
    lxc exec ${CLUSTER_MEMBER} -- sh /tmp/$subjectF
}

# subjectF=subject file
# # clusterMember=cluster member
# Example:
# lxc exec ${CLUSTER_MEMBER} -- sh /tmp/cluster-init-user.sh
fxExecClusterCbFile(){
    subjectF=$1
    echo "--------$(hostname)/${EXEC_FILE}: exectuting $subjectF at ${CLUSTER_MEMBER}"
    lxc exec ${CLUSTER_MEMBER} -- sh /home/${CB_OPERATOR}/.cb/$subjectF
}


# Example:
# lxc exec ${CLUSTER_MEMBER} -- chown -R ${CB_OPERATOR}:${CB_OPERATOR} /home/${CB_OPERATOR}/
# lxc exec ${CLUSTER_MEMBER} -- chmod -R 775 /home/${CB_OPERATOR}/
fxClusterMemberResetPerm(){
    echo "--------$(hostname)/${EXEC_FILE}: Reset cluster member permissions"
    lxc exec ${CLUSTER_MEMBER} -- chown -R ${CB_OPERATOR}:${CB_OPERATOR} /home/${CB_OPERATOR}/
    lxc exec ${CLUSTER_MEMBER} -- chmod -R 775 /home/${CB_OPERATOR}/
}