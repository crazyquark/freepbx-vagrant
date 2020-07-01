#!/bin/bash

# Based on https://wiki.freepbx.org/display/FOP/Installing+FreePBX+14+on+CentOS+7

echo 'Setting up CentOS'

echo 'Checking SELinux...'
echo $(sestatus)

echo 'Upgrade system'
yum -y update
yum -y groupinstall core base "Development Tools"

echo 'Adding Asterisk user'
adduser asterisk -m -c "Asterisk User"

echo 'Disable firewall'
# TODO instead of disabling, open ports TCP and UDP
systemctl stop firewalld
systemctl disable firewalld
echo 'Firewall is' $(firewall-cmd --state)

echo 'Installing deps'
yum -y install lynx tftp-server unixODBC mysql-connector-odbc mariadb-server mariadb \
  httpd ncurses-devel sendmail sendmail-cf sox newt-devel libxml2-devel libtiff-devel \
  audiofile-devel gtk2-devel subversion kernel-devel git crontabs cronie \
  cronie-anacron wget vim uuid-devel sqlite-devel net-tools gnutls-devel python-devel texinfo \
  libuuid-devel

echo 'Install PHP'
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

yum -y remove php*
yum -y install php56w php56w-pdo php56w-mysql php56w-mbstring php56w-pear php56w-process php56w-xml php56w-opcache php56w-ldap php56w-intl php56w-soap

echo 'Install NodeJS'
curl -sL https://rpm.nodesource.com/setup_10.x | bash -
yum install -y nodejs

echo 'Setup MariaDB server'
systemctl enable mariadb.service
systemctl start mariadb

# Instead of mysql_secure_installation
mysql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

echo 'Setup Apache'
systemctl enable httpd.service
systemctl start httpd.service

pear install Console_Getopt
