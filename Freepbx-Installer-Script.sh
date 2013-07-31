# Installer Script to take a stock Centos 6.4 64bit to a FreePBX Distro 4.211.64-1 release.
# Once completed you can use the upgrade scripts for version track 4.211.64
# To keep your system updated.

# Copyright 2013 Schmooze Com, Inc.

# This script is not to be copied for other use.

# This script and the finished product that is installed carries NO WARRANTY and is
# used to get your FreePBX system setup and installed.  The installed product is released
# as the FreePBX Distro and is licensed under the GPLV2 and can be used by anyone
# free of charge.  Please see http://www.gnu.org/ for more information on the use of the GPL License
###########################################################################
# Set some Variable
echo "Set some Variables needed for install time"
brand=FreePBXDistro
version=4.211.64-1
###########################################################################
echo
echo "Moving to Next Step"
echo
###########################################################################
# Check to see if MySQL is installed.
echo " Check to see if MySQL is installed"
if [ `rpm -qa | grep mysql-server | wc -l` -gt 0 ]; then
	echo " MySQL appears to be installed will now check for a MySQL root password"
	echo "Test to make sure MySQL does not have a root password"
	if mysql -uroot -e'show databases' > /dev/null 2>&1; [ $? -gt 0 ]; then
		echo "The root user for MySQL has a password.  Please remove the password and re-run this script"
		exit
	else
		echo "You do not have a password for the root MySQL user.  We will now continue with the install"
	fi
else
	echo " MySQL is not installed so we will continue on with the installer"
fi
###########################################################################
echo
echo "Moving to Next Step"
echo
###########################################################################
echo " Replace repos with only FreePBX Distro since some people have added other repos which can break updates"
# Setup FreePBX Distro Repos Only
rm -rf /etc/yum.repos.d/*
/bin/cat <<'EOTT' >/etc/yum.repos.d/FreePBX.repo
# FreePBX-Base.repo
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
[base]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.freepbxdistro.org/?release=6.4&arch=$basearch&repo=os
#baseurl=http://yum.freepbxdistro.org/centos/$releasever/os/$basearch/
gpgcheck=0
enabled=1

#released updates
[updates]
name=CentOS-$releasever - Updates
mirrorlist=http://mirrorlist.freepbxdistro.org/?release=6.4&arch=$basearch&repo=updates
#baseurl=http://yum.freepbxdistro.org/centos/$releasever/updates/$basearch/
gpgcheck=0
enabled=1

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
mirrorlist=http://mirrorlist.freepbxdistro.org/?release=6.4&arch=$basearch&repo=extras
#baseurl=http://yum.freepbxdistro.org/centos/$releasever/extras/$basearch/
gpgcheck=0
enabled=1

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
mirrorlist=http://mirrorlist.freepbxdistro.org/?release=6.4&arch=$basearch&repo=centosplus
#baseurl=http://yum.freepbxdistro.org/centos/$releasever/centosplus/$basearch/
gpgcheck=0
enabled=0

#Core PBX Packages
[pbx]
name=pbx
mirrorlist=http://mirrorlist.freepbxdistro.org/?pbxver=4.211.64&release=6.4&arch=$basearch&repo=pbx
#baseurl=http://yum.freepbxdistro.org/pbx/4.211.64/$basearch/
gpgcheck=0
enabled=1

#Schmooze Commercial Packages
[schmooze-commercial]
name=schmooze-commercial
mirrorlist=  http://mirrorlist.schmoozecom.net/?release=6.4&arch=$basearch&repo=schmooze-commercial
#baseurl=http://yum.schmoozecom.net/schmooze-commercial/$release/$basearch/
gpgcheck=0
enabled=1
EOTT
###########################################################################
echo
echo "Clean Yum just to make sure we have a fresh list"
echo
yum clean all
###########################################################################
echo
echo "Moving to Next Step"
echo
###########################################################################
# Yum Install Packages
echo " yum install needed packages"

# software raid
yum -y install sgpio mdadm

# NOTE: The Kernel packages need to match what we tell Sangoma to compile Wanpipe against or we will have issues
yum -y install kernel-2.6.32-358.0.1.el6 kernel-headers-2.6.32-358.0.1.el6 kernel-devel-2.6.32-358.0.1.el6

# Vim goodies
yum -y install vim-enhanced

# Apache
yum -y install httpd

# MySQL
yum -y install mysql mysql-server mysql-libs

# PHP
yum -y install php-5.3.3 php-mysql-5.3.3 php-common-5.3.3 php-cli-5.3.3 php-ldap-5.3.3 php-gd-5.3.3 php-pdo-5.3.3 php-process-5.3.3 php-devel-5.3.3 php-pear-1.9.4 php-pear-DB-1.7.13 php-5.3-zend-guard-loader-5.5.0

# Various utilities
yum -y install dnsmasq lm_sensors gcc gcc-c++ gdb incron screen

# Network Tools
yum -y install ntp nmap openvpn

# Install Asterisk 1.8
yum -y install asterisk18-1.8.21.0 asterisk18-addons-1.8.21.0 asterisk18-addons-bluetooth-1.8.21.0 asterisk18-addons-core-1.8.21.0 asterisk18-addons-mysql-1.8.21.0 asterisk18-addons-ooh323-1.8.21.0 asterisk18-core-1.8.21.0 asterisk18-curl-1.8.21.0 asterisk18-dahdi-1.8.21.0 asterisk18-flite-1.8.21.0 asterisk18-doc-1.8.21.0 asterisk18-flite-debuginfo-1.8.21.0 asterisk18-voicemail-1.8.21.0 asterisk18-odbc-1.8.21.0

# Dahdi, libpri and other Dahdi tools
yum -y install kmod-dahdi-linux-2.6.1 dahdi-linux-kmod-debuginfo-2.6.1 dahdi-linux-2.6.1 dahdi-linux-debuginfo-2.6.1 dahdi-linux-devel-2.6.1 dahdi-tools-2.6.1 dahdi-tools-debuginfo-2.6.1 dahdi-tools-doc-2.6.1 dahdi-firmware-2.5.0.1 dahdi-firmware-hx8-2.06 dahdi-firmware-oct6114-064-1.05.01 dahdi-firmware-oct6114-128-1.05.01 dahdi-firmware-oct6114-256-1.05.01 dahdi-firmware-tc400m-MR6.12 dahdi-firmware-vpmoct032-1.12.0 dahdi-firmware-te820-1.76 dahdi-firmware-xorcom-1.0
yum -y install libpri-1.4.12 libpri-debuginfo-1.4.12 libpri-devel-1.4.12
yum -y install libtonezone-2.6.1 libtonezone-devel-2.6.1
yum -y install libresample-0.1.3
yum -y install libss7-1.0.2 libss7-devel-1.0.2 libopenr2-1.3.2
yum -y install schmooze-dahdi

# Asterisk Sounds
yum -y install asterisk-sounds-core-en-alaw-1.4.21 asterisk-sounds-core-en-ulaw-1.4.21 asterisk-sounds-core-en-gsm-1.4.21 asterisk-sounds-extra-en-alaw-1.4.9 asterisk-sounds-extra-en-ulaw-1.4.9 asterisk-sounds-extra-en-gsm-1.4.9 moh-sounds

# Flite
yum -y install flite flite-devel

# TFTP and FTP Server
yum -y install tftp-server vsftpd

# Java
yum -y install jre

# Play audio files from asterisk
yum -y install mpg123 sox esound-devel libtool-ltdl

# Remove sendmail and install postifx to handle email
yum -y install postfix mailx cyrus-sasl-plain

# fax conversion applications
yum -y install libtiff libtiff-devel ghostscript ghostscript-fonts

# SVN
yum -y install subversion

# Fail2ban RPM for Security
yum -y install fail2ban

# Install iksemel for SRTP
yum -y install iksemel

# Install spandsp for faxing
yum -y install spandsp
yum -y install spandsp-devel

# Install Mosh for MAC and Linux Users
yum -y install mosh

# Radiusclient for Asterisk CEL logging
yum -y install radiusclient-ng radiusclient-ng-devel

# fxload for xorcom USB support
yum -y install fxload

# odbc for CEL support in asterisk
yum -y install mysql-connector-odbc unixODBC

# libwat
yum -y install libwat libwat-devel libwat-debuginfo

# Tree
yum -y install tree

# JS for LumenVox
yum -y install js

#XMPP-Jabber Server
yum -y install prosody

# SRTP support for Asterisk
yum -y install libsrtp-devel libsrtp

# Sangoma Wanpipe
yum -y install wanpipe
###########################################################################
echo
echo "Moving to Next Step"
echo
###########################################################################
# Cleanup files and setup things.
echo "Cleanup files and setup things"

# COMMON THINGS BETWEEN ALL DISTROS
# ntp settings
echo "driftfile /var/lib/ntp/drift" > /etc/ntp.conf
echo "server 0.pool.ntp.org" >> /etc/ntp.conf
echo "server 1.pool.ntp.org" >> /etc/ntp.conf
echo "server 2.pool.ntp.org" >> /etc/ntp.conf
echo "server 127.127.1.0" >> /etc/ntp.conf
echo "fudge 127.127.1.0 stratum 10" >> /etc/ntp.conf

# Setup DNSMasq to ignore reqeust for DNS from outside world
sed -i 's/#listen-address=/listen-address=127.0.0.1/g' /etc/dnsmasq.conf

cp -f /etc/xinetd.d/tftp /tmp/xinetd.tftp.old
sed -e "s/\W*disable\W*yes/        disable                 = no/" /tmp/xinetd.tftp.old > /etc/xinetd.d/tftp
sed -i "s/\/var\/lib\/tftpboot/\/tftpboot/" /etc/xinetd.d/tftp

# Change which user apache runs as so freepbx can modify asterisk files
sed -i "s/^User apache$/User asterisk/" /etc/httpd/conf/httpd.conf
sed -i "s/^Group apache$/Group asterisk/" /etc/httpd/conf/httpd.conf

# The standard timeout will prevent us from downloading modules and installing them
sed -i "s/^Timeout 120$/Timeout 300/" /etc/httpd/conf/httpd.conf

# Improve the amount of memory php can use
sed -i "s/^memory_limit = 16M.*$/memory_limit = 128M/" /etc/php.ini
sed -i "s/^memory_limit = 32M.*$/memory_limit = 128M/" /etc/php.ini

# Make a bunch of processes start on boot
/sbin/chkconfig httpd on
/sbin/chkconfig mysqld on
/sbin/chkconfig ntpd on
/sbin/chkconfig dnsmasq on 
/sbin/chkconfig incrond on
/sbin/chkconfig fail2ban on
/sbin/chkconfig tftp on
/sbin/chkconfig openvpn off

# Various file ownership changes
/bin/chown -R asterisk:asterisk /var/www/html
/bin/chown -R asterisk:asterisk /var/lib/php/session

# Create rc.local
/bin/echo "# Make sure asterisk starts on boot" >> /etc/rc.local
/bin/echo "/usr/local/sbin/amportal start" >> /etc/rc.local

# write resolv.conf file
/bin/echo "nameserver 127.0.0.1" > /etc/resolv.conf.new
cat /etc/resolv.conf >> /etc/resolv.conf.new
mv -f /etc/resolv.conf.new /etc/resolv.conf 

# set up java stuff
mkdir /usr/java
ln -s /usr/java/jre1.7.0_05 /usr/java/latest

# install and  configure aastra config file
mkdir /tftpboot
/bin/chown -R asterisk:asterisk /tftpboot

# change sshd_config settings
sed -i "s/#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config

# Setup logger
# remove logger.conf so FreePBX 2.10 can symlink to it
rm -rf /etc/asterisk/logger.conf

# add voicemail.conf settings for contexts to dial from
sed -i 's/;pollmailboxes=yes/pollmailboxes=yes/g'  /etc/asterisk/vm_general.inc
sed -i 's/;pollfreq=.*/pollfreq=10/g'  /etc/asterisk/vm_general.inc

# Setup a odbc for asteriskcdrdb settings
touch /etc/odbc.ini
cat <<'EOF' >/etc/odbc.ini
[MySQL-cel]
Description=MySQL connection to 'asterisk' database
driver=MySQL
server=localhost
database=asteriskcdrdb
Port=3306
Socket=/var/lib/mysql/mysql.sock
option=3
EOF

# create sudoers settings for user asterisk
sed -i "s/Defaults\s*requiretty/#Defaults requiretty/g" /etc/sudoers

# Create Upgrade Notes Section
mkdir /var/log/pbx
mkdir /var/log/pbx/install
mkdir /var/log/pbx/upgrade
chown -R asterisk:asterisk /var/log/pbx

# fix php.ini config parameters 
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' /etc/php.ini
sed -i 's/post_max_size = .*/post_max_size = 100M/' /etc/php.ini

# run a weekly updatedb to keep locate up to date
echo -e "#"\!"/bin/bash\nupdatedb" > /etc/cron.weekly/update-locate.sh
chmod +x /etc/cron.weekly/update-locate.sh

#Set nano as default editor for crons
echo "export VISUAL=nano" >> /root/.bashrc

# set permission of file that the FreePBX dahdi needs
chown -R asterisk:asterisk /etc/modprobe.d/dahdi.conf

# Create Directory for version and license file
mkdir /etc/schmooze
chown asterisk:asterisk /etc/schmooze/

# Setup MySQL Logging   Centos 6.x Only
sed -i 's/\[mysqld\]/\[mysqld\]\ngeneral_log = 1\ngeneral_log_file = \/var\/log\/mysql\/mysql.log/g' /etc/my.cnf
mkdir -p /var/log/mysql

#copy grub splash from sourcefiles directy Centos 6.x Only
cd /boot/grub/
wget http://upgrades.freepbxdistro.org/files/grub-splash.xpm.gz

###########################################################################
echo
echo "Moving to Next Step"
echo
###########################################################################
# Install FreePBX and enable Modules.
echo "Install FreePBX and enable Modules"

# FreePBX GUI
yum -y install freepbx-2.11*

# Enable modules that in 2.11 are not being enabled from the RPM
echo "Enable modules that in 2.11 are not being enabled from the RPM"
sudo -u asterisk /var/lib/asterisk/bin/module_admin enable fw_ari
sudo -u asterisk /var/lib/asterisk/bin/module_admin enable framework
sudo -u asterisk /var/lib/asterisk/bin/module_admin disable fw_fop
sudo -u asterisk /var/lib/asterisk/bin/retrieve_conf
sudo -u asterisk /var/lib/asterisk/bin/module_admin reload

# pull in all freepbx modules and load them
echo "pull in all freepbx modules and load them"
`which amportal` chown
# Install all core modules and reload
sudo -u asterisk /var/lib/asterisk/bin/module_admin installall
sudo -u asterisk /var/lib/asterisk/bin/module_admin installall
sudo -u asterisk /var/lib/asterisk/bin/module_admin installall
sudo -u asterisk /var/lib/asterisk/bin/retrieve_conf
sudo -u asterisk /var/lib/asterisk/bin/module_admin reload
# Install Misc non Core modules and reload
sudo -u asterisk /var/lib/asterisk/bin/module_admin download sysadmin
sudo -u asterisk /var/lib/asterisk/bin/module_admin install sysadmin
sudo -u asterisk /var/lib/asterisk/bin/module_admin install sysadmin
sudo -u asterisk /var/lib/asterisk/bin/module_admin --repos extended download dahdiconfig
sudo -u asterisk /var/lib/asterisk/bin/module_admin --repos extended install dahdiconfig
sudo -u asterisk /var/lib/asterisk/bin/module_admin --repos commercial installall
sudo -u asterisk /var/lib/asterisk/bin/module_admin download motif
sudo -u asterisk /var/lib/asterisk/bin/module_admin install motif
sudo -u asterisk /var/lib/asterisk/bin/retrieve_conf
sudo -u asterisk /var/lib/asterisk/bin/module_admin reload

# Sysadmin RPM for Sysadmin Module  Moved to Firstboot or we can create the incrontab
yum -y install sysadmin-*

# Install iSymphony
yum -y install iSymphonyServer-fpbx-*
sudo -u asterisk /var/lib/asterisk/bin/retrieve_conf
sudo -u asterisk /var/lib/asterisk/bin/module_admin reload

# sed out wrong	setting	for EPM	to handle more entries.	Move to	FreePBX	RPM soon
sed -i 's/AllowOverride None/AllowOverride Options/g'  /etc/httpd/conf.d/freepbx.conf

# Pull down Asterisk Version switch script
cd /usr/local/sbin
wget http://upgrades.freepbxdistro.org/files/asterisk-version-switch
chmod +x asterisk-version-switch

# add MOTD banner on SSH login
echo "" > /etc/motd
echo "/usr/local/sbin/MOTD.py" >> /etc/profile
cd /usr/local/sbin/
wget http://upgrades.freepbxdistro.org/files/MOTD.py
chmod +x /usr/local/sbin/MOTD.py

###########################################################################
echo
echo "Moving to Next Step"
echo
###########################################################################
# set some version information
echo "$version" > /etc/schmooze/pbx-version
echo "1.0.0.0" > /etc/schmooze/pbx-failsafe
echo "$brand" > /etc/schmooze/pbx-brand

