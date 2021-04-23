#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo -e "This script must be run as root"
   exit 1
fi

script_path=$(dirname $(realpath "$0"))

export LAN_IFACE="${LAN_IFACE:-wlan0}"
export LAN_SSID="${LAN_SSID:-central_hotspot}"
export LAN_PASSPHRASE="${LAN_PASSPHRASE:-password}"
export LAN_DNS="${LAN_DNS:-8.8.8.8}"
export LAN_CENTRAL_IP="${LAN_CENTRAL_IP:-192.168.29.1}"
export LAN_SUBNET="${LAN_SUBNET:-255.255.255.0}"
export LAN_DHCP_LOW="${LAN_DHCP_LOW:-192.168.29.10}"
export LAN_DHCP_HIGH="${LAN_DHCP_HIGH:-192.168.29.20}"

echo -e "Hotspot Details: "
echo -e "LAN_IFACE: $LAN_IFACE"
echo -e "LAN_SSID: $LAN_SSID"
echo -e "LAN_PASSPHRASE: $LAN_PASSPHRASE"
echo -e "LAN_DNS: $LAN_DNS"
echo -e "LAN_CENTRAL_IP: $LAN_CENTRAL_IP"
echo -e "LAN_SUBNET: $LAN_SUBNET"
echo -e "LAN_DHCP_LOW: $LAN_DHCP_LOW"
echo -e "LAN_DHCP_HIGH: $LAN_DHCP_HIGH"


read -p "Continue? [Yy] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  apt install hostapd dnsmasq iptables-persistent netfilter-persistent -y
  temp_hostapd=$(mktemp)
  temp_dnsmasq=$(mktemp)
    envsubst < $script_path/hostapd.conf.template > $temp_hostapd
    envsubst < $script_path/dnsmasq.conf.template > $temp_dnsmasq
    ip addr flush $LAN_IFACE
    ip addr add $LAN_CENTRAL_IP/$LAN_SUBNET dev $LAN_IFACE

    if [[ -n "$INTERNET_IFACE" ]]; then
      echo -e "Setting up Internet Sharing"

      temp_iptables=$(mktemp)
      iptables-save > $temp_iptables
      sysctl -w net.ipv4.ip_forward=1
      iptables -A FORWARD -i $LAN_IFACE -o $INTERNET_IFACE -j ACCEPT
      iptables -A FORWARD -i $INTERNET_IFACE -o $LAN_IFACE -j ACCEPT
      iptables -t nat -A POSTROUTING -o $LAN_IFACE -j MASQUERADE
      iptables -t nat -A POSTROUTING -o $INTERNET_IFACE -j MASQUERADE
    fi

    hostapd $temp_hostapd &
    dnsmasq -p 0 -d -C $temp_dnsmasq && fg

    # Teardown
    ip addr flush $LAN_IFACE
    
    if [[ -v "$INTERNET_IFACE" ]]; then
      iptables -F 
      iptables -F -t nat
      iptables-restore $temp_iptables
    fi

    read -p "Clear DHCP Leases? [Yy] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm /var/lib/misc/dnsmasq.leases || true
      echo -e "\nDHCP Leases Removed."
    else
      echo -e "\nDHCP Leases Persist."
    fi

else
  echo -e "\nHotspot Setup Aborted."
fi

