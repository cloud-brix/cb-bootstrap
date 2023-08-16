#!/bin/bash

# Ref: https://gist.github.com/soubrunorocha/ec30b7704d737a1797b0281e97967834

#update and install some dependencies 
sudo apt-get update && apt-get upgrade -y;
sudo apt-get install -y debconf-utils zsh htop libaio1;

#apt congig file:
mysqlAptConfig="mysql-apt-config_0.8.26-1_all.deb"

#set the root password
DEFAULTPASS=$1

#set some config to avoid prompting
sudo debconf-set-selections <<EOF
mysql-apt-config mysql-apt-config/select-server select mysql-8.0
mysql-community-server mysql-community-server/root-pass password $DEFAULTPASS
mysql-community-server mysql-community-server/re-root-pass password $DEFAULTPASS
EOF

#get the mysql repository via wget
wget --user-agent="Mozilla" -O /tmp/$mysqlAptConfig https://dev.mysql.com/get/$mysqlAptConfig;

#set debian frontend to not prompt
export DEBIAN_FRONTEND="noninteractive";

#config the package
sudo -E dpkg -i /tmp/$mysqlAptConfig;

#update apt to get mysql repository
sudo apt-get update

#install mysql according to previous config
sudo -E apt-get install mysql-server mysql-client mysql-shell --assume-yes --force-yes

# ISSUE:
# W: --force-yes is deprecated, use one of the options starting with --allow instead.

# allow remote connection:
# backup the confif file first
# cp /etc/mysql/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak
# sed -i '/bind-address/c\bind-address = 0.0.0.0' /etc/mysql/mysql.conf.d/mysqld.cnf
# sed -i -E "s/#?bind-address = 127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

############################################################################
# set up host file
# hosts setup
cp /etc/hosts /etc/hosts.bak
sudo cat > /etc/hosts <<EOF                                                                             /etc/hosts                                                                                        
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

192.168.0.9  emp-09
192.168.0.10 emp-10
192.168.0.11 emp-11

192.168.0.90 cb.ha
192.168.0.91 routed-91
192.168.0.92 routed-92
192.168.0.93 routed-93
192.168.0.94 routed-94
192.168.0.95 routed-95
192.168.0.96 routed-96
192.168.0.97 routed-97

192.168.0.101 routed-101
192.168.0.102 routed-102
192.168.0.103 routed-103
192.168.0.104 routed-104
192.168.0.105 routed-105
192.168.0.106 routed-106
192.168.0.107 routed-107

192.168.0.111 routed-111
192.168.0.112 routed-112
192.168.0.113 routed-113
192.168.0.114 routed-114
192.168.0.115 routed-115
192.168.0.116 routed-116
192.168.0.117 routed-117

240.93.0.172  cd-db-01
240.103.0.64  cd-db-02
240.113.0.252 cd-db-03

240.103.0.121 cd-api-01

EOF



################################################################################
# # create user
# root@cd-db-01 ~# touch create-user
# root@cd-db-01 ~# nano create-user 
# File contents:
# create database db01;
# create user 'john'@'%' identified by 'yU0B14NC1PdE';
# root@cd-db-01 ~# mysql < create-user 
# root@cd-db-01 ~# mysql -u devops -p
# Enter password: 
# Welcome to the MySQL monitor.  Commands end with ; or \g.
# Your MySQL connection id is 40
# Server version: 8.0.34 MySQL Community Server - GPL

# Copyright (c) 2000, 2023, Oracle and/or its affiliates.

# Oracle is a registered trademark of Oracle Corporation and/or its
# affiliates. Other names may be trademarks of their respective
# owners.

# Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

# mysql> show databases;
# +--------------------+
# | Database           |
# +--------------------+
# | db01               |
# | information_schema |
# | mysql              |
# | performance_schema |
# | sys                |
# +--------------------+
# 5 rows in set (0.01 sec)

# mysql> SELECT user FROM mysql.user;
# +------------------+
# | user             |
# +------------------+
# | devops           |
# | john             |
# | mysql.infoschema |
# | mysql.session    |
# | mysql.sys        |
# | root             |
# +------------------+
# 6 rows in set (0.00 sec)


