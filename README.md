# LinuxHelp

## Изменить метрику
```
ip route
route
sudo route del default dev wlan0
sudo route add -net default gw x.x.x.1 dev wlan0 metric xxxx
```

## Назначить статический ip
- netplan
```bash
 ls /etc/netplan/
 # если нет *-default.yaml значит нето пальто см. дальше
 sudo nano /etc/netplan/*-default.yaml
 ```
 ***
 ```yaml
  network: 
  version: 2
  renderer: NetworkManager
  ethernets:
    eth0:
      addresses: [192.168.1.120/24]
      dhcp4: yes
```     
***
```bash
sudo netplan apply
# sudo netplan --debug apply
```
- dhcp.service
```bash
sudo nano /etc/dhcpcd.conf
```
> nodhcp <br />
> static ip_address=192.168.0.10/24 <br />
> static routers=192.168.0.1 <br />
> static domain_name_servers=192.168.0.1 <br />
- interfaces.d
```bash
sudo nano /etc/network/interfaces.d/ethernet
```
> auto enP4p65s0 <br />
> iface enP4p65s0 inet dhcp <br />
> auto enP4p65s0:0 <br />
> iface enP4p65s0:0 inet static <br />
>       address 192.168.1.120 <br />
>       netmask 255.255.255.0 <br />

## Проблемы с wifi RPI
[взято отсюда](https://mirrobo.ru/network-manager-podklyuchenie-k-wi-fi-debian-ubuntu-raspbian/)
```
sudo systemctl start Networkmanager
sudo nmcli radio wifi on
sudo nmcli dev status
# отображение точек доступа !!!
sudo  nmcli dev wifi
# ручное подключение nmcli con add sirius5  ifname wlan0 type wifi ssid sirius3
sudo nmtui
# Add -> Wi-Fi -> Параметры сети (указать Device !!) -> Activate (выбрать имя подключения или сети) -> повторный ввод пароля
```
> НЕТ СОЕДИНЕНИЯ
>
> 1. Файл /etc/network/interfaces не должен содержать ничего об интерфейсах, даже:
>
> allow-hotplug eth0
>
> iface eth0 inet dhcp

## Монтирование флешки
```
 fdisk -l
 sudo mount /dev/sdc1 /mnt/usb
```
## Убрать пароль sudo
sudo visudo
> %sudo ALL=(ALL) NOPASSWD: ALL

## Генерация и копирование ключа
```bash
ssh-keygen
scp r:/ключ.pub user@host:/home/bogdan/.ssh/
mv ключ.pub authorized_keys
```

## Проброс порта тунелем
```bash
ssh -L 8888:192.168.1.25:22 bogdan@192.168.111.142 -i .\.ssh\smartgate
# -L порт_на_вызывающем_компе:адрес_в_лок_сети_промежуточного:порт сам_промежуточный_комп
```

## Поиск и удаление больших/старых файлов
```bash
find . -mount -type f -size +1G 2>/dev/null`
# -mount означает, что в процессе поиска не нужно переходить на другие файловые системы.
#b — блоки размером 512 байт. Числом указывается количество блоков.
#c — в байтах. Например: -size +128с
#w — в двухбайтовых словах
#k — в килобайтах
#M — в мегабайтах
#G — в гигабайтах
```
## Зависание update / upgrade
```bash
sudo apt -o Acquire::ForceIPv4=true update
sudo apt -o Acquire::ForceIPv4=true -y dist-upgrade
sudo apt autoremove
sudo apt clean
```

## Тест скорости чтения/записи
```bash
# Записать файл на 4G
sudo dd if=/dev/zero of=tempfile bs=1M count=4096 status=progress 
# Очистить кеш
sudo /sbin/sysctl -w vm.drop_caches=3
# Прочитать файл на 4G
sudo dd if=tempfile of=/dev/null bs=1M count=4096 status=progress
```

## Увеличить раздел на весь диск
```bash
df -h
# найти корневой раздел - он будет типа /dev/mmcblk1p2
sudo cfdisk /dev/mmcblk1
# запустить на этот раздел без номера партиции
```
В открывшейся программе <br />
- В пустом разделе в начале диска создать раздел во весь размер
- **удалить** корневой раздел /dev/mmcblk1p2
- на свободном месте создать раздел на весь размер 
- Write / Quit

```bash
sudo reboot
sudo resize2fs /dev/mmcblk1p2
```
