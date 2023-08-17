#!/bin/bash

# global variables
export HOST_USER="emp-09"
export HOST_NAME="emp-09"
export CB_OPERATOR="devops"
export CLUSTER_MEMBER="routed-93"
export EXEC_FILE="cluster-update-workers-mf.sh"
export SHARED_FILES_HOST="/home/${HOST_USER}/cb-bootstrap/shared-files"
export SHARED_FILES_CLUSTER_MEMBER="/home/${CB_OPERATOR}/cb-bootstrap/shared-files"
export P_SECR=`cat /tmp/p`
export FX_DIR="/tmp/fx.sh"



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
# count=3
# i=0;
# while [ "$proj" -lt $count ]
for proj in cd-shell cd-user cd-moduleman cd-comm cd-pub;
do

    export CURRENT_INSTANCE="$proj-01"
    export PROJ=$proj

    cmdPushWorkerFilesTmp='
        source ${FX_DIR}
        fxSubHeader "Move cb files from ${CLUSTER_MEMBER} to $proj/tmp/ directory"
        fxPushWorkerTmpFile "fx.sh"               ${CURRENT_INSTANCE}
        fxPushWorkerTmpFile "pre-init-user.sh"    ${CURRENT_INSTANCE}            
        fxPushWorkerTmpFile "worker-init-user.sh" ${CURRENT_INSTANCE}
        fxPushWorkerTmpFile "installer-nodejs.sh"  ${CURRENT_INSTANCE}'

    cmdInitWorker='
        source ${FX_DIR}
        fxSubHeader "Initialize worker node"
        fxExecWorkerTmpFile "pre-init-user.sh"       ${CURRENT_INSTANCE}
        fxExecWorkerTmpFile "worker-init-user.sh"    ${CURRENT_INSTANCE}
        # fxExecWorkerTmpFile "installer-nodejs.sh"  ${CURRENT_INSTANCE}'

    # clone or update files
    # cmdGit='
    #     source ${FX_DIR}
    #     fxSubHeader "get latest cd-api files from repository"
    #     fxGit "$proj" "https://github.com/corpdesk/$proj.git" ${CB_OPERATOR}'


    # cmdInitApp='
    #     cd /home/${CB_OPERATOR}/$proj/
    #     npm insall
    #     npm start' 

    # -----------------------------------------------------------------------------------

    sudo -H -u devops bash -c '
    cd /home/devops/
    echo "--------installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    cd /home/devops/
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'

    sudo -H -u devops bash -c '
    echo "--------${CURRENT_INSTANCE}: changing to home"
    cd /home/devops
    echo "--------${CURRENT_INSTANCE}: confirm current directory:"
    pwd
    echo "--------${CURRENT_INSTANCE}: confirm current current user:"
    whoami
    echo "--------${CURRENT_INSTANCE}: confirm home directory contents:"
    ls -la /home/devops/
    echo "--------${CURRENT_INSTANCE}: getting the latest ${PROJ}"
    if [ -d "/home/devops/${PROJ}" ]
    then
        cd /home/devops/${PROJ}
        git pull
    else
        cd /home/devops/
        git clone https://github.com/corpdesk/${PROJ}.git /home/devops/${PROJ}
    fi'
    

    sudo -H -u devops bash -c '
    cd /home/devops/${PROJ}
    npm install --legacy-peer-deps
    npm start'

    # concatenate required commands
    cmdW="$cmdPushWorkerFilesTmp;$cmdInitWorker;"
    # run commands
    bash -c "$cmdW"

    i=$(($proj + 1))
done