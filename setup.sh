#!/bin/bash
# =================================================================
#   HokageScript VPS — Setup Script
#   FIX: hapus PERMISSION/check_license, ganti URL hokagelegend9999/original
#        ke hokagescript, perbaiki sed tanpa nama file
# =================================================================
set -euo pipefail

HKBASE="https://raw.githubusercontent.com/tuyulbodo99/hokagescript/main"

red='\e[1;31m'; green='\e[0;32m'; yell='\e[1;33m'; tyblue='\e[1;36m'; NC='\e[0m'
green()  { echo -e "\033[32;1m${*}\033[0m"; }
red()    { echo -e "\033[31;1m${*}\033[0m"; }
yellow() { echo -e "\033[33;1m${*}\033[0m"; }

[[ "${EUID}" -ne 0 ]] && { red "You need to run this script as root"; exit 1; }
[[ "$(systemd-detect-virt 2>/dev/null || echo none)" == "openvz" ]] && { red "OpenVZ is not supported"; exit 1; }

localip=$(hostname -I | cut -d\  -f1)
hst=$(hostname)
dart=$(grep -w "$(hostname)" /etc/hosts | awk '{print $2}' || true)
if [[ "$hst" != "$dart" ]]; then
  echo "$localip $(hostname)" >> /etc/hosts
fi

mkdir -p /etc/xray

secs_to_human() {
  echo "Installation time: $(( ${1} / 3600 ))h $(( (${1} / 60) % 60 ))m $(( ${1} % 60 ))s"
}
start=$(date +%s)

ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1     >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true

cat > /root/.profile << 'PROFILE'
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
fi
mesg n 2>/dev/null || true
clear
PROFILE
chmod 644 /root/.profile

apt-get install -y git curl wget >/dev/null 2>&1

mkdir -p /etc/devculturevpnn /var/lib/devculturevpn-pro

if [[ -f "/etc/xray/domain" ]]; then
  yellow "Script sudah pernah diinstall sebelumnya."
  echo -ne "  Lanjutkan install ulang? (y/n)? "
  read -r answer
  if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    rm -f /root/setup.sh 2>/dev/null; exit 0
  fi
fi

echo ""
yellow "Masukkan domain untuk vmess/vless/trojan"
echo ""
read -rp "  Input domain: " -e pp
if [[ -z "$pp" ]]; then
  red "Domain tidak boleh kosong!"; exit 1
fi
echo "$pp" > /root/domain
echo "$pp" > /root/scdomain
echo "$pp" > /etc/xray/domain
echo "IP=$pp" > /var/lib/devculturevpn-pro/ipvps.conf

echo ""
yellow "Install SSH & OpenVPN..."
TMP=$(mktemp /tmp/hk-XXXXX.sh)
wget -qO "$TMP" "${HKBASE}/ssh/ssh-vpn.sh" 2>/dev/null || \
  curl -fsSL "${HKBASE}/ssh/ssh-vpn.sh" -o "$TMP" 2>/dev/null
chmod +x "$TMP" && bash "$TMP"; rm -f "$TMP"

echo ""
yellow "Install Xray..."
TMP=$(mktemp /tmp/hk-XXXXX.sh)
wget -qO "$TMP" "${HKBASE}/xray/ins-xray.sh" 2>/dev/null || \
  curl -fsSL "${HKBASE}/xray/ins-xray.sh" -o "$TMP" 2>/dev/null
chmod +x "$TMP" && bash "$TMP"; rm -f "$TMP"

echo ""
yellow "Install WebSocket..."
TMP=$(mktemp /tmp/hk-XXXXX.sh)
wget -qO "$TMP" "${HKBASE}/websocket/insshws.sh" 2>/dev/null || \
  curl -fsSL "${HKBASE}/websocket/insshws.sh" -o "$TMP" 2>/dev/null
[[ -s "$TMP" ]] && chmod +x "$TMP" && bash "$TMP" || true; rm -f "$TMP"

echo ""
yellow "Download Extra Menu..."
TMP=$(mktemp /tmp/hk-XXXXX.sh)
wget -qO "$TMP" "${HKBASE}/update/update.sh" 2>/dev/null || \
  curl -fsSL "${HKBASE}/update/update.sh" -o "$TMP" 2>/dev/null
chmod +x "$TMP" && bash "$TMP"; rm -f "$TMP"

cat > /root/.profile << 'PROFILE'
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
fi
mesg n 2>/dev/null || true
clear
menu
PROFILE
chmod 644 /root/.profile

[[ ! -f "/etc/log-create-user.log" ]] && echo "Log All Account" > /etc/log-create-user.log
curl -sS ifconfig.me > /etc/myipvps 2>/dev/null || hostname -I | awk '{print $1}' > /etc/myipvps

echo ""
echo "====================-[HokageScript]-===================="
echo "   - OpenSSH    : 22, 200, 500, 40000, 51443, 58080"
echo "   - Stunnel4   : 222, 447, 777"
echo "   - Dropbear   : 109, 143"
echo "   - Badvpn     : 7100-7900"
echo "   - Nginx      : 81"
echo "   - Xray       : 80, 443"
echo "========================================================="
echo ""
rm -f /root/setup.sh 2>/dev/null
secs_to_human "$(($(date +%s) - ${start}))"
echo ""
echo -ne "  Reboot sekarang? (y/n)? "
read -r answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then reboot; fi
