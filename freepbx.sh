#!/bin/bash

# echo 'FreePBX install'
sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
systemctl restart httpd.service

pushd /usr/src
wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-15.0-latest.tgz
tar xfz freepbx-15.0-latest.tgz
rm -f freepbx-15.0-latest.tgz

pushd freepbx
./start_asterisk start
./install -n
popd

popd

mv /home/vagrant/freepbx.service /etc/systemd/system/
systemctl enable freepbx

# Fix permissions
fwconsole chown
chmod 755 /var/spool/mqueue 

# Show IP address on login screen
echo -e "\nIP address: \4{eth1}" >> /etc/issue 

# TODO: hack, why are permissions wrong?
chown -R asterisk:asterisk /var/lock
chown asterisk:asterisk /dev/ttyUSB*