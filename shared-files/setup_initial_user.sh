#!/bin/bash
# To run: sudo sh setup_initial_user.sh

# reset environment
sudo sh /tmp/reset_environment.sh
initialUser="devops"
pswd="yU0B14NC1PdE"


# INSTALL ANSIBLE SERVER REQUIREMENTS


# check if $initialUser dir exits
if [ -d "/home/$initialUser/" ] 
then
    echo "user $initialUser esists" 
    sleep 0
else
    # sudo useradd -m -s /bin/bash $initialUser
    echo "creating $initialUser user (non-inteructive, with preset hushed password):"
    # add user OPTION 1
    # hash created by:
    # python -c 'import crypt; print crypt.crypt("yU0B14NC1PdE", "$1$SomeSalt$")'
    # recommended: openssl passwd -salt SomeSalt -1 yU0B14NC1PdE
    sudo useradd -m -p \$6\$QGFip3kXOicYeuKf\$pq3AMKWm9G6/iWtu10G6ciExPjRNcGZRL5Gni6zEHg46juPx4ZSSPkBMZLAF/WBfclfDbuSi4KXGW7b4hg1pH/ -s /bin/bash $initialUser
    # add user OPTION 2
    # sudo useradd -m -p $(openssl passwd -1 $pswd) $initialUser
    # confirm user and password:
    # cat /etc/shadow | grep $initialUser
    echo "escalate the $initialUser to sudoer:"
    usermod -aG sudo $initialUser
    sudo id $initialUser
    # no password for $initialUser as a sudoer
    # OPTION 1
    # sudo echo "$initialUser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    # OPTION 2
    bash -c 'echo "devops ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
    # OPTION 3
    # touch /etc/sudoers.d/devops
    # sed '1 i devops\tALL=(ALL)\tNOPASSWD:\tALL' /etc/sudoers.d/devops
    
    
    sudo mkdir -p /home/$initialUser/.ssh
    # sudo touch /home/$initialUser/.ssh/authorized_keys
    
    # sudo ssh-keygen -t rsa -b 2048 -f /home/$initialUser/.ssh/id_rsa -q -N ""
    # sudo chown $initialUser /home/$initialUser/.ssh
    # sudo chmod -R 700 /home/$initialUser/.ssh  #this is important.
    sudo chmod -R 755 /home/$initialUser
    # sudo chmod 600 /home/$initialUser/.ssh/authorized_keys  #this is important.
    sudo mkdir /home/$initialUser/vagrant-deploy
    sudo chmod -R 755 /home/$initialUser/vagrant-deploy
    chown -R $initialUser /home/$initialUser/vagrant-deploy
    
fi


# ansible-playbook playbook03.yml
