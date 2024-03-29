## Общее
`sudo vcgencmd measure_volts` # напряжение ядра <br />
`sudo vcgencmd measure_temp` #температура <br />
`sudo nano /boot/config.txt` #Configure a GPIO pin to control a cooling fan.<br />
> Load:   dtoverlay=gpio-fan,<param>=<val><br />
> Params: gpiopin                 GPIO used to control the fan (default 12)<br />
>        temp                    Temperature at which the fan switches on, in<br />
>                                millicelcius (default 55000)<br />
>        hyst                    Temperature delta (in millicelcius) below<br />
>                                temp at which the fan will drop to minrpm<br />
>                                (default 10000)<br />
><br />
>dtoverlay=gpio-fan,temp=65000 <br />

## НАЧАЛЬНЫЕ НАСТРОЙКИ
```
sudo raspi-config
	При помощи первого пункта данного окна можно сменить пароль пользователя.
	N2 вводим идентификатор беспроводной сети
	I1 change locale
		[*] ru_RU.UTF-8 UTF-8
	I2 Change Timezone	
	I4 Change Wi-fi Country:
qq	A1 Expand Filesystem
	P2 SSH
```
	
## ИСПРАВЛЕНИЕ ЛОКАЛИ
```
sudo dpkg-reconfigure console-setup
	Управлять в меню вам будут мешать «квадраты», устанавливаем
	Используемая кодировка в консоли: UTF-8
	Используемая таблица символов:
	Определение оптимального набора символов (последний пункт)
	Консольный шрифт:
	Fixed или Позволить системе выбрать подходящий шрифт (последний пункт)
	Размер шрифта: 8x16
	Finish
```

### отключить wlan0 для трафика по умолчанию
```
crontab -e
```
>	@reboot sudo ip route del default via 192.168.0.1 dev wlan0

## MQTT
```
sudo apt install mosquitto mosquitto-clients
sudo mosquitto_passwd -c /etc/mosquitto/passwd <user>
#!!! других юзеров добавлять без -c
```
прописать:
```
sudo nano /etc/mosquitto/mosquitto.conf
```
>	allow_anonymous false <br />
>	password_file /etc/mosquitto/passwd


## BLYNK
```
sudo apt install openjdk-11-jdk-headless -y
sudo apt install openjdk-11-jdk -y
java -version #см. последнюю версию 
wget "https://github.com/blynkkk/blynk-server/releases/download/v0.41.13/server-0.41.13-java8.jar"
wget "https://github.com/Peterkn2001/blynk-server/releases/download/v0.41.17/server-0.41.17.jar"
mkdir Blynk
java -jar server-0.41.17.jar -dataFolder /home/bogdan/Blynk &
sudo nano /etc/rc.local 
```
> java -jar /home/bogdan/Blynk/server-0.41.17.jar -dataFolder /home/bogdan/Blynk &

```
crontab -e
```
> @reboot java -jar /home/bogdan/Blynk/server-0.41.17.jar -dataFolder /home/bogdan/Blynk &

## NAS
```
cat /proc/filesystems #проверка установленных FS
sudo modprobe cifs #установка файловой системы
sudo ls /lib/modules/$(uname -r)/kernel/fs/cifs/cifs.ko #проверка что версия системы соответствует версии ядра (uname -r)
sudo apt reinstall raspberrypi-kernel && sudo apt reinstall raspberrypi-bootloader && sudo reboot #обновление версии ядра
sudo apt install samba samba-common-bin smbclient cifs-utils #установка cifs
sudo mount.cifs //192.168.0.50/Volume_1 /home/rasberry/nas_x -o user=Alex,password=marus14kaW7,vers=1.0,iocharset=utf8
sudo nano /etc/fstab
```
>	//192.168.0.50/Volume_1 /home/rasberry/nas_x cifs rw,username=Alex,password=marus14kaW7,vers=1.0,iocharset=utf8 0 0

### SAMBA
```
sudo apt install samba 
sudo nano /etc/samba/smb.conf
```
>	...<br />
>	[<ресур>]<br />
>	comment = Shared OPi folder<br />
>	path = </home/opi/opi_samba><br />
>	browseable = no<br />
>	writeable = Yes<br />
>	only guest = no<br />
>	create mask = 0777<br />
>	directory mask = 0777<br />
>	public = no<br />
```	
sudo smbpasswd -a <username> #системного пользователя. не существующего добавлять нельзя
sudo service smbd restart
```
### NFS взамен SAMBA
```bash
sudo apt install nfs-kernel-server	
sudo nano /etc/exports	
	/home   192.168.0.0/255.255.255.0(rw,sync,no_root_squash,no_subtree_check)
	#для указания конкретного адреса вроде надо писать 192.168.0.1/255.255.255.255
	#специальные шары создаются с chown nobody:nogroup и тогда no_root_squash нужно не указывать, в обычных папках указывать обязательно
	#если async - можно открывать уже занятые файлы, иначе нельзя двже открыть открытые на хосте для чтения
sudo systemctl restart nfs-kernel-server	
```	
В винде NFS Client устанавливать Приложения -> Дополнительные компоненты -> Другие компоненты Windows -> Службы для NFS<br />
Для записи в обычные шары под админом в реестре HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default создать <br />
DWORD32 AnonymousUid = 0 и AnonymousGid = 0 (запись будет под рутом) и перезапустить службу "Клиент для NFS из оснастки 'Службы для NFS' (nfsmgmt.msc)" <br /><br />
Подключать сетевой диск из windows необходимо под anon с пустым паролем	или `mount -o anon \\KOM-FS01\mnt\vdo-vd1\ovirt-iso-domain I:`
Чтобы писать [под пользователем](https://meandubuntu.ru/2014/04/подключение-nfs-обычным-пользователем/)	
```bash
sudo nano /etc/exports	
	/home   192.168.0.0/255.255.255.0(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
	#где uid:gid под кем писать можно посмотреть cat /etc/passwd
```	
Нужно ли при этом ковырять реестр в винде - не знаю.<br />
	
### NTP
```
sudo apt install ntp
sudo nano /etc/ntp.conf
```
>	pool ru.pool.ntp.org iburst <br />
>	server ntp2.vniiftri.ru iburst prefer <br />
>	server 0.ru.pool.ntp.org <br />
>	server 1.ru.pool.ntp.org <br />
>	server 2.ru.pool.ntp.org <br />
>	server 3.ru.pool.ntp.org <br />
>	... <br />
>	restrict 192.168.0.0 mask 255.255.255.0 <br />
>	broadcast 192.168.0.255 <br />
>	broadcast 224.0.1.1 <br />
```
sudo systemctl restart ntp
```
### MINIDLNA
```
sudo apt install minidlna
sudo nano /etc/minidlna.conf
```
>	<#>media_dir=</media/DataY/Torrents>  <br />
>	<#>db_dir=... <br />
>	<#>log_dir=... <br />
>	port=8200 <br />
>	<#>friendly_name=OrangePi <br />
>	<#>inotify=yes <br />
>	<#>notify_interval=20 <br />
```	
ip link set eth1 multicast on
ip link set lo multicast on
sudo service minidlna restart
```
### VPNKI
```
sudo apt-get install -y pptp-linux #Установим пакет pptp-linux
sudo pptpsetup --create vpnki --server msk.vpnki.ru --username <имя туннеля> --password <пароль туннеля> # Создадим соединени #Подключим туннель
sudo pon vpnki updetach
ifconfig -s #Проверим что создался интерфейс ppp0
ping 172.16.0.1 # Проверим пинг адреса VPNKI
sudo poff vpnki # Отключим туннель
ifconfig -s # Проверим отключение ppp0
sudo nano -B /etc/rc.local # Добавим установление PPTP туннеля при загрузке компьютера, открываем файл
```
>	И перед "exit 0" вставляем туда текст <br />
>	vpn="on" <br />
>	if [ $vpn = on ]; then <br />
>	printf "\nVPN connection to VPNKI\n" <br />
>	pon vpnki updetach &  <br />
>	sleep 5 <br />
>	sudo route add -net "172.16.0.0/16" dev "ppp0" & #Маршрут к сети VPNKI <br />
>	sudo route add -net "192.168.100.0/24" dev "ppp0" #Например маршрут к "другому" вашему туннелю (в домашнюю сеть 192.168.100.0/24) <br />
>	printf "Netstat output of all PPTP sockets\n" <br />
>	netstat -a | grep "/var/run/pptp/" <br />
>	fi <br />
```
sudo /etc/rc.local # Тестируем работу local.rc без перезагрузки
sudo systemctl status rc-local # Тестируем работу local.rc без перезагрузки
sudo systemctl restart rc-local 
sudo journalctl -u rc-local

sudo nano -B /etc/ppp/peers/vpnki # В случае обрыва связи нам потребуется автоматическая переустановка соединения, для этого откройте файл
```
>	#В конец файла добавьте  <br />
>	persist  <br />
>	maxfail 0  <br />
>	holdoff 10 <br />
```
sudo nano -B /etc/ppp/ip-up.d/routeadd # В случае обрыва связи и ее восстановлении нам также потребуется автоматически прописать маршруты к сети VPNKI и к вашей "другой" сети. Для этого создайте файл
```
>	#!/bin/sh -e  <br />
>	route add -net "172.16.0.0/16" dev "ppp0" #Маршрут к сети VPNKI  <br />
>	#route add -net "192.168.100.0/24" dev "ppp0" #Например маршрут к вашей "другой" сети 192.168.100.0/24 (если такая существует через сеть VPNKI)  <br />
```
sudo chmod 755 /etc/ppp/ip-up.d/routeadd # Измените права на исполнение файла при поднятии интерфейса ppp0
```

### RTL_433
```bash	
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
#если не исполняется скрипт (так и не понял о чем. У меня устройство находит, но пишет в конце абортед и он работает)
#lsusb
# получаем вида Bus 005 Device 003: ID 0bda:2838 Realtek Semiconductor Corp. RTL2838 DVB-T
#sudo nano /etc/udev/rules.d/rtl-sdr.rules
#	SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE:="0666"
#sudo service udev restart
#sudo reboot
sudo apt install libtool librtlsdr-dev rtl-433
#компиляция из исходников если в репе нет rtl-433
#cd /usr/src
#sudo git clone https://github.com/merbanan/rtl_433.git
#cd rtl_433/ && sudo mkdir build && cd build && sudo cmake ../ && sudo make
#sudo make install
cd /usr/local/etc/rtl_433
sudo cp rtl_433.exmple.conf rtl_433.conf
sudo nano rtl_433.conf
	decoder n=PIR815K,m=OOK_PWM,s=352,l=1116,r=1180,g=0,t=200,bits=25,get=@0:{25}:id #добавляем поддержку ДД PIR815K
nano /home/bogdan/rtl433_test.sh 	
	#!/bin/bash
	if [[ "$(ps -A | grep rtl_433)" != *rtl_433* ]]; then
	    echo "exec"
	    sudo rtl_433 -c /home/bogdan/rtl_433.conf |  mosquitto_pub -h 192.168.0.60 -u bogdan -P marus14kaMQT9 -t rtl_433 -l&
	fi	
crontab -e 
	@reboot /home/bogdan/rtl433_test.sh
	*/1 * * * * /home/bogdan/rtl433_test.sh
```

### ZIGBEE2MQTT
lsusb #убедиться, что есть в устройствах
ls -l /dev/serial/by-id #убедиться, что /dev/ttyACM0 
sudo usermod -a -G dialout <user> #дать права на порт (не забыть перезойти)
#sudo usermod -a -G tty <user> #возможно и в эту группу добавить придется
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - #подключаем	репозитарий, с первого раза не прошло
sudo apt install -y nodejs
nodejs -v #проверяем версию должна быть 12.xxx
sudo apt install -y npm
sudo npm install -g npm@latest #обновляем до последней версии
npm -version #должно быть старше 6.5.0
sudo git clone https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt
sudo chown -R <user>:<user> /opt/zigbee2mqtt
cd /opt/zigbee2mqtt
npm install #будет куча предупреждений, игнорировать. закончиться должно added <383> packages in <111.613>
#в opt/zigbee2mqtt/data/ скопировать configuration.yaml и еще 2
npm start
sudo nano /etc/systemd/system/zigbee2mqtt.service #устанавливаем как сервис
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
#git checkout 00ebd44 # откат на версию 1.3.0
#rm -rf node_modules
#npm install

# MAJORDOMO
https://kb.mjdm.ru/kak-ustanovit-majordomo-na-linux/
#mysql 
sudo apt install mariadb-server mariadb-client -y
sudo mysql_secure_installation #И пройдите по всем шагам. И в этих шагах укажите пароль пользователя root.
sudo mysql -uroot -p -e "CREATE DATABASE db_terminal;"
sudo mysql -uroot -p -e "CREATE USER 'majordomo'@'%' IDENTIFIED BY '<passw>';"
sudo mysql -uroot -p -e "GRANT ALL PRIVILEGES ON *.* TO 'majordomo'@'%';"
sudo mysql -uroot -p -e "FLUSH PRIVILEGES;"
#apache2
sudo apt-get install apache2 apache2-utils -y
sudo nano /etc/apache2/sites-available/000-default.conf
  #<VirtualHost *:80>
  #  DocumentRoot /var/www/html
  # после этого безобразия вставляем, что ниже 
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
# PHP
sudo apt install php php-cgi php-cli php-pear php-mysql php-mbstring php-xml -y	
sudo apt install curl libcurl4 libcurl3-dev php-curl -y
sudo apt autoremove
sudo apt install libapache2-mod-php -y
sudo nano /etc/php/7.3/apache2/php.ini
	;short_open_tag = On	
	short_open_tag = Off
sudo apt install phpmyadmin -y #при установке выбираем настройку через apache2, затем через dbconfig-common, пароль от MySQL
sudo a2enmod rewrite
sudo apache2ctl restart
sudo nano /etc/php/7.3/apache2/php.ini
	error_reporting  =  E_ALL & ~E_NOTICE ; заменяем
	max_execution_time  = 90 ; С 30 меняем на 90
	max_input_time = 180 ; С 60 на 180
	post_max_size = 200M ; С 8M на 200M
	upload_max_filesize = 50M ; С 2M на 50M
	max_file_uploads = 150 ; С 20 на 150
sudo nano /etc/php/7.3/cli/php.ini
	# меняем тоже, что и в файле выше
sudo /etc/init.d/apache2 restart
	
# MAJORDOMO
mkdir ~/majordomo && cd ~/majordomo && wget https://github.com/sergejey/majordomo/archive/master.zip
unzip master.zip && sudo cp -rp ~/majordomo/majordomo-master/* /var/www/html && sudo cp -rp ~/majordomo/majordomo-master/.htaccess /var/www/html && rm -rf ~/majordomo
sudo find /var/www/html/ -type f -exec chmod 0644 {} \;
sudo find /var/www/html/ -type d -exec chmod 0755 {} \;
ls -lh /var/www/html # проверяем права Права будут выглядеть подобно drwxr-xr-x (директории), -rw-r--r-- (файлы)
sudo chown -R www-data:www-data /var/www/html
ls -lh /var/www/html # проверяем собственника Вывод должен быть подобный: -rw-r--r--  1 www-data www-data  12K May 26 22:19 cycle.php
sudo usermod -a -G audio www-data
cat /etc/group | grep audio # проверяем собственника в группе  Вывод будет подобный audio:x:29:www-data
#Заходим по адресу: http://192.168.0.x/phpmyadmin и majordomo, и пароль который который был задан в SQL
#скачиваем куда-нибудь https://raw.githubusercontent.com/sergejey/majordomo/master/db_terminal.sql 
#импортируем db_terminal из него (Импорт успешно завершён, выполнено 171 запросов. (db_terminal.sql))
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
