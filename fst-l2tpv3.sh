
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}"
cat << "EOF"
 █████▒███   ██████  ███████ 
▓██  ▒ ▒██▒ ██   ▒  ██   ▒ 
▒██ ░░ ░██▒ ▒████ ░ ▒████ ░ 
░██ ░░ ░██▒ ░ ▒░▒░ ░░ ▒░▒░ ░ 
░▓   ░░▓ ░   ░ ▒ ▒░  ░ ▒ ▒░ 
 ▒ ░  ▒ ░   ░ ░ ░ ▒ ░ ░ ░ ▒  
 ▒ ░  ▒ ░     ░ ░     ░ ░  
 ░    ░                   
EOF

echo -e "${NC}Version: ${YELLOW}1${NC}"
echo -e "GitHub: ${GREEN}github.com/Hadifst/fst-l2tpv3-tunnel${NC}"
echo -e "Telegram Channel: ${CYAN}@deusvpn${NC}"

# Detect location and datacenter
echo ""
echo -e "${YELLOW}Fetching server location...${NC}"
IPINFO=$(curl -s ipinfo.io)
COUNTRY=$(echo "$IPINFO" | grep country | cut -d '"' -f4)
ORG=$(echo "$IPINFO" | grep org | cut -d '"' -f4)

echo -e "Location: ${GREEN}$COUNTRY${NC}"
echo -e "Datacenter: ${CYAN}$ORG${NC}"
echo "------------------------------------------------------------"
echo ""

# Auto system update
echo -e "${YELLOW}🔄 Updating system...${NC}"
apt update -y && apt upgrade -y

echo -e "${GREEN}✅ System updated.${NC}"
echo ""

# اجرای اسکریپت اصلی
bash <(curl -Ls https://raw.githubusercontent.com/Hadifst/fst-l2tpv3-tunnel/main/l2tpv3_interactive_autoreconnect_en.sh)
