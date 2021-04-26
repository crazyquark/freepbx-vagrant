#!/bin/bash

echo 'Building Asterisk & deps'
pushd /usr/src
wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz

echo 'DAHDI'
tar xvfz dahdi-linux-complete-current.tar.gz
tar xvfz libpri-current.tar.gz
rm -f dahdi-linux-complete-current.tar.gz libpri-current.tar.gz

pushd dahdi-linux-complete-*
make all
make install
make config
popd

pushd libpri-*
make
make install
popd

echo 'Compiling Asterisk'
tar xvfz asterisk-16-current.tar.gz
rm -f asterisk-*-current.tar.gz
pushd asterisk-*
contrib/scripts/install_prereq install
./configure --libdir=/usr/lib64 --with-pjproject-bundled --with-jansson-bundled
contrib/scripts/get_mp3_source.sh
make menuselect.makeopts
menuselect/menuselect \
    --enable app_macro \
    --enable format_mp3
make
make install WGET_EXTRA_ARGS="--no-verbose"
make config
ldconfig
chkconfig asterisk off

# Default configs
cp configs/samples/modules.conf.sample /etc/asterisk/modules.conf
cp configs/samples/logger.conf.sample /etc/asterisk/logger.conf
popd

git clone https://github.com/wdoekes/asterisk-chan-dongle.git && \
	cd asterisk-chan-dongle && \
	./bootstrap && \
	./configure --with-astversion=16 && \
	make && \
	make install

# Copy config
cp ./etc/dongle.conf /etc/asterisk/dongle.conf

# Dongle permissions
usermod -aG dialout,lock asterisk

popd # /usr/src

echo 'Setting permissions'
chown asterisk. /var/run/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib64/asterisk
chown -R asterisk. /var/www/
