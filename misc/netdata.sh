#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

clear
cat <<"EOF"
    _   __     __  ____        __
   / | / /__  / /_/ __ \____ _/ /_____ _
  /  |/ / _ \/ __/ / / / __ `/ __/ __ `/
 / /|  /  __/ /_/ /_/ / /_/ / /_/ /_/ /
/_/ |_/\___/\__/_____/\__,_/\__/\__,_/

EOF

install() {
while true; do
  read -p "This script will install NetData on Proxmox VE 8+. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

wget -q https://repo.netdata.cloud/repos/repoconfig/debian/bookworm/netdata-repo_2-2+debian12_all.deb
dpkg -i netdata-repo_2-2+debian12_all.deb
rm -rf netdata-repo_2-2+debian12_all.deb
apt-get update &>/dev/null
apt-get -y upgrade
apt-get install -y netdata
echo -e "\nInstalled NetData (http://$(hostname -I | awk '{print $1}'):19999)\n"
}

uninstall() {
systemctl stop netdata
apt-get remove --purge -y netdata netdata-repo
rm -rf /var/log/netdata /var/lib/netdata /var/cache/netdata /etc/apt/sources.list.d/netdata.list
rm -rf /etc/apt/trusted.gpg.d/netdata-archive-keyring.gpg
systemctl daemon-reload
apt autoremove -y
userdel netdata
  echo -e "\nRemoved NetData from Proxmox VE\n"
}

if ! pveversion | grep -Eq "pve-manager/(8\.[0-9])"; then
  msg_error "This version of Proxmox Virtual Environment is not supported"
  echo -e "Requires PVE Version 8.0 or higher"
  echo -e "Exiting..."
  sleep 2
  exit
fi

OPTIONS=(Install "Install NetData on Proxmox VE" \
         Uninstall "Uninstall NetData from Proxmox VE")

CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "NetData" --menu "Select an option:" 10 58 2 \
          "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

case $CHOICE in
  "Install")
    install
    ;;
  "Uninstall")
    uninstall
    ;;
  *)
    echo "Exiting..."
    exit 0
    ;;
esac
