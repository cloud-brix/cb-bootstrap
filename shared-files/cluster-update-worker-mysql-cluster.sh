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
export APP_NAME="cd-db-0"

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
    export CURRENT_INSTANCE="${APP_NAME}$j"

    cmdPushWorkerFilesTmp='
        source ${FX_DIR}
        fxSubHeader "${CURRENT_INSTANCE}: Move cb files from ${CLUSTER_MEMBER} to ${CURRENT_INSTANCE}/tmp/ directory"
        fxPushWorkerTmpFile "fx.sh"                 ${CURRENT_INSTANCE}
        fxPushWorkerTmpFile "pre-init-user.sh"      ${CURRENT_INSTANCE}              
        fxPushWorkerTmpFile "worker-init-user.sh"   ${CURRENT_INSTANCE}
        fxPushWorkerTmpFile "worker-update-dirs.sh" ${CURRENT_INSTANCE}
        fxPushWorkerTmpFile "installer-mysql.sh"    ${CURRENT_INSTANCE}   
        fxPushWorkerTmpFile "p"                     ${CURRENT_INSTANCE}' 

    cmdInitWorker='
        source ${FX_DIR}
        fxSubHeader "${CURRENT_INSTANCE}:Initialize worker node"
        fxExecWorkerTmpFile "pre-init-user.sh"       ${CURRENT_INSTANCE}
        fxExecWorkerTmpFile "worker-init-user.sh"    ${CURRENT_INSTANCE}
        fxExecWorkerTmpFile "worker-update-dirs.sh"  ${CURRENT_INSTANCE}' 

    cmdPushWorkerFilesCb='
        source ${FX_DIR}
        fxSubHeader "${CURRENT_INSTANCE}: Move cb files from ${CLUSTER_MEMBER} to ${CURRENT_INSTANCE}/home/${CB_OPERATOR}/.cb/ directory"
        echo "contents of ${CURRENT_INSTANCE}/home/${CB_OPERATOR}/.cb in ${CURRENT_INSTANCE}:"
        lxc exec ${CURRENT_INSTANCE} -- ls -la /home/${CB_OPERATOR}/.cb
        fxPushWorkerCbFile "fx.sh"            ${CURRENT_INSTANCE}
        fxPushWorkerCbFile "init_cluster.js"  ${CURRENT_INSTANCE}              
        fxPushWorkerCbFile "build_cluster.js" ${CURRENT_INSTANCE}' 

    cmdInstallations='
        source ${FX_DIR}
        if [dpkg --get-selections | grep mysql]
        then
            fxSubHeader "${CURRENT_INSTANCE}: mysql already installed"
        else
            fxSubHeader "${CURRENT_INSTANCE}: Install mysql"
            fxExecWorkerTmpFile "installer-mysql.sh"     ${CURRENT_INSTANCE}
        fi
        
        # note that post installations are done on one machine only' 

    # concatenate required commands
    cmdW="$cmdPushWorkerFilesTmp;$cmdInitWorker;$cmdPushWorkerFilesCb;$cmdInstallations"
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
        # sleep 10
        # fxExecMysqlShFile "build_cluster.js" ${APP_NAME}$1
        # sleep 10' 

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