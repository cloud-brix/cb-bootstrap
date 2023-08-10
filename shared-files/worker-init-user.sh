#!/bin/bash


echo "."
echo "."
echo "."
echo "--------$(hostname)/STARTING worker-init-user.sh"
echo "--------$(hostname)/cluster-init-user.sh: whoami: $(whoami)"
if [ -d "/home/devops/" ] 
then
    echo "--------$(hostname)/worker-init-user.sh: /home/devops/ dir exists"
else
    sudo deluser devops
    sudo rm -r -f /home/devops
    # add devops user
    sudo useradd -m -p $(openssl passwd -1 yU0B14NC1PdE) devops
fi

if [ -d "/home/devops/.cb/mysql-shell-scripts/" ] 
then
    echo "--------$(hostname)/worker-init-user.sh: /home/devops/.cb/mysql-shell-scripts/ dir exists"
else
    echo "--------$(hostname)/worker-init-user.sh: creating new .cb/mysql-shell-scriptsdir"
    mkdir -p /home/devops/.cb/mysql-shell-scripts/
fi

chmod -R 755 /home/devops/
# escalate devops to sudoer
usermod -aG sudo devops
cp /etc/sudoers /etc/sudoers.backup
# suppress password prompt on switch to user
bash -c 'echo "devops ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
# enable password authentication for ssh connection
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sed -i -E 's/#?PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

