#!/bin/bash

echo "🔰 اسکریپت راه‌اندازی تانل L2TPv3 بین دو سرور ایران و سوئیس"
echo "--------------------------------------------------------"

read -p "📍 آیا این سرور نقش ایران (client) را دارد؟ [y/n]: " IS_IR

if [[ "$IS_IR" == "y" || "$IS_IR" == "Y" ]]; then
    read -p "🌐 آی‌پی سرور ایران (این سرور): " IP_IR
    read -p "🌐 آی‌پی سرور سوئیس: " IP_CH
    LOCAL_IP="$IP_IR"
    REMOTE_IP="$IP_CH"
    TUN_SRC_IP="10.0.0.1"
    TUN_DST_IP="10.0.0.2"
else
    read -p "🌐 آی‌پی سرور سوئیس (این سرور): " IP_CH
    read -p "🌐 آی‌پی سرور ایران: " IP_IR
    LOCAL_IP="$IP_CH"
    REMOTE_IP="$IP_IR"
    TUN_SRC_IP="10.0.0.2"
    TUN_DST_IP="10.0.0.1"
fi

INTERFACE="l2tpeth0"
SSH_SRC_IP="$(who | awk '{print $5}' | tr -d '()' | head -n1)"

echo "🔧 حذف تانل‌های قبلی (در صورت وجود)..."
ip l2tp del session tunnel_id 1000 session_id 2000 2>/dev/null
ip l2tp del tunnel tunnel_id 1000 2>/dev/null

echo "🚧 ساخت تانل جدید بین $LOCAL_IP ↔ $REMOTE_IP ..."
ip l2tp add tunnel tunnel_id 1000 peer_tunnel_id 1000 encap ip local $LOCAL_IP remote $REMOTE_IP
ip l2tp add session tunnel_id 1000 session_id 2000 peer_session_id 2000
ip link add name $INTERFACE type l2tpeth session_id 2000
ip link set $INTERFACE up
ip addr add $TUN_SRC_IP/30 dev $INTERFACE

echo "✅ تست پینگ به طرف مقابل ($TUN_DST_IP)..."
ping -c 2 $TUN_DST_IP

if [[ "$IS_IR" == "y" || "$IS_IR" == "Y" ]]; then
  echo "📡 تنظیم route پیش‌فرض از طریق سوئیس و حفظ مسیر SSH ($SSH_SRC_IP)..."
  ip route del default
  ip route add $SSH_SRC_IP/32 via $IP_IR dev eth0
  ip route add default via $TUN_DST_IP dev $INTERFACE
fi

echo "✅ تانل L2TPv3 راه‌اندازی شد!"

echo "⚙️ ایجاد اسکریپت دائمی برای اتصال مجدد تانل..."

cat <<EOF > /usr/local/bin/l2tpv3-reconnect.sh
#!/bin/bash
IP_IR="{IP_IR}"
IP_CH="{IP_CH}"
TUN_SRC_IP="{TUN_SRC_IP}"
TUN_DST_IP="{TUN_DST_IP}"
INTERFACE="l2tpeth0"
SSH_SRC_IP="$(who | awk '{print \$5}' | tr -d '()' | head -n1)"

ip l2tp del session tunnel_id 1000 session_id 2000 2>/dev/null
ip l2tp del tunnel tunnel_id 1000 2>/dev/null

ip l2tp add tunnel tunnel_id 1000 peer_tunnel_id 1000 encap ip local $IP_IR remote $IP_CH
ip l2tp add session tunnel_id 1000 session_id 2000 peer_session_id 2000
ip link add name $INTERFACE type l2tpeth session_id 2000
ip link set $INTERFACE up
ip addr add $TUN_SRC_IP/30 dev $INTERFACE

if [[ "$IS_IR" == "y" || "$IS_IR" == "Y" ]]; then
  ip route del default
  ip route add $SSH_SRC_IP/32 via $IP_IR dev eth0
  ip route add default via $TUN_DST_IP dev $INTERFACE
fi
EOF

#!/bin/bash

cat <<EOF > /etc/systemd/system/l2tp-tunnel.service
[Unit]
Description=Auto Reconnect L2TPv3 Tunnel
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/l2tpv3-reconnect.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

chmod +x /usr/local/bin/l2tpv3-reconnect.sh
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable l2tp-tunnel.service
