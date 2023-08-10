#!/bin/bash

echo "."
echo "."
echo "."
echo "--------$(hostname)/STARTING ssh-copy-id.sh"
echo "--------$(hostname)/ssh-copy-id.sh: whoami: $(whoami)"
cname=$1
echo "--------$(hostname)/ssh-copy-id.sh: ssh-copy-id for $cname"
cip=$(sudo lxc list -c4 --format csv $cname | cut -d' ' -f1)
# cip=$(sudo lxc list "a1" -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')
echo "--------$(hostname)/ssh-copy-id.sh: $cname ip address is $cip"
# export CIP=$cip
# echo "ip for $cname is $cip"
# ssh-copy-id -i /home/devops/.ssh/id_rsa.pub devops@$cip
echo "--------$(hostname)/ssh-copy-id.sh: current directory $(pwd)"
# sudo -H -u devops bash -c '

if [ -f "/home/devops/.ssh/id_rsa" ] 
then
    echo "--------ssh-copy-id: ssh keys already exists"
else
    echo "--------ssh-copy-id: creating ssh keys"
    # ssh-keygen -t rsa -b 2048 -f /home/devops/.ssh/id_rsa -q -N ""
    sh /home/devops/.cb/ssh-key.sh devops
    echo "--------ssh-copy-id: check if key exists after ssh-key.sh"
    tree /home/devops/.ssh/
fi

echo "--------$(hostname)/ssh-copy-id: whoami: $(whoami)"
echo "--------ssh-copy-id: check if key exists before ssh-copy-id"
tree /home/devops/.ssh
echo "cmd: sshpass -f /home/devops/.cb/p ssh-copy-id -i /home/devops/.ssh/id_rsa.pub devops@$cip"
sshpass -f "/tmp/p" ssh-copy-id -i /home/devops/.ssh/id_rsa.pub devops@$cip
# '


