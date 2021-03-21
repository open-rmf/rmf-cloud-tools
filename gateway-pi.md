# GPI-Setup

On Desktop
```
wget https://downloads.raspberrypi.org/raspios_armhf/images/raspios_armhf-2021-01-12/2021-01-11-raspios-buster-armhf.zip
# Flash with balena etcher or whatever you like
```

From here, everything is on the PI
```
# General installation 
sudo apt update && upgrade
sudo apt install wireguard hostapd dnsmasq
```

# Provision Servers
```
Set up a server and client using https://github.com/open-rmf/rmf-cloud-tools
```

# Setup Hotspot
TODO: fix why hostapd does not seem to start on boot. We use the activate-gpi script to hackily patch this for now
```
### Set /etc/hostapd/hostapd.conf to the following
interface=wlan0
driver=nl80211
ssid=gpi-ap
hw_mode=g
channel=1
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=3
wpa_passphrase=password
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
###

### Setup /etc/dnsmasq.conf to the following
interface=wlan0
dhcp-range=10.42.0.2,10.42.0.2,255.255.255.0,24h     
listen-address=::1,127.0.0.1
server=8.8.8.8
server=8.8.4.4
no-resolv
```

### Setup /etc/dhcpcd.conf to add the following
```
interface wlan0
static ip_address=10.42.0.1
```

### Setup /etc/resolv.conf to the following
```
domain net
nameserver 8.8.8.8
```

# Start services
```
sudo -s # AS SUDO

systemctl unmask hostapd.service
systemctl start hostapd.service
journalctl -u hostapd.service -f    # Check for error messages

systemctl unmask dnsmasq.service
systemctl start dnsmasq.service
journalctl -u dnsmasq.service -f    # Check for error messages

systemctl enable hostapd.service
systemctl enable dnsmasq.service

exit
```

# Setup Wireguard 
```
sudo -s
cd /etc/wireguard

### Set up /etc/wireguard/wg0.conf to the wg0.conf as generated from rmf-cloud-tools
systemctl start wg-quick@wg0.service
```

# Setup activation script
```
### Setup /home/pi/activate-gpi as the following:
#!/bin/bash

echo "G POWERS ACTIVATE"
systemctl restart hostapd.service
sysctl -w net.ipv4.ip_forward=1

iptables -F -t nat
iptables -F 

iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 22 -j ACCEPT
iptables -t nat -A PREROUTING -i wlan0 -d 10.42.0.1 -j DNAT --to-destination 10.200.200.1
iptables -t nat -A POSTROUTING -o wg0 -d 10.200.200.1 -j SNAT --to 10.200.200.2

iptables -t nat -A PREROUTING -i wg0 -d 10.200.200.2 -j DNAT --to-destination 10.42.0.2
iptables -t nat -A POSTROUTING -o wlan0 -d 10.42.0.12 -j SNAT --to 10.42.0.1


#iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 22 -j ACCEPT
#iptables -t nat -A PREROUTING -i eth0 -d 10.42.0.1 -j DNAT --to-destination 10.200.200.1
#iptables -t nat -A POSTROUTING -o wg0 -d 10.200.200.1 -j SNAT --to 10.200.200.2

#iptables -t nat -A PREROUTING -i wg0 -d 10.200.200.2 -j DNAT --to-destination 10.42.0.12
#iptables -t nat -A POSTROUTING -o eth0 -d 10.42.0.12 -j SNAT --to 10.42.0.1

###
sudo chmod +x /home/pi/activate-gpi

### Setup /etc/systemd/system/gpi.service as the following:
[Unit]
Description=GPi startup script
After=network.target dnsmasq.service

StartLimitIntervalSec=12
StartLimitBurst=3

[Service]
Type=simple
User=root
ExecStart=/home/pi/activate-gpi
Restart=no

[Install]
WantedBy=default.target
###

sudo systemctl enable gpi.service
sudo systemctl start gpi.service
journalctl -u gpi.service -f # Check if success
```

# Use the GPi!
1. Plug Gpi into power
2. From remote, connect to gpi-ap over Wifi. Password is "password"
