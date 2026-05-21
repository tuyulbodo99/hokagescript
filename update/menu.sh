#!/bin/bash
# =================================================================
#   HokageScript VPS — Main Menu
#   FIX: hapus BURIQ/PERMISSION/Bloman (ijin/original tidak ada),
#        set default variabel Exp/Name/Isadmin secara lokal
# =================================================================
HKBASE="https://raw.githubusercontent.com/tuyulbodo99/hokagescript/main"

# Warna
colornow=$(cat /etc/hokagevpn/theme/color.conf 2>/dev/null || echo "blue")
export NC="\e[0m"
export YELLOW='\033[0;33m'
export RED="\033[0;31m"
export GREEN='\033[0;32m'
COLOR1=$(cat /etc/hokagevpn/theme/$colornow 2>/dev/null | grep -w "TEXT" | cut -d: -f2 | sed 's/ //g' || echo "\033[1;36m")
COLBG1=$(cat /etc/hokagevpn/theme/$colornow 2>/dev/null | grep -w "BG"   | cut -d: -f2 | sed 's/ //g' || echo "\033[1;37m")

# System info
tram=$(free -h 2>/dev/null | awk 'NR==2 {print $2}')
uram=$(free -h 2>/dev/null | awk 'NR==2 {print $3}')
ISP=$(curl -s --max-time 5 ipinfo.io/org 2>/dev/null | cut -d' ' -f2-10 || echo "N/A")
CITY=$(curl -s --max-time 5 ipinfo.io/city 2>/dev/null || echo "N/A")
MYIP=$(curl -s --max-time 5 ipv4.icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}')

# FIX: Exp dan Name diambil dari file lokal — tidak lagi dari ijin/original
Name=$(hostname 2>/dev/null || echo "hokage")
Isadmin="ON"
Exp="2099-12-31"

# Service status
ssh_ws=$(systemctl is-active ws-stunnel 2>/dev/null || echo "inactive")
nginx_st=$(systemctl is-active nginx 2>/dev/null || echo "inactive")
xray_st=$(systemctl is-active xray   2>/dev/null || echo "inactive")

[[ "$ssh_ws"  == "active" ]] && status_ws="${GREEN}ON${NC}"    || status_ws="${RED}OFF${NC}"
[[ "$nginx_st" == "active" ]] && status_nginx="${GREEN}ON${NC}" || status_nginx="${RED}OFF${NC}"
[[ "$xray_st" == "active" ]] && status_xray="${GREEN}ON${NC}"  || status_xray="${RED}OFF${NC}"

function add-host(){
  clear
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
  echo -e "$COLOR1│${NC} ${COLBG1}               • ADD VPS HOST •                ${NC} $COLOR1│$NC"
  echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
  read -rp "  New Host Name : " -e host
  echo ""
  if [[ -z "$host" ]]; then
    echo -e "  [INFO] Type Your Domain/sub domain"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo ""
    read -n 1 -s -r -p "  Press any key to back on menu"
    menu
  else
    echo "$host" > /etc/xray/domain
    echo "IP=$host" > /var/lib/hokagevpn-pro/ipvps.conf 2>/dev/null || true
    echo ""
    echo "  [INFO] Dont forget to renew cert"
    echo ""
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo ""
    read -n 1 -s -r -p "  Press any key to Renew Cert"
    crtxray 2>/dev/null || true
  fi
}

function updatews(){
  clear
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
  echo -e "$COLOR1│${NC} ${COLBG1}            • UPDATE SCRIPT VPS •              ${NC} $COLOR1│$NC"
  echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
  echo -e "$COLOR1│${NC}  $COLOR1[INFO]${NC} Check for Script updates..."
  sleep 1
  # FIX: download dari hokagescript bukan dari /original
  TMP_UP=$(mktemp /tmp/hk-update-XXXXX.sh)
  wget -qO "$TMP_UP" "${HKBASE}/update/update.sh" 2>/dev/null || \
    curl -fsSL "${HKBASE}/update/update.sh" -o "$TMP_UP" 2>/dev/null
  chmod +x "$TMP_UP"
  bash "$TMP_UP" && rm -f "$TMP_UP"
  echo -e "$COLOR1│${NC}  $COLOR1[INFO]${NC} Successfully Up To Date!"
  echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
  echo ""
  read -n 1 -s -r -p "  Press any key to back on menu"
  menu
}

function menu(){
  clear
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
  echo -e "$COLOR1│${NC} ${COLBG1}               • VPS PANEL MENU •              ${NC} $COLOR1│$NC"
  echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
  DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "N/A")
  echo -e "$COLOR1│$NC Memory Usage   : $uram / $tram"
  echo -e "$COLOR1│$NC ISP & City     : $ISP & $CITY"
  echo -e "$COLOR1│$NC Current Domain : $DOMAIN"
  echo -e "$COLOR1│$NC IP-VPS         : ${COLOR1}$MYIP${NC}"
  echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
  echo -e "$COLOR1│$NC [ SSH WS : ${status_ws} ]  [ XRAY : ${status_xray} ]   [ NGINX : ${status_nginx} ] $COLOR1│$NC"
  echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
  echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
  echo -e "  ${COLOR1}[01]${NC} • SSHWS   [${YELLOW}Menu${NC}]   ${COLOR1}[07]${NC} • THEME    [${YELLOW}Menu${NC}]  $COLOR1│$NC"
  echo -e "  ${COLOR1}[02]${NC} • VMESS   [${YELLOW}Menu${NC}]   ${COLOR1}[08]${NC} • BACKUP   [${YELLOW}Menu${NC}]  $COLOR1│$NC"
  echo -e "  ${COLOR1}[03]${NC} • VLESS   [${YELLOW}Menu${NC}]   ${COLOR1}[09]${NC} • ADD HOST/DOMAIN  $COLOR1│$NC"
  echo -e "  ${COLOR1}[04]${NC} • TROJAN  [${YELLOW}Menu${NC}]   ${COLOR1}[10]${NC} • RENEW CERT       $COLOR1│$NC"
  echo -e "  ${COLOR1}[05]${NC} • SS WS   [${YELLOW}Menu${NC}]   ${COLOR1}[11]${NC} • SETTINGS [${YELLOW}Menu${NC}]  $COLOR1│$NC"
  echo -e "  ${COLOR1}[06]${NC} • SET DNS [${YELLOW}Menu${NC}]   ${COLOR1}[12]${NC} • INFO     [${YELLOW}Menu${NC}]  $COLOR1│$NC"
  echo -e "  ${COLOR1}[13]${NC} • SET IP  [${YELLOW}Menu${NC}]   ${COLOR1}[14]${NC} • SET BOT  [${YELLOW}Menu${NC}]  $COLOR1│$NC"
  echo -e "  ${COLOR1}[00]${NC} • UPDATE SCRIPT                               $COLOR1│$NC"
  echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
  echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
  echo -e "$COLOR1│${NC}              • HokageScript •          $COLOR1│$NC"
  echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
  echo ""
  echo -ne " Select menu : "; read -r opt
  case $opt in
    01|1) clear; menu-ssh 2>/dev/null    || echo "menu-ssh tidak ditemukan" ;;
    02|2) clear; menu-vmess 2>/dev/null  || echo "menu-vmess tidak ditemukan" ;;
    03|3) clear; menu-vless 2>/dev/null  || echo "menu-vless tidak ditemukan" ;;
    04|4) clear; menu-trojan 2>/dev/null || echo "menu-trojan tidak ditemukan" ;;
    05|5) clear; menu-ss 2>/dev/null     || echo "menu-ss tidak ditemukan" ;;
    06|6) clear; menu-dns 2>/dev/null    || echo "menu-dns tidak ditemukan" ;;
    07|7) clear; menu-theme 2>/dev/null  || echo "menu-theme tidak ditemukan" ;;
    08|8) clear; menu-backup 2>/dev/null || echo "menu-backup tidak ditemukan" ;;
    09|9) clear; add-host ;;
    10) clear; crtxray 2>/dev/null   || echo "crtxray tidak ditemukan" ;;
    11) clear; menu-set 2>/dev/null  || echo "menu-set tidak ditemukan" ;;
    12) clear; info 2>/dev/null      || echo "info tidak ditemukan" ;;
    13) clear; menu-ip 2>/dev/null   || echo "menu-ip tidak ditemukan" ;;
    14) clear; menu-bot 2>/dev/null  || echo "menu-bot tidak ditemukan" ;;
    00|0) clear; updatews ;;
    *) clear; menu ;;
  esac
}

menu
