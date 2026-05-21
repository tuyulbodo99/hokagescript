#!/bin/bash
#
# ==================================================
# DevCulture / HokageScript — SSH & OpenVPN Installer
# FIX: hapus $ANU undefined, perbaiki sed tanpa nama file,
#      ganti URL dari hokagelegend9999/original ke hokagescript
# ==================================================

export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- ipinfo.io/ip 2>/dev/null || curl -fsSL ipinfo.io/ip 2>/dev/null)
MYIP2="s/xxxxxxxxx/$MYIP/g"
# FIX: hapus $ANU — ip route tidak butuh flag tambahan
NET=$(ip -o -4 route show to default 2>/dev/null | awk '{print $5}' | head -1 || echo "eth0")
source /etc/os-release 2>/dev/null || true
ver="${VERSION_ID:-}"

HKBASE="https://raw.githubusercontent.com/tuyulbodo99/hokagescript/main"

country=ID; state=INDONESIA; locality=TANGERANG
organization=HOKAGE; organizationalunit=HOKAGE
commonname=none; email=hokagelegend99@gmail.com

cd /root

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service << 'END'
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

cat > /etc/rc.local << 'END'
#!/bin/sh -e
# rc.local
exit 0
END
chmod +x /etc/rc.local
systemctl enable rc-local 2>/dev/null || true
systemctl start rc-local.service 2>/dev/null || true

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
if ! grep -q "disable_ipv6" /etc/rc.local; then
  sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
fi

apt update -y >/dev/null 2>&1
apt upgrade -y >/dev/null 2>&1
apt dist-upgrade -y >/dev/null 2>&1
apt-get remove --purge ufw firewalld -y >/dev/null 2>&1 || true
apt-get remove --purge exim4 -y >/dev/null 2>&1 || true

apt -y install jq wget curl figlet ruby >/dev/null 2>&1 || true
gem install lolcat >/dev/null 2>&1 || true

ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# install nginx
apt -y install nginx >/dev/null 2>&1
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
wget -qO /etc/nginx/nginx.conf "${HKBASE}/ssh/nginx.conf" 2>/dev/null || true
rm -f /etc/nginx/conf.d/vps.conf
wget -qO /etc/nginx/conf.d/vps.conf "${HKBASE}/ssh/vps.conf" 2>/dev/null || true
service nginx restart >/dev/null 2>&1 || true

mkdir -p /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
rm -f /etc/nginx/conf.d/default.conf
systemctl daemon-reload
service nginx restart >/dev/null 2>&1 || true

mkdir -p /home/vps/public_html /home/vps/public_html/ss-ws /home/vps/public_html/clash-ws
wget -qO /home/vps/public_html/index.html "${HKBASE}/ssh/multiport" 2>/dev/null || echo "HokageScript VPS" > /home/vps/public_html/index.html

# install badvpn
wget -qO /usr/bin/badvpn-udpgw "${HKBASE}/ssh/newudpgw" 2>/dev/null || true
if [[ -f /usr/bin/badvpn-udpgw ]]; then
  chmod +x /usr/bin/badvpn-udpgw
  for PORT in 7100 7200 7300 7400 7500 7600 7700 7800 7900; do
    if ! grep -q "badvpn.*$PORT" /etc/rc.local; then
      sed -i "$ i\\screen -dmS badvpn${PORT} badvpn-udpgw --listen-addr 127.0.0.1:${PORT} --max-clients 500" /etc/rc.local
    fi
    screen -dmS "badvpn${PORT}" badvpn-udpgw --listen-addr "127.0.0.1:${PORT}" --max-clients 500 2>/dev/null || true
  done
fi

# setting port ssh
if ! grep -q "Port 500" /etc/ssh/sshd_config; then
  sed -i '/Port 22/a Port 500'   /etc/ssh/sshd_config
  sed -i '/Port 22/a Port 40000' /etc/ssh/sshd_config
  sed -i '/Port 22/a Port 51443' /etc/ssh/sshd_config
  sed -i '/Port 22/a Port 58080' /etc/ssh/sshd_config
  sed -i '/Port 22/a Port 200'   /etc/ssh/sshd_config
fi
sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
# FIX: tambahkan nama file target
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service ssh restart >/dev/null 2>&1 || true

# install dropbear
apt -y install dropbear >/dev/null 2>&1 || true
sed -i 's/NO_START=1/NO_START=0/g'       /etc/default/dropbear 2>/dev/null || true
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear 2>/dev/null || true
if ! grep -q "50000" /etc/default/dropbear 2>/dev/null; then
  sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69 "/g' /etc/default/dropbear 2>/dev/null || true
fi
echo "/bin/false"        >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart    >/dev/null 2>&1 || true
service dropbear stop  >/dev/null 2>&1 || true
service dropbear start >/dev/null 2>&1 || true

# install stunnel
apt install stunnel4 -y >/dev/null 2>&1 || true

openssl genrsa -out /tmp/key.pem 2048 2>/dev/null
openssl req -new -x509 -key /tmp/key.pem -out /tmp/cert.pem -days 1095 \
  -subj "/C=${country}/ST=${state}/L=${locality}/O=${organization}/OU=${organizationalunit}/CN=${commonname}/emailAddress=${email}" 2>/dev/null
cat /tmp/key.pem /tmp/cert.pem > /etc/stunnel/stunnel.pem
rm -f /tmp/key.pem /tmp/cert.pem

# FIX: nama section stunnel harus unik (duplikat [dropbear] dihapus)
cat > /etc/stunnel/stunnel.conf << 'END'
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[openssh]
accept = 222
connect = 127.0.0.1:22

[dropbear]
accept = 777
connect = 127.0.0.1:109

[ws-stunnel]
accept = 2096
connect = 127.0.0.1:700

[openvpn]
accept = 442
connect = 127.0.0.1:1194
END

sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null || true
service stunnel4 restart >/dev/null 2>&1 || true

# install fail2ban
apt -y install fail2ban >/dev/null 2>&1 || true

# DDos Deflate
mkdir -p /usr/local/ddos
for url in "https://www.inetbase.com/scripts/ddos/ddos.conf" "http://www.inetbase.com/scripts/ddos/ddos.conf"; do
  wget -q -O /usr/local/ddos/ddos.conf "$url" 2>/dev/null && break || true
done
for url in "https://www.inetbase.com/scripts/ddos/ddos.sh" "http://www.inetbase.com/scripts/ddos/ddos.sh"; do
  wget -q -O /usr/local/ddos/ddos.sh "$url" 2>/dev/null && break || true
done
if [[ -f /usr/local/ddos/ddos.sh ]]; then
  chmod 0755 /usr/local/ddos/ddos.sh
  ln -sf /usr/local/ddos/ddos.sh /usr/local/sbin/ddos 2>/dev/null || true
  /usr/local/ddos/ddos.sh --cron >/dev/null 2>&1 || true
fi

# banner
wget -qO /etc/issue.net "${HKBASE}/issue.net" 2>/dev/null || true
chmod +x /etc/issue.net 2>/dev/null || true
if ! grep -q "Banner /etc/issue.net" /etc/ssh/sshd_config; then
  echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
fi
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear 2>/dev/null || true

# download helper scripts
for SCRIPT in speedtest xp auto-set; do
  case "$SCRIPT" in
    speedtest) SRC="${HKBASE}/ssh/speedtest_cli.py" ;;
    xp)        SRC="${HKBASE}/ssh/xp.sh" ;;
    auto-set)  SRC="${HKBASE}/xray/auto-set.sh" ;;
  esac
  wget -qO "/usr/bin/${SCRIPT}" "$SRC" 2>/dev/null && chmod +x "/usr/bin/${SCRIPT}" || true
done

cat > /etc/cron.d/re_otm << 'END'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 7 * * * root /sbin/reboot
END
cat > /etc/cron.d/xp_otm << 'END'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/bin/xp
END
echo "7" > /home/re_otm
service cron restart >/dev/null 2>&1 || true

chown -R www-data:www-data /home/vps/public_html 2>/dev/null || true

for SVC in nginx ssh dropbear fail2ban stunnel4; do
  service "$SVC" restart >/dev/null 2>&1 || true
  echo -e "[ ok ] Restarting $SVC"
done

screen -dmS badvpn7100 badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500 2>/dev/null || true
screen -dmS badvpn7200 badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500 2>/dev/null || true
screen -dmS badvpn7300 badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500 2>/dev/null || true

history -c
echo "unset HISTFILE" >> /etc/profile
rm -f /root/key.pem /root/cert.pem /root/ssh-vpn.sh /root/bbr.sh 2>/dev/null || true
clear
