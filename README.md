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

