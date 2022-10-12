#   ���� vcgencmd get_throttled # ������� 0x50000 �����, 0x50005 - �����
#	sudo vcgencmd measure_volts # ���������� ����
#   sudo vcgencmd measure_temp #�����������

��������� ���������
sudo raspi-config
	��� ������ ������� ������ ������� ���� ����� ������� ������ ������������.
	N2 ������ ������������� ������������ ����
	I1 change locale
		[*] ru_RU.UTF-8 UTF-8
	I2 Change Timezone	
	I4 Change Wi-fi Country:
qq	A1 Expand Filesystem
	P2 SSH

������������
sudo adduser rasberry
sudo visudo
	# User privilege specification
	root  ALL=(ALL:ALL) ALL
	rasberry   ALL = NOPASSWD: ALL	
	sudo userdel -r pi
	
����������� ������
sudo dpkg-reconfigure console-setup
	��������� � ���� ��� ����� ������ ����������, �������������
	������������ ��������� � �������: UTF-8
	������������ ������� ��������:
	����������� ������������ ������ �������� (��������� �����)
	���������� �����:
	Fixed ��� ��������� ������� ������� ���������� ����� (��������� �����)
	������ ������: 8x16
	Finish

����������� IP	
sudo nano/etc/dhcpcd.conf

#interface eth0
#static ip_address=192.168.1.14/24
#static routers=192.168.1.1
#static domain_name_servers=192.168.1.1
 
#interface wlan0
#static ip_address=192.168.1.14/24
#static routers=192.168.1.1
#static domain_name_servers=192.168.1.1
#########################################################################
#��������� wlan0 ��� ������� �� ���������
crontab -e
	@reboot sudo ip route del default via 192.168.0.1 dev wlan0


MQTT
sudo apt install mosquitto mosquitto-clients
sudo mosquitto_passwd -c /etc/mosquitto/passwd <user>
!!! ������ ������ ��������� ��� -c
���������:
sudo nano /etc/mosquitto/mosquitto.conf
	allow_anonymous false
	password_file /etc/mosquitto/passwd

BLYNK
sudo apt install openjdk-11-jdk-headless -y
sudo apt install openjdk-11-jdk -y
java -version
######### ��. ��������� ������ 
wget "https://github.com/blynkkk/blynk-server/releases/download/v0.41.13/server-0.41.13-java8.jar"
mkdir Blynk
java -jar server-0.41.13-java8.jar -dataFolder /home/rasberry/Blynk &
sudo nano /etc/rc.local 
	java -jar /home/rasberry/server-0.41.13-java8.jar -dataFolder /home/rasberry/Blynk &
#crontab -e
#    @reboot java -jar /home/rasberry/server-0.41.13-java8.jar -dataFolder /home/rasberry/Blynk &
#����������
#ps -aux | grep java

NAS
#cat /proc/filesystems #�������� ������������� FS
#sudo modprobe cifs #��������� �������� �������
#sudo ls /lib/modules/$(uname -r)/kernel/fs/cifs/cifs.ko #�������� ��� ������ ������� ������������� ������ ���� (uname -r)
#sudo apt reinstall raspberrypi-kernel && sudo apt reinstall raspberrypi-bootloader && sudo reboot #���������� ������ ����
#sudo apt install samba samba-common-bin smbclient cifs-utils #��������� cifs
sudo mount.cifs //192.168.0.50/Volume_1 /home/rasberry/nas_x -o user=Alex,password=marus14kaW7,vers=1.0,iocharset=utf8
sudo nano /etc/fstab
	//192.168.0.50/Volume_1 /home/rasberry/nas_x cifs rw,username=Alex,password=marus14kaW7,vers=1.0,iocharset=utf8 0 0

SAMBA
sudo apt install samba 
sudo nano /etc/samba/smb.conf
	[global]
	wins support = yes
	...
	[<�����>]
	comment = Shared OPi folder
	path = </home/opi/opi_samba>
	browseable = no
	writeable = Yes
	only guest = no
	create mask = 0777
	directory mask = 0777
	public = no
sudo smbpasswd -a <username> #���������� ������������. �� ������������� ��������� ������
sudo service smbd restart

NTP
sudo apt install ntp
sudo nano /etc/ntp.conf
	pool ru.pool.ntp.org iburst
	server ntp2.vniiftri.ru iburst prefer
	server 0.ru.pool.ntp.org
	server 1.ru.pool.ntp.org
	server 2.ru.pool.ntp.org
	server 3.ru.pool.ntp.org
	...
	restrict 192.168.0.0 mask 255.255.255.0
	broadcast 192.168.0.255
	broadcast 224.0.1.1
sudo systemctl restart ntp

MINIDLNA
sudo apt install minidlna
sudo nano /etc/minidlna.conf
	<#>media_dir=</media/DataY/Torrents>
	<#>db_dir=...
	<#>log_dir=...
	port=8200
	<#>friendly_name=OrangePi
	<#>inotify=yes
	<#>notify_interval=20
ip link set eth1 multicast on
ip link set lo multicast on
sudo service minidlna restart

VPNKI
sudo apt-get install -y pptp-linux #��������� ����� pptp-linux
sudo pptpsetup --create vpnki --server msk.vpnki.ru --username <��� �������> --password <������ �������> # �������� ��������� #��������� �������
sudo pon vpnki updetach
ifconfig -s #�������� ��� �������� ��������� ppp0
ping 172.16.0.1 # �������� ���� ������ VPNKI
sudo poff vpnki # �������� �������
ifconfig -s # �������� ���������� ppp0
sudo nano -B /etc/rc.local # ������� ������������ PPTP ������� ��� �������� ����������, ��������� ����
	# � ����� "exit 0" ��������� ���� �����
	# vpn="on"
	# if [ $vpn = on ]; then
	# printf "\nVPN connection to VPNKI\n"
	pon vpnki updetach & 
	sleep 5
	sudo route add -net "172.16.0.0/16" dev "ppp0" & #������� � ���� VPNKI
	# sudo route add -net "192.168.100.0/24" dev "ppp0" #�������� ������� � "�������" ������ ������� (� �������� ���� 192.168.100.0/24)
	# printf "Netstat output of all PPTP sockets\n"
	# netstat -a | grep "/var/run/pptp/"
	# fi
sudo /etc/rc.local # ��������� ������ local.rc ��� ������������
sudo systemctl status rc-local # ��������� ������ local.rc ��� ������������
sudo systemctl restart rc-local 
sudo journalctl -u rc-local
sudo nano -B /etc/ppp/peers/vpnki # � ������ ������ ����� ��� ����������� �������������� ������������� ����������, ��� ����� �������� ����
	# � ����� ����� ��������
	persist 
	maxfail 0 
	holdoff 10
sudo nano -B /etc/ppp/ip-up.d/routeadd # � ������ ������ ����� � �� �������������� ��� ����� ����������� ������������� ��������� �������� � ���� VPNKI � � ����� "������" ����. ��� ����� �������� ����
	#!/bin/sh -e
	route add -net "172.16.0.0/16" dev "ppp0" #������� � ���� VPNKI
	# route add -net "192.168.100.0/24" dev "ppp0" #�������� ������� � ����� "������" ���� 192.168.100.0/24 (���� ����� ���������� ����� ���� VPNKI)
sudo chmod 755 /etc/ppp/ip-up.d/routeadd # �������� ����� �� ���������� ����� ��� �������� ���������� ppp0

RTL_433
cd /usr/src
sudo apt install git git-core cmake libusb-1.0-0-dev
sudo git clone git://git.osmocom.org/rtl-sdr.git
cd rtl-sdr/ && sudo mkdir build && cd build/
sudo cmake ../ -DINSTALL_UDEV_RULES=ON
sudo make
sudo make install
sudo ldconfig
cd ../..
sudo cp ./rtl-sdr/rtl-sdr.rules /etc/udev/rules.d/
sudo reboot	
sudo nano /etc/modprobe.d/no-rtl.conf
	blacklist dvb_usb_rtl28xxu
	blacklist rtl2832
	blacklist rtl2830
sudo reboot
rtl_test -t
#���� �� ����������� ������
#lsusb
# �������� ���� Bus 005 Device 003: ID 0bda:2838 Realtek Semiconductor Corp. RTL2838 DVB-T
#sudo nano /etc/udev/rules.d/rtl-sdr.rules
#	SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE:="0666"
#sudo service udev restart
#sudo reboot
sudo apt-get install libtool libusb-1.0.0-dev librtlsdr-dev
cd /usr/src
sudo git clone https://github.com/merbanan/rtl_433.git
cd rtl_433/ && sudo mkdir build && cd build && sudo cmake ../ && sudo make
sudo make install
cd /usr/local/etc/rtl_433
sudo cp rtl_433.exmple.conf rtl_433.conf
sudo nano rtl_433.conf
	decoder n=PIR815K,m=OOK_PWM,s=352,l=1116,r=1180,g=0,t=200,bits=25,get=@0:{25}:id #��������� ��������� �� PIR815K
crontab -e 
	@reboot sudo rtl_433 -f 433920000 -s 250000 -F json |  mosquitto_pub -u bogdan -P marus14kaMQT9 -t rtl_433 -l&

ZIGBEE2MQTT
lsusb #���������, ��� ���� � �����������
ls -l /dev/serial/by-id #���������, ��� /dev/ttyACM0 
sudo usermod -a -G dialout <user> #���� ����� �� ���� (�� ������ ���������)
#sudo usermod -a -G tty <user> #�������� � � ��� ������ �������� ��������
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - #����������	�����������, � ������� ���� �� ������
sudo apt install -y nodejs
nodejs -v #��������� ������ ������ ���� 12.xxx
sudo apt install -y npm
sudo npm install -g npm@latest #��������� �� ��������� ������
npm -version #������ ���� ������ 6.5.0
sudo git clone https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt
sudo chown -R <user>:<user> /opt/zigbee2mqtt
cd /opt/zigbee2mqtt
npm install #����� ���� ��������������, ������������. ����������� ������ added <383> packages in <111.613>
#� opt/zigbee2mqtt/data/ ����������� configuration.yaml � ��� 2
npm start
sudo nano /etc/systemd/system/zigbee2mqtt.service #������������� ��� ������
	[Unit]
	Description=zigbee2mqtt
	After=network.target

	[Service]
	ExecStart=/usr/bin/npm start
	WorkingDirectory=/opt/zigbee2mqtt
	StandardOutput=inherit
	StandardError=inherit
	Restart=always
	User=<pi>

	[Install]
	WantedBy=multi-user.target
sudo systemctl start zigbee2mqtt
sudo systemctl enable zigbee2mqtt.service
#git checkout 00ebd44 # ����� �� ������ 1.3.0
#rm -rf node_modules
#npm install

MAJORDOMO
https://kb.mjdm.ru/kak-ustanovit-majordomo-na-linux/
#mysql 
sudo apt install mariadb-server mariadb-client -y
sudo mysql_secure_installation #� �������� �� ���� �����. � � ���� ����� ������� ������ ������������ root.
sudo mysql -uroot -p -e "CREATE DATABASE db_terminal;"
sudo mysql -uroot -p -e "CREATE USER 'majordomo'@'%' IDENTIFIED BY '<passw>';"
sudo mysql -uroot -p -e "GRANT ALL PRIVILEGES ON *.* TO 'majordomo'@'%';"
sudo mysql -uroot -p -e "FLUSH PRIVILEGES;"
#apache2
sudo apt-get install apache2 apache2-utils -y
sudo nano /etc/apache2/sites-available/000-default.conf
  #<VirtualHost *:80>
  #  DocumentRoot /var/www/html
  # ����� ����� ���������� ���������, ��� ���� 
  <Directory />
    Options FollowSymLinks
    AllowOverride All
  </Directory>
  <Directory /var/www/html>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    allow from all
  </Directory>
 
  ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
  <Directory "/usr/lib/cgi-bin">
    AllowOverride None
    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
    Order allow,deny
    Allow from all
  </Directory>
sudo rm -f /var/www/html/index.html
sudo nano /etc/apache2/apache2.conf
		ServerName localhost
sudo apache2ctl restart		
#PHP
sudo apt install php php-cgi php-cli php-pear php-mysql php-mbstring php-xml -y	
sudo apt install curl libcurl4 libcurl3-dev php-curl -y
sudo apt autoremove
sudo apt install libapache2-mod-php -y
sudo nano /etc/php/7.3/apache2/php.ini
	;short_open_tag = On	
	short_open_tag = Off
sudo apt install phpmyadmin -y #��� ��������� �������� ��������� ����� apache2, ����� ����� dbconfig-common, ������ �� MySQL
sudo a2enmod rewrite
sudo apache2ctl restart
sudo nano /etc/php/7.3/apache2/php.ini
	error_reporting  =  E_ALL & ~E_NOTICE ; ��������
	max_execution_time  = 90 ; � 30 ������ �� 90
	max_input_time = 180 ; � 60 �� 180
	post_max_size = 200M ; � 8M �� 200M
	upload_max_filesize = 50M ; � 2M �� 50M
	max_file_uploads = 150 ; � 20 �� 150
sudo nano /etc/php/7.3/cli/php.ini
	# ������ ����, ��� � � ����� ����
sudo /etc/init.d/apache2 restart
#MAJORDOMO
mkdir ~/majordomo && cd ~/majordomo && wget https://github.com/sergejey/majordomo/archive/master.zip
unzip master.zip && sudo cp -rp ~/majordomo/majordomo-master/* /var/www/html && sudo cp -rp ~/majordomo/majordomo-master/.htaccess /var/www/html && rm -rf ~/majordomo
sudo find /var/www/html/ -type f -exec chmod 0644 {} \;
sudo find /var/www/html/ -type d -exec chmod 0755 {} \;
ls -lh /var/www/html # ��������� ����� ����� ����� ��������� ������� drwxr-xr-x (����������), -rw-r--r-- (�����)
sudo chown -R www-data:www-data /var/www/html
ls -lh /var/www/html # ��������� ������������ ����� ������ ���� ��������: -rw-r--r--  1 www-data www-data  12K May 26 22:19 cycle.php
sudo usermod -a -G audio www-data
cat /etc/group | grep audio # ��������� ������������ � ������  ����� ����� �������� audio:x:29:www-data
#������� �� ������: http://192.168.0.x/phpmyadmin � majordomo, � ������ ������� ������� ��� ����� � SQL
#��������� ����-������ https://raw.githubusercontent.com/sergejey/majordomo/master/db_terminal.sql 
#����������� db_terminal �� ���� (������ ������� ��������, ��������� 171 ��������. (db_terminal.sql))
sudo cp /var/www/html/config.php.sample /var/www/html/config.php
sudo chown www-data:www-data /var/www/html/config.php
sudo nano /var/www/html/config.php
	Define('DB_USER', 'majordomo');
	Define('DB_PASSWORD', 'xxxxxxxxxxxxx');
sudo nano /etc/systemd/system/majordomo.service	
	[Unit]
	Description=Majordomo cycles service
	Requires=network.target mysql.service apache2.service
	After=mysql.service apache2.service

	[Service]
	Type=simple
	User=www-data
	Group=www-data
	ExecStart=/usr/bin/php /var/www/html/cycle.php
	ExecStop=/usr/bin/pkill -f cycle_*

	KillSignal=SIGKILL
	KillMode=control-group
	RestartSec=1min
	Restart=on-failure

	[Install]
	WantedBy=multi-user.target
sudo systemctl enable majordomo
sudo systemctl start majordomo