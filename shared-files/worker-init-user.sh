#!/bin/bash


# global variables
export HOST_USER="emp-09"
export HOST_NAME="emp-09"
export CB_OPERATOR="devops"
export CLUSTER_MEMBER="routed-93"
export EXEC_FILE="worker-init-user.sh"
export SHARED_FILES_HOST="/home/${HOST_USER}/cb-bootstrap/shared-files"
export SHARED_FILES_CLUSTER_MEMBER="/home/${CB_OPERATOR}/cb-bootstrap/shared-files"
export P_SECR=`cat /tmp/p`

cmdHead='
    source ./fx.sh
    fxHeader'

cmdAddWorkerOperator='
    source ./fx.sh
    fxSubHeader "Add user(${CB_OPERATOR}) to worker node"
    fxAddOperator ${CB_OPERATOR} ${P_SECR}'

# concatenate required commands
cmd="$cmdHead;$cmdAddWorkerOperator"

# run commands
bash -c "$cmd"


