# FST L2TPv3 Tunnel 🚀

A fully automated interactive script to create a **Layer 3 IP-over-IP tunnel** between two servers (e.g. Iran → foreign) using `L2TPv3` encapsulation over `IP`.

✅ Ideal for bypassing local restrictions, routing V2Ray/Marzban traffic through a clean IP, or simply building your own relay.

---

## 🌍 Features

- Automated **L2TPv3** tunnel creation  
- Full **IPv4/IP routing**  
- Works with **Marzban**, **V2Ray**, or any TCP-based protocol  
- Auto-route setup without SSH disconnection  
- Auto-reconnect after reboot (via `systemd`)  
- Shows **location** & **datacenter** using `ipinfo.io`

---

## ⚡ One-Line Installation

Run this on your **Iranian or foreign server**:

```
bash <(curl -Ls https://raw.githubusercontent.com/Hadifst/fst-l2tpv3-tunnel/main/fst-l2tpv3.sh)
```
🧠 _The script will ask:_
- Is this an Iranian server?
- Foreign and local IPs?

Then it will setup the L2TPv3 tunnel with route switching and auto-reconnect.

---

## 📡 Usage Scenario

Example:  
You have a Marzban panel on an Iranian server (`151.x.x.x`) and want to route traffic via a foreign IP (`45.x.x.x`).

Client sees only the clean foreign IP — but real traffic reaches Iran.

---

## 📦 Requirements

- Two Linux servers (Ubuntu 20+)
- Public IPv4 on both
- Root access (sudo)

---

## 💡 Developed by

**FST Team**  
Telegram: [@deusvpn](https://t.me/deusvpn)  
GitHub: [Hadifst](https://github.com/Hadifst)
