#!/bin/bash

# global variables
export HOST_USER="emp-09"
export HOST_NAME="emp-09"
export CB_OPERATOR="devops"
export CLUSTER_MEMBER="routed-93"
export EXEC_FILE="cluster-update-worker-mysql-cluster.sh"
export SHARED_FILES_HOST="/home/${HOST_USER}/cb-bootstrap/shared-files"
export SHARED_FILES_CLUSTER_MEMBER="/home/${CB_OPERATOR}/cb-bootstrap/shared-files"
export P_SECR=`cat /tmp/p`
export FX_DIR="/tmp/fx.sh"
export APP_NAME="cd-api-0"

cmdHead='
    source ${FX_DIR}
    fxHeader'
bash -c "$cmdHead"
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
count=3
i=0;
while [ "$i" -lt $count ]
do
    j=$(($i + 1))

    cmdPushWorkerFilesTmp='
        source ${FX_DIR}
        fxSubHeader "Move cb files from ${CLUSTER_MEMBER} to ${APP_NAME}$j/tmp/ directory"
        fxPushWorkerTmpFile "fx.sh"               ${APP_NAME}$j
        fxPushWorkerTmpFile "pre-init-user.sh"    ${APP_NAME}$j              
        fxPushWorkerTmpFile "worker-init-user.sh" ${APP_NAME}$j
        fxPushWorkerTmpFile "installer-mysql.sh"  ${APP_NAME}$j   
        fxPushWorkerTmpFile "p"                   ${APP_NAME}$j' 

    cmdPushWorkerFilesCb='
        source ${FX_DIR}
        fxSubHeader "Move cb files from ${CLUSTER_MEMBER} to ${APP_NAME}$j/.cb/ directory"
        fxPushWorkerCbFile "fx.sh"            ${APP_NAME}$j
        fxPushWorkerCbFile "init_cluster.js"  ${APP_NAME}$j              
        fxPushWorkerCbFile "build_cluster.js" ${APP_NAME}$j' 

    cmdInitWorker='
        source ${FX_DIR}
        fxSubHeader "Initialize worker node"
        fxExecWorkerTmpFile "pre-init-user.sh"     ${APP_NAME}$j
        fxExecWorkerTmpFile "worker-init-user.sh"  ${APP_NAME}$j' 

    cmdInstallations='
        source ${FX_DIR}
        fxSubHeader "Install mysql"
        fxExecWorkerTmpFile "installer-mysql.sh"     ${APP_NAME}$j
        # note that post installations are done on one machine only' 

    # concatenate required commands
    cmdW="$cmdPushWorkerFilesTmp;$cmdPushWorkerFilesCb;$cmdInitWorker"
    # run commands
    bash -c "$cmdW"

    i=$(($i + 1))
done

# post installations:
# 1. setting up mysql cluster
cmdMysqlCluster='
        source ${FX_DIR}
        fxSubHeader "Setup mysql cluster"          
        # fxExecMysqlShFile "init_cluster.js" ${APP_NAME}1
        # fxExecMysqlShFile "build_cluster.js" ${APP_NAME}$1' 

# 2. Restore data
cmdRestoreData='
        source ${FX_DIR}
        fxSubHeader "Restore data from dump file"
        # lxc exec ${APP_NAME}$1 -- wget http://${CLUSTER_MEMBER}/cloud-brix.lab/mysql-downloads/sql-dump/Dump20220829.sql -P /home/${CB_OPERATOR}/.cb/
        # lxc exec ${APP_NAME}$1 -- mysql $dbname < /home/${CB_OPERATOR}/.cb/Dump20220829.sql -u $dbUser -p$dbPswd' 

# concatenate required commands
cmd="$cmdMysqlCluster;$cmdRestoreData"
# run commands
bash -c "$cmd"