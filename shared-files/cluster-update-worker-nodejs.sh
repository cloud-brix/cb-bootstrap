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

    export CURRENT_INSTANCE="${APP_NAME}$j"

    cmdPushWorkerFilesTmp='
        source ${FX_DIR}
        fxSubHeader "${CURRENT_INSTANCE}: Move cb files from ${CLUSTER_MEMBER} to ${CURRENT_INSTANCE}/tmp/ directory"
        fxPushWorkerTmpFile "fx.sh"                 ${CURRENT_INSTANCE}
        fxPushWorkerTmpFile "pre-init-user.sh"      ${CURRENT_INSTANCE}              
        fxPushWorkerTmpFile "worker-init-user.sh"   ${CURRENT_INSTANCE}
        fxPushWorkerTmpFile "worker-update-dirs.sh" ${CURRENT_INSTANCE}
        fxPushWorkerTmpFile "installer-nodejs.sh"   ${CURRENT_INSTANCE}' 

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
        fxPushWorkerCbFile "fx.sh"            ${CURRENT_INSTANCE}' 

    cmdInstallNodejs='
        source ${FX_DIR}
        fxSubHeader "Install nvm/node.js and npm"          
        # fxExecWorkerTmpFile "installer-nodejs.sh"       ${CURRENT_INSTANCE}' 

    # clone or update files
    # cmdGit='
    #     source ${FX_DIR}
    #     fxSubHeader "get latest cd-api files from repository"
    #     fxGit "cd-api" "https://github.com/corpdesk/cd-api.git" ${CB_OPERATOR}
    #     fxGit "cd-sio" "https://github.com/corpdesk/cd-sio.git" ${CB_OPERATOR}'


    # cmdInitApp='
    #     fxSubHeader "starting cd-sio"
    #     cd /home/${CB_OPERATOR}/cd-sio/
    #     npm insall
    #     npm start
    #     fxSubHeader "starting cd-api"
    #     cd /home/${CB_OPERATOR}/cd-api/
    #     npm insall
    #     npm start' 


    # concatenate required commands
    cmdW1="$cmdPushWorkerFilesTmp;$cmdInitWorker;$cmdPushWorkerFilesCb;$cmdInstallNodejs;"
    # run commands
    bash -c "$cmdW1"

    # sudo -H -u devops bash -c '
    # echo "--------${CURRENT_INSTANCE}: changing to home"
    # cd /home/devops
    # echo "--------${CURRENT_INSTANCE}: confirm current directory:"
    # pwd
    # echo "--------${CURRENT_INSTANCE}: confirm current current user:"
    # whoami
    # echo "--------${CURRENT_INSTANCE}: confirm home directory contents:"
    # ls -la /home/devops/
    # echo "--------${CURRENT_INSTANCE}: getting the latest cd-sio"
    # if [ -d "/home/devops/cd-sio" ]
    # then
    #     cd /home/devops/cd-sio
    #     git pull
    # else
    #     cd /home/devops/
    #     git clone https://github.com/corpdesk/cd-sio.git /home/devops/cd-sio
    # fi
    
    # echo "--------getting the latest cd-api"
    # if [ -d "/home/devops/cd-api" ]
    # then
    #     cd /home/devops/cd-api
    #     git pull
    # else
    #     cd /home/devops/
    #     git clone https://github.com/corpdesk/cd-api.git /home/devops/cd-api
    # fi'

    # sudo -H -u devops bash -c '
    # export NVM_DIR="$HOME/.nvm"
    # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'

    # sudo -H -u devops bash -c '
    # cd /home/devops/cd-sio
    # npm install
    # npm start'

    # sudo -H -u devops bash -c '
    # cd /home/devops/cd-api
    # npm install
    # npm start'


    

    i=$(($i + 1))
done

