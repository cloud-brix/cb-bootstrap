#!/bin/bash

initialUser=$1
sudo ssh-keygen -t rsa -b 2048 -f /home/$initialUser/.ssh/id_rsa -q -N ""
sudo chown $initialUser /home/$initialUser/.ssh
sudo chmod -R 700 /home/$initialUser/.ssh  #this is important.