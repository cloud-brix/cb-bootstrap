#!/bin/bash


# global variables
export HOST_USER="emp-09"
export HOST_NAME="emp-09"
export CB_OPERATOR="devops"
export CLUSTER_MEMBER="routed-93"
export EXEC_FILE="cluster-update-worker-nodejs.sh"
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
        fxPushWorkerTmpFile "installer-nodejs.sh"  ${APP_NAME}$j'

    cmdInitWorker='
        source ${FX_DIR}
        fxSubHeader "Initialize worker node"
        fxExecWorkerTmpFile "pre-init-user.sh"     ${APP_NAME}$j
        fxExecWorkerTmpFile "worker-init-user.sh"  ${APP_NAME}$j
        fxExecWorkerTmpFile "installer-nodejs.sh"  ${APP_NAME}$j'



    # clone or update files
    cmdGit='
        source ${FX_DIR}
        fxSubHeader "get latest cd-api files from repository"
        fxGit "cd-api" "https://github.com/corpdesk/cd-api.git" ${CB_OPERATOR}
        fxGit "cd-sio" "https://github.com/corpdesk/cd-sio.git" ${CB_OPERATOR}'


    cmdInitApp='
        cd /home/${CB_OPERATOR}/cd-sio/
        npm insall
        npm start
        cd /home/${CB_OPERATOR}/cd-api/
        npm insall
        npm start' 


    # concatenate required commands
    cmdW="$cmdPushWorkerFilesTmp;$cmdInitWorker;$cmdGit;$cmdInitApp"
    # run commands
    bash -c "$cmdW"

    i=$(($i + 1))
done

