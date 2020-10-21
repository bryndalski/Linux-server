#!/bin/bash


#czytam sobie nazwe serwera
function server_rename(){

server_name=`cat config.temp`;
#ustawiam nazwe serwera dla pliku hostname\
rm -r /etc/hostname
$server_name >> /etc/hostname 

# ustaiwam nazwe serwera dla /etc/hosts
co_zmieniam=`sed -n 2p /etc/hosts`
#wycinam IP
co_zmieniam="${co_zmieniam:10}"
sed  -i "s/$co_zmieniam/$server_name/g" /etc/hosts 
rm -r config.temp
}


function network_configure(){
netmask=`cat mask.temp`;
ip_adress=`cat address.temp`
#rm -r mask.temp;
#rm -r address.temp;
echo -e " \n #interface 2 \n auto enp0s8 \n allow-hotplug enp0s8 \n iface enp0s8 inet static \n address $ip_adress \n netmask $netmask">> /etc/network/interfaces
}

#pliki do dyspo
#mask.temp
#address.temp
#dhcp
#second_domain.temp
#domain.temp
#broadcast.temp
function dhcp_configure(){
#rm -r /etc/dhcp/dhcpd.conf
adres_ip=`cat address.temp`
maska=`cat mask.temp`
nazwa_sieci=`cat domain.temp`
nazwa_drg_dns=`cat second_domain.temp`
#zanawa w numerki 
#subnet
subnet_last_digit=`cut -d'.' -f 4 address.temp`
subnet="${adres_ip%.*}.$((subnet_last_digit-1))"
#bootp1
bootp="${adres_ip%.*}.$((subnet_last_digit+1))"
#bootp2
broadcast_last_digit=`cut -d'.' -f 4 broadcast.temp`
bootp_dwa="${adres_ip%.*}.$((broadcast_last_digit))"
#brodcast
broadcast=`cat broadcast.temp`
#utput
echo -e "ddns-update-style none;\noption domain-name\"$nazwa_sieci\";\noption domain-name-servers $adres_ip ,$nazwa_drg_dns;\nmax-lease-time 7200;\nlog-facility local7;\nsubnet $subnet netmask $maska{\nrange dynamic-bootp $bootp $bootp_dwa;\noption routers $adres_ip;\noption broadcast-address $broadcast;\n}">/etc/dhcp/dhcpd.conf
rm -r *.temp
}












#wyświetlam powitanie 
apt-get install dialog >>instal.temp
dialog --title "Witam serdecznie" --backtitle "SKRYPT MUSI ZOSTAĆ WYWOŁANY JAKO ROOT" --msgbox "Cześć - skonfiguruj swój DHCP + routing automatycznie wraz z zmianą
nazwy serwera etc. Jeśli widzisz tą wiadomość chce życzyć Ci miłego dzionka i smacznej kawusi :)
Pozdrawiam Kuba Bryndal " 0 0;
#pora pobrać informacje od użytkwnika
#nazwa serwera
clear;
dialog --title "Konfiguracja nazwy serwera" --inputbox "Daj mi nazwe serwera o tu " 0 0 2>config.temp
clear;
server_rename;
dialog --title "Konfiguracja karty sieciowek" --msgbox "Ok widzę że zmiane nazwy serwera mamy już za sobą.Poproszę Cie teraz o podanie mi kolejno adresu sieciowego i maski :)" 0 0 ;
clear
dialog --title "Adres sieci" --inputbox "Podaj mi proszę Adres swojej sieci np:10.0.0.1" 0 0 2>>address.temp
clear
dialog --title "Maska sieci" --inputbox "Podaj mi proszę maskę sieci np 255.255.255.0" 0 0 2>>mask.temp
clear
network_configure;
dialog --title "DHCP" --msgbox "Okej jeśli nic się nie zepsuło to jest miodzio pora się zabrać za dhcp. Wezme od ciebie kilka :Nazwe domeny ,broadcast i DNS2(8,8,8,8)" 0 0;
clear
dialog --title "DHCP" --inputbox "Oks to super podaj mi prosze teraz nazwe domeny np zsl04.local" 0 0 2>>domain.temp;
clear
dialog --title "DHCP" --inputbox "OKI to teraz broadcast np 10.0.0.255" 0 0 2>>broadcast.temp;
clear
dialog --title "DHCP" --inputbox "potrzebuje jeszcze 2 dnsa np 8.8.8.8" 0 0 2>>second_domain.temp;
clear
dhcp_configure
clear
#robie routing
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/exit 0/iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE/g' /etc/rc.local
echo 'exit 0' >> /etc/rc.local
reboot;
