#!/bin/bash

###
#
# Scriptname: Basic Webserver Configuration
# Services to install:  apache2, php, mariadb, phpmyadmin
# Actions: Install and configure MySQL Mariadb, phpmyadmin
# Year: 2020
# Author: Benson Njunge
# ScriptVersion: 0.0.1
#
###

# update system
read -p "Update this system [y/n] " update
if [[ $update =~ ^[Yy]$ ]]
	then
		sudo apt-get update -y
		read -p "Upgrade this system [y/n] " upgrade
		if [[ $upgrade =~ ^[Yy]$ ]]
		then 
			sudo apt-get upgrade -y
		fi
fi 

# Install modules
read -p "Install wget, curl, git, zip, unzip [y/n] " modul
if [[ $modul =~ ^[Yy]$ ]]
	then
		sudo apt-get install -y wget curl git zip unzip
fi

echo ""
sleep 3
# install mariadb
echo -n ">>>>> Installing mysql <<<<<"

sudo apt-get install -y php-mysql mariadb-server mariadb-client

sleep 3
echo ""
echo -n ">>>>> Configure MySQL <<<<<"
echo ""
echo "You are about to configure MySQL Database, please answer the following questions inorder to proceed"
sleep 3

sudo apt-get install -y php-mysql mariadb-server mariadb-client
sudo mysql_secure_installation

# Make Maria connectable from outside world without SSH tunnel
echo ''
read -p "Enable remote access this MariaDB [y/n] " remotemysql
if [[ $remotemysql =~ ^[Yy]$ ]]
then
    if [ -z $1 ]
    then
        echo ''
        read -sp "Confirm MySQL root password : " pswd
    else
        pswd=$1
    fi
    if [ -z $pswd ]
    then
        echo "Password is required!"
		exit 1
	else
    	# enable remote access
    	sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

    	# adding grant privileges to mysql root user from everywhere
    	MYSQL='mysql'
        Q1="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$pswd' WITH GRANT OPTION;"
        Q2="FLUSH PRIVILEGES;"
        Q3="UPDATE mysql.user SET plugin='' WHERE user='root';"
        Q4="FLUSH PRIVILEGES;"
        SQL="${Q1}${Q2}${Q3}${Q4}"

    	$MYSQL -uroot -p$pswd -e "$SQL"
		# Restart MySQL
    	sudo service mysql restart
    fi
fi

# install apache webserver
echo -n ">>>>> Installing apache webserver >>>"

sudo apt-get install -y apache2 php php-curl php-mbstring php-xml php-gd php-dev php-pear php-ssh2 libmcrypt-dev
echo -n ">>>> PHP successfully installed <<<<"
echo ""
sleep 2
# install phpmyadmin
echo -n ">>>>> Installing phpmyadmin <<<<<<"
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl

sleep 3
echo -n ">>>>> Installation complete <<<<<<"



