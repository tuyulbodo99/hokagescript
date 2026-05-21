<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=24&pause=1000&color=9B59B6&center=true&vCenter=true&width=600&lines=HokageScript;DevCulture+Menu+%26+Service+Suite;Part+of+DevCulture+Ecosystem" alt="Typing SVG" />

<br/>

[![Part of DevCulture](https://img.shields.io/badge/ecosystem-DevCulture-9b59b6?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/tuyulbodo99)
[![Shell](https://img.shields.io/badge/shell-bash-1a1a2e?style=for-the-badge&logo=gnubash&logoColor=white)](https://github.com/tuyulbodo99/hokagescript)
[![License](https://img.shields.io/badge/license-Private-6c3483?style=for-the-badge)](https://github.com/tuyulbodo99/hokagescript)
[![Sync](https://img.shields.io/badge/sync-auto-5b2c6f?style=for-the-badge&logo=sync&logoColor=white)](https://github.com/tuyulbodo99/devculture-vps/blob/main/sync.sh)

</div>

---

## 🟣 Overview

**HokageScript** adalah komponen menu dan service management dari ekosistem DevCulture. Menyediakan menu interaktif lengkap untuk manajemen SSH, Xray, VPN, bot, backup, dan monitoring VPS.

> 🔗 **Terhubung penuh dengan ekosistem DevCulture** — disinkronkan otomatis via `sync.sh`

---

## 🌐 Ekosistem DevCulture

| Repo | Fungsi |
|------|--------|
| [`devculture-vps`](https://github.com/tuyulbodo99/devculture-vps) | 🏠 Core installer & panel |
| **[`hokagescript`](https://github.com/tuyulbodo99/hokagescript)** | ⚙️ **Menu & service scripts** ← Anda di sini |
| [`vpnscript`](https://github.com/tuyulbodo99/vpnscript) | 🔒 VPN installer |
| [`vps-script`](https://github.com/tuyulbodo99/vps-script) | 🔧 SSH tunnel |
| [`ijin`](https://github.com/tuyulbodo99/ijin) | 🛡️ License system |

---

## ⚡ Instalasi

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/tuyulbodo99/hokagescript/main/setup.sh)
```

### Update via Ekosistem

```bash
# Update semua komponen DevCulture sekaligus:
bash <(curl -fsSL https://raw.githubusercontent.com/tuyulbodo99/devculture-vps/main/sync.sh)
```

---

## 📦 Komponen

<table>
<tr><td><b>📁 ssh/</b></td><td>SSH & WebSocket setup, multi-port</td></tr>
<tr><td><b>📁 xray/</b></td><td>Xray core installer (VMess/VLess/Trojan)</td></tr>
<tr><td><b>📁 websocket/</b></td><td>WebSocket & Nginx config</td></tr>
<tr><td><b>📁 backup/</b></td><td>Backup & restore data VPS</td></tr>
<tr><td><b>📁 update/</b></td><td>Script update semua menu service</td></tr>
<tr><td><b>📁 corn/</b></td><td>Cron jobs & scheduler</td></tr>
<tr><td><b>📄 setup.sh</b></td><td>Installer utama (dengan cek ijin)</td></tr>
<tr><td><b>📄 dependencies.sh</b></td><td>Instalasi paket dependensi</td></tr>
</table>

---

## 🛡️ Sistem Ijin

Script ini dilindungi oleh sistem lisensi DevCulture berbasis IP:

```bash
# Sumber ijin:
https://raw.githubusercontent.com/tuyulbodo99/ijin/main/youtube
```

VPS Anda harus terdaftar. Hubungi admin untuk registrasi.

---

## 🔧 Requirements

| Item | Detail |
|------|--------|
| OS | Debian 10/11/12 · Ubuntu 20/22 |
| Akses | Root |
| Arch | x86_64 |

---

<div align="center">

[![Telegram](https://img.shields.io/badge/Telegram-@devculturebot-9b59b6?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/devculturebot)
[![GitHub](https://img.shields.io/badge/GitHub-tuyulbodo99-1a1a2e?style=for-the-badge&logo=github&logoColor=white)](https://github.com/tuyulbodo99)

<sub>© 2024 DevCulture VPS Store · Part of <a href="https://github.com/tuyulbodo99">tuyulbodo99</a> Ecosystem</sub>

</div>
