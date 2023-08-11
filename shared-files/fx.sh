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
    user=$3
    if [ -d "/home/$user/$projName" ] 
    then
        echo "--------$(hostname)/${EXEC_FILE}: cloud-brix files for $user  will be updated"
        cd /home/$user/$projName
        git pull
        cd /home/$user/
    else
        echo "--------$(hostname)/${EXEC_FILE}: cloing $gitUrl"
        cd /home/$user
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

# add user
# Example:
# if [ -d "/home/devops/" ] 
# then
#     echo "--------$(hostname)/worker-init-user.sh: /home/devops/ dir exists"
# else
    # sudo deluser devops
    # sudo rm -r -f /home/devops
    # # add devops user
    # sudo useradd -m -p $(openssl passwd -1 yU0B14NC1PdE) devops
# fi
fxAddOperator(){
    user=$1
    p=$2
    if [ -d "/home/$user" ] 
    then
        echo "--------$(hostname)/${EXEC_FILE}: /home/$user/ dir exists"
    else
        sudo deluser $user
        sudo rm -r -f /home/$user
        # add devops user
        sudo useradd -m -p $(openssl passwd -1 $p) $user
        chmod -R 755 /home/$user/
        # escalate devops to sudoer
        usermod -aG sudo $user
        cp /etc/sudoers /etc/sudoers.backup
        # suppress password prompt on switch to user
        bash -c 'echo "devops ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
        # enable password authentication for ssh connection
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
        sed -i -E 's/#?PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
        systemctl restart ssh
    fi
}

fxSshKey(){
    if [ -f "/home/${CB_OPERATOR}/.ssh/id_rsa" ] 
    then
        echo "--------ssh keys already exists"
    else
        echo "--------creating ssh keys"
        sh /tmp/ssh-key.sh ${CB_OPERATOR}
    fi
}

#create directory
# Example:
# if [ -d "/home/devops/.cb/mysql-shell-scripts/" ] 
# then
#     echo "--------$(hostname)/worker-init-user.sh: /home/devops/.cb/mysql-shell-scripts/ dir exists"
# else
#     echo "--------$(hostname)/worker-init-user.sh: creating new .cb/mysql-shell-scriptsdir"
#     mkdir -p /home/devops/.cb/mysql-shell-scripts/
# fi
fxMkDir(){
    path=$1
    if [ -d "$path" ] 
    then
        echo "--------$(hostname)/${EXEC_FILE}: $path dir exists"
    else
        echo "--------$(hostname)/${EXEC_FILE}: creating $path directory"
        mkdir -p $path
    fi
}



# -------------------------------------------------------------------------------------------------------
# MYSQL CLUSTER SETUP
# -------------------------------------------------------------------------------------------------------

fxInstalMysql(){
    # confirm operator is aleady setup
    # do unattended mysql installation
    # do unattended mysql-shell installation
    echo ""
}

fxCreateMysqlCluster(){
    # set mysql directories
    fxMkDir /home/${CB_OPERATOR}/.cb/mysql-shell-scripts/
    # install cluster initialization scripts
    fxExecClusterCbFile "init_cluster.js"
    fxExecClusterCbFile "build_cluster.js"
}

fxRestoreMysqlData(){
    echo ""
}

fxMysqlStatus(){
    echo ""
}

# -------------------------------------------------------------------------------------------------------
# CORPDESK NODE.JS SETUP
# -------------------------------------------------------------------------------------------------------

fxInstalNodejs(){
    # confirm operator is aleady setup
    # set mysql directories
    # do unattended mysql installation
    # do unattended mysql-shell installation
    echo ""
}

fxCreateNodejsCluster(){
    echo ""
}

fxInstallNodejsApp(){
    echo ""
}

fxNodejsStatus(){
    echo ""
}

# -------------------------------------------------------------------------------------------------------
# CORPDESK MODULE FEDERATION SETUP
# -------------------------------------------------------------------------------------------------------
fxInstalCdMF(){
    # confirm operator is aleady setup
    # set mysql directories
    # do unattended mysql installation
    # do unattended mysql-shell installation
    echo ""
}

fxCreateCdApp(){
    echo ""
}

fxCdStatus(){
    echo ""
}