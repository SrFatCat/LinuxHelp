# LinuxHelp

## Изменить метрику
```
ip route
route
sudo route del default dev wlan0
sudo route add -net default gw x.x.x.1 dev wlan0 metric xxxx
```

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
ssh-keygen
scp r:/ключ.pub user@host:/home/bogdan/.ssh/
mv ключ.pub authorized_keys
