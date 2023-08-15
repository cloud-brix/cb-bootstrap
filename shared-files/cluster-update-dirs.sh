#!/bin/bash

export HOST_USER="emp-09"
export HOST_NAME="emp-09"
export CB_OPERATOR="devops"
export CLUSTER_MEMBER="routed-93"
export EXEC_FILE="cluster-update-dirs.sh"
export SHARED_FILES_HOST="/home/${HOST_USER}/cb-bootstrap/shared-files"
export SHARED_FILES_CLUSTER_MEMBER="/home/${CB_OPERATOR}/cb-bootstrap/shared-files"
export P_SECR=`cat /tmp/p`
export FX_DIR="/tmp/fx.sh"

cmdHead='
    source ${FX_DIR}
    fxHeader'

# clone or update files
cmdGit='
    source ${FX_DIR}
    fxSubHeader "Update files from Git"
    fxGit "cb-bootstrap" "https://github.com/cloud-brix/cb-bootstrap.git" ${CLUSTER_MEMBER}'

cmdMkCbDir='
    source ${FX_DIR}
    fxSubHeader "Create .cb directory at ${CLUSTER_MEMBER}"
    fxMkDir /home/devops/.cb'

# concatenate required commands
cmd="$cmdHead;$cmdGit;$cmdMkCbDir"

# run commands
bash -c "$cmd"
