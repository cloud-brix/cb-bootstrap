#!/bin/bash

# global variables
export HOST_USER="emp-09"
export HOST_NAME="emp-09"
export CB_OPERATOR="devops"
export CLUSTER_MEMBER="routed-93"
export EXEC_FILE="host-update-cluster.sh"
export SHARED_FILES_HOST="/home/${HOST_USER}/cb-bootstrap/shared-files"
export SHARED_FILES_CLUSTER_MEMBER="/home/${CB_OPERATOR}/cb-bootstrap/shared-files"
export FX_DIR="/tmp/fx.sh"

cp ./fx.sh /tmp/fx.sh

# print header
cmdHead='
    source ${FX_DIR}
    fxHeader'

# clone or update files
cmdGit='
    source ${FX_DIR}
    fxSubHeader "Update files from Git"
    fxGit "cb-bootstrap" "https://github.com/cloud-brix/cb-bootstrap.git" ${HOST_USER}'


# push cb files to /tmp/ dir for cluster member
cmdPushClusterFilesTmp='
    source ${FX_DIR}
    fxSubHeader "Move cb files to /tmp/ directory at ${CLUSTER_MEMBER}"
    fxPushClusterTmpFile "fx.sh"                
    fxPushClusterTmpFile "worker-init-user.sh"  
    fxPushClusterTmpFile "cluster-init-user.sh" 
    fxPushClusterTmpFile "pre-init-user.sh"     
    fxPushClusterTmpFile "ssh-key.sh"           
    fxPushClusterTmpFile "ssh-copy-id.sh"       
    fxPushClusterTmpFile "p"'

# execute init-user in cluster member
cmdInitClusterUser='
    source ${FX_DIR}
    fxSubHeader "Execute cluster-init-user.sh at ${CLUSTER_MEMBER}"
    fxExecClusterTmpFile "cluster-init-user.sh"'

# push cb files to ~/.cb/ dir for cluster member
cmdPushClusterFilesCb='
    source ${FX_DIR}
    fxSubHeader "PUSH POST-INITIAL FILES TO $clusterMember/home/$operator/.cb/ DIRECTORY"
    fxPushClusterCbFile "cluster-init-user.sh"          "" 
    fxPushClusterCbFile "p"                             ""
    fxPushClusterCbFile "cluster-update-worker.sh"      ""
    fxPushClusterCbFile "cluster-update-dirs.sh"        ""
    fxPushClusterCbFile "init_cluster.js"               ""
    fxPushClusterCbFile "init_build_cluster.js"         "mysql-shell-scripts/"
    fxPushClusterCbFile "build_cluster.js"              "mysql-shell-scripts/"'

# reset permissions for operator in the cluster member   
cmdClusterMemberResetPerm='
    source ${FX_DIR}
    fxSubHeader "PUSH POST-INITIAL FILES TO $clusterMember/home/$operator/.cb/ DIRECTORY"
    fxClusterMemberResetPerm'

# do cb bootstrap the worker containers
# containers would be for specific project eg db containers for given projects
cmdExecClusterFilesCb='
    source ${FX_DIR}
    fxSubHeader "Execute ${EXEC_FILE} at ${CLUSTER_MEMBER}"
    fxExecClusterCbFile "cluster-update-worker.sh"'
    
# concatenate required commands
cmd="$cmdHead;$cmdGit;$cmdPushClusterFilesTmp;$cmdInitClusterUser;$cmdPushClusterFilesCb;$cmdClusterMemberResetPerm;$cmdExecClusterFilesCb;"
# run commands
bash -c "$cmd"

