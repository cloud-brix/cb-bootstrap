#!/bin/bash

# git clone https://github.com/georemo/cb-bootstrap.git
# update execution codes
# git pull https://georemo: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@github.com/georemo/cb-bootstrap.git
# git pull https://username:password@git_hostname.com/my/repository
sudo apt update
sudo apt upgrade -y
sudo snap refresh
sudo sh /tmp/remove_devops.sh


# Reset: remove previous versions
# sudo rm /var/nfs/share/ansibleServer.pub
# sudo rm /home/ubuntu/.ssh/ansibleServer.pub
# sudo rm /root/.ssh/ansibleServer.pub

# Disable Password Authentication before applying ssh-copy-id  
# The #? is an extended regular expression that matches the line whether it's commented or not. 
# The -E switch enables extended regexp support for sed.
# sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# sudo apt update -y
echo "---install git -------------------------------------------------------------------------------------------------------"
sudo apt-get install git  -y
echo "---install net-tools--------------------------------------------------------------------------------------------------"
sudo apt-get install net-tools -y
echo "---install telnet-----------------------------------------------------------------------------------------------------"
sudo apt-get install telnet -y
echo "---install openssh-server---------------------------------------------------------------------------------------------"
sudo apt-get install openssh-server -y
echo "---install sshpass----------------------------------------------------------------------------------------------------"
sudo apt-get install sshpass -y
echo "---install tree-------------------------------------------------------------------------------------------------------"
sudo snap install tree -y
echo "---install fish-------------------------------------------------------------------------------------------------------"
sudo apt-get install fish -y
echo "---install jq---------------------------------------------------------------------------------------------------------"
sudo apt-get install jq -y
echo "---install traceroute-------------------------------------------------------------------------------------------------"
sudo apt-get install traceroute -y
# sudo snap install lxd --channel=latest/stable
# sudo snap refresh lxd --channel=latest/stable
sudo service ssh restart
# allow ssh
sudo ufw allow from 192.168.0.0/24 to any port 22
# allow rsync
sudo ufw allow from 192.168.0.0/24 to any port 873
# allow lxd connection
sudo ufw allow from 192.168.0.0/24 to any port 8443
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo sed -i -E 's/#?PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i -E 's/#?ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i -E 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i -E 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart ssh





