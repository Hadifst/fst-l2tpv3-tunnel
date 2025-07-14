#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m'

clear
echo -e "${BLUE}"
echo " █████▒▒████████▒▒██▒▒▒██████"
echo " ██▒▒██▒▒██▒▒▒▒██▒▒██▒▒██▒▒██"
echo " ██▒▒██▒▒██████▒▒▒▒██▒▒██████"
echo " ██▒▒██▒▒██▒▒▒▒██▒▒██▒▒██▒▒██"
echo " █████▒▒████████▒▒██▒▒██▒▒██  FST L2TPv3 Tunnel"
echo -e "${NC}"
echo -e "${YELLOW}Version:${NC} 1"
echo -e "${YELLOW}GitHub:${NC} github.com/Hadifst/fst-l2tpv3-tunnel"
echo -e "${YELLOW}Telegram Channel:${NC} @deusvpn"
echo ""

echo -e "${BLUE}Fetching server location...${NC}"
LOCATION=$(curl -s ipinfo.io/country)
DCINFO=$(curl -s ipinfo.io/org)
echo -e "${YELLOW}Location:${NC} $LOCATION"
echo -e "${YELLOW}Datacenter:${NC} $DCINFO"
echo "---------------------------------------------"
echo ""

echo -e "${GREEN}Main Menu${NC}"
echo "1) Create new tunnel"
echo "2) Manage tunnels"
echo "3) Check tunnel status"
echo "4) Update this script"
echo "5) Exit"
echo ""
read -p "Choose an option [1-5]: " OPTION

case $OPTION in
  1)
    bash <(curl -Ls https://raw.githubusercontent.com/Hadifst/fst-l2tpv3-tunnel/main/fst-l2tpv3.sh)
    ;;
  2)
    ip l2tp show tunnel
    ;;
  3)
    ip -d link show type l2tpeth
    ;;
  4)
    curl -Ls https://raw.githubusercontent.com/Hadifst/fst-l2tpv3-tunnel/main/fst-l2tpv3_menu.sh -o /usr/local/bin/fstl2tp
    chmod +x /usr/local/bin/fstl2tp
    echo "✅ Script updated. Run again: fstl2tp"
    ;;
  5)
    echo "👋 Exiting."
    exit 0
    ;;
  *)
    echo "❌ Invalid option."
    ;;
esac
