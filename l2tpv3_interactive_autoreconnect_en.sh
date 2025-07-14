#!/bin/bash

echo "🔰 Interactive L2TPv3 Tunnel Setup Between Local and Foreign Server"
echo "-------------------------------------------------------------------"

read -p "📍 Is this the local (Iran) server? [y/n]: " IS_IR

if [[ "$IS_IR" == "y" || "$IS_IR" == "Y" ]]; then
    read -p "🌐 Local (Iran) server IP (this server): " IP_IR
    read -p "🌐 Foreign server IP: " IP_FOREIGN
    LOCAL_IP="$IP_IR"
    REMOTE_IP="$IP_FOREIGN"
    TUN_SRC_IP="10.0.0.1"
    TUN_DST_IP="10.0.0.2"
else
    read -p "🌐 Foreign server IP (this server): " IP_FOREIGN
    read -p "🌐 Local (Iran) server IP: " IP_IR
    LOCAL_IP="$IP_FOREIGN"
    REMOTE_IP="$IP_IR"
    TUN_SRC_IP="10.0.0.2"
    TUN_DST_IP="10.0.0.1"
fi

INTERFACE="l2tpeth0"
SSH_SRC_IP="$(who | awk '{print $5}' | tr -d '()' | head -n1)"

echo "🔧 Removing any existing tunnel (if exists)..."
ip l2tp del session tunnel_id 1000 session_id 2000 2>/dev/null
ip l2tp del tunnel tunnel_id 1000 2>/dev/null

echo "🚧 Creating new L2TPv3 tunnel from $LOCAL_IP to $REMOTE_IP ..."
ip l2tp add tunnel tunnel_id 1000 peer_tunnel_id 1000 encap ip local $LOCAL_IP remote $REMOTE_IP
ip l2tp add session tunnel_id 1000 session_id 2000 peer_session_id 2000
ip link add name $INTERFACE type l2tpeth session_id 2000
ip link set $INTERFACE up
ip addr add $TUN_SRC_IP/30 dev $INTERFACE

echo "✅ Pinging remote side ($TUN_DST_IP)..."
ping -c 2 $TUN_DST_IP

if [[ "$IS_IR" == "y" || "$IS_IR" == "Y" ]]; then
  echo "📡 Setting default route via tunnel while keeping SSH route for $SSH_SRC_IP..."
  SSH_IFACE=$(ip route get $SSH_SRC_IP | awk '{print $5; exit}')
  SSH_GW=$(ip route get $SSH_SRC_IP | awk '/via/ {print $3; exit}')
  ip route add $SSH_SRC_IP/32 via $SSH_GW dev $SSH_IFACE
  ip route del default || true
  ip route add default via $TUN_DST_IP dev $INTERFACE
fi

echo "⚙️ Creating reconnect script..."
cat <<EOF > /usr/local/bin/l2tpv3-reconnect.sh
#!/bin/bash
INTERFACE="l2tpeth0"
SSH_SRC_IP="\$(who | awk '{print \\$5}' | tr -d '()' | head -n1)"
ip l2tp del session tunnel_id 1000 session_id 2000 2>/dev/null
ip l2tp del tunnel tunnel_id 1000 2>/dev/null
ip l2tp add tunnel tunnel_id 1000 peer_tunnel_id 1000 encap ip local $LOCAL_IP remote $REMOTE_IP
ip l2tp add session tunnel_id 1000 session_id 2000 peer_session_id 2000
ip link add name \$INTERFACE type l2tpeth session_id 2000
ip link set \$INTERFACE up
ip addr add $TUN_SRC_IP/30 dev \$INTERFACE

if [[ "$IS_IR" == "y" || "$IS_IR" == "Y" ]]; then
  SSH_IFACE=\$(ip route get \$SSH_SRC_IP | awk '{print \\$5; exit}')
  SSH_GW=\$(ip route get \$SSH_SRC_IP | awk '/via/ {print \\$3; exit}')
  ip route add \$SSH_SRC_IP/32 via \$SSH_GW dev \$SSH_IFACE
  ip route del default || true
  ip route add default via $TUN_DST_IP dev \$INTERFACE
fi
EOF

chmod +x /usr/local/bin/l2tpv3-reconnect.sh

echo "🛠️ Creating systemd service for auto-reconnect..."
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

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable l2tp-tunnel.service

echo "✅ L2TPv3 tunnel setup complete! Tunnel will reconnect automatically after reboot."


