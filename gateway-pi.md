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
systemctl stop dnsmasq.service
if [ -f /var/lib/misc/dnsmasq.leases ]; then
  rm /var/lib/misc/dnsmasq.leases
fi
systemctl start dnsmasq.service

systemctl restart hostapd.service
sysctl -w net.ipv4.ip_forward=1

iptables -F -t nat
iptables -F 

iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 22 -j ACCEPT
iptables -t nat -A PREROUTING -i wlan0 -d 10.42.0.1 -j DNAT --to-destination 10.200.200.1
iptables -t nat -A POSTROUTING -o wg0 -d 10.200.200.1 -j SNAT --to 10.200.200.2

iptables -t nat -A PREROUTING -i wg0 -d 10.200.200.2 -j DNAT --to-destination 10.42.0.2
iptables -t nat -A POSTROUTING -o wlan0 -d 10.42.0.2 -j SNAT --to 10.42.0.1


#iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 22 -j ACCEPT
#iptables -t nat -A PREROUTING -i eth0 -d 10.42.0.1 -j DNAT --to-destination 10.200.200.1
#iptables -t nat -A POSTROUTING -o wg0 -d 10.200.200.1 -j SNAT --to 10.200.200.2

#iptables -t nat -A PREROUTING -i wg0 -d 10.200.200.2 -j DNAT --to-destination 10.42.0.2
#iptables -t nat -A POSTROUTING -o eth0 -d 10.42.0.2 -j SNAT --to 10.42.0.1

###
sudo chmod +x /home/pi/activate-gpi
```

# Setup gpi.service 
```
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

# Setup cyclonedds.xml on External Device
```
### Setup $HOME/cyclonedds.xml as the following:
<?xml version="1.0" encoding="UTF-8" ?>
<CycloneDDS xmlns="https://cdds.io/config" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://cdds.io/config https://raw.githubusercontent.com/eclipse-cyclonedds/cyclonedds/master/etc/cyclonedds.xsd">
        <Domain id="any">
                <General>
                        <NetworkInterfaceAddress>wlp4s0</NetworkInterfaceAddress>
                        <AllowMulticast>false</AllowMulticast>
                        <MaxMessageSize>65500B</MaxMessageSize>
                        <FragmentSize>4000B</FragmentSize>
                        <Transport>udp</Transport>
                        <ExternalNetworkAddress>10.200.200.2</ExternalNetworkAddress>
                        <ExternalNetworkMask>255.255.255.0</ExternalNetworkMask>
                </General>
                <Discovery>
                        <Peers>
                                <Peer address="10.42.0.1"/>
                                <Peer address="10.42.0.2"/>
                        </Peers>
                        <ParticipantIndex>auto</ParticipantIndex>
                </Discovery>
                <Internal>
                        <Watermarks>
                                <WhcHigh>500kB</WhcHigh>
                        </Watermarks>
                        <MultipleReceiveThreads>false</MultipleReceiveThreads>
                </Internal>
                <Tracing>
                        <Verbosity>severe</Verbosity>
                        <OutputFile>stdout</OutputFile>
                </Tracing>
        </Domain>
</CycloneDDS>
```

# Setup cyclonedds.xml on Server
```
### Setup $HOME/cyclonedds.xml as the following
<CycloneDDS xmlns="https://cdds.io/config" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://cdds.io/config https://raw.githubusercontent.com/eclipse-cyclonedds/cyclonedds/master/etc/cyclonedds.xsd">
        <Domain id="any">
                <General>
                        <NetworkInterfaceAddress>wg0</NetworkInterfaceAddress>
                        <AllowMulticast>false</AllowMulticast>
                        <MaxMessageSize>35500B</MaxMessageSize>
                        <FragmentSize>4000B</FragmentSize>
                        <Transport>udp</Transport>
                        <ExternalNetworkAddress>10.42.0.1</ExternalNetworkAddress>
                </General>
                <Discovery>
                        <Peers>
                                <Peer address="10.200.200.1"/>
                                <Peer address="10.200.200.2"/>
                        </Peers>
                        <ParticipantIndex>auto</ParticipantIndex>
                </Discovery>
                <Internal>
                        <Watermarks>
                                <WhcHigh>500kB</WhcHigh>
                        </Watermarks>
                        <MultipleReceiveThreads>false</MultipleReceiveThreads>
                </Internal>
                <Tracing>
                        <Verbosity>severe</Verbosity>
                        <OutputFile>stdout</OutputFile>
                </Tracing>
        </Domain>
</CycloneDDS>
```

# Use the GPi!
1. Plug Gpi into power
2. From remote, connect to gpi-ap over Wifi. Password is "password"
3. contact 10.42.0.1 for any correspondence with wireguard server
4. `ros2 topic list` , you should see `/chatter` topic from the wireguard server ( i have a heartbeat talker running )
