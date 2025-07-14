#!/bin/bash

# FST L2TPv3 Tunnel - Version 1
# GitHub: github.com/Hadifst/fst-l2tpv3-tunnel
# Telegram: @deusvpn

clear

echo -e "\e[1;36m"
cat << "EOF"
 ______ _____ _____     _______ _____  _____  __      _______ _____  ______ 
|  ____|_   _|  __ \ /\|__   __|  __ \|  __ \|  |    |__   __|  __ \|  ____|
| |__    | | | |__) /  \  | |  | |__) | |__) |  |       | |  | |__) | |__   
|  __|   | | |  ___/ /\ \ | |  |  _  /|  ___/|  |       | |  |  _  /|  __|  
| |____ _| |_| |  / ____ \| |  | | \ \| |    |  |____   | |  | | \ \| |____ 
|______|_____|_| /_/    \_\_|  |_|  \_\_|    |______|  |_|  |_|  \_\______|

EOF
echo -e "\e[0m"
echo -e "\e[1;32mVersion:\e[0m 1"
echo -e "\e[1;33mGitHub:\e[0m github.com/Hadifst/fst-l2tpv3-tunnel"
echo -e "\e[1;33mTelegram Channel:\e[0m @deusvpn"
echo "------------------------------------------------------------"

# Show server location info
echo -e "\e[1;36mFetching server location...\e[0m"
IPINFO=$(curl -s ipinfo.io)
LOCATION=$(echo "$IPINFO" | grep country | awk -F'"' '{print $4}')
DATACENTER=$(echo "$IPINFO" | grep org | cut -d ':' -f2- | xargs)
echo -e "\e[1;32mLocation:\e[0m $LOCATION"
echo -e "\e[1;32mDatacenter:\e[0m $DATACENTER"
echo "------------------------------------------------------------"

# Show main menu
while true; do
  echo ""
  echo -e "\e[1;36mFST L2TPv3 Tunnel Menu\e[0m"
  echo "1) Create new tunnel"
  echo "2) Tunnel management"
  echo "3) Check tunnel status"
  echo "4) Update script"
  echo "5) Exit"
  read -p "Choose an option [1-5]: " choice

  case $choice in
    1)
      bash <(curl -Ls https://raw.githubusercontent.com/Hadifst/fst-l2tpv3-tunnel/main/l2tpv3_interactive_autoreconnect_en.sh)
      ;;
    2)
      echo -e "\nAvailable tunnels:"
      ip l2tp show tunnel
      echo -e "\nTo delete a tunnel:"
      echo "ip l2tp del tunnel tunnel_id <ID>"
      ;;
    3)
      echo -e "\nTunnel status:"
      ip l2tp show tunnel
      ;;
    4)
      echo -e "\nUpdating system and script..."
      apt update && apt upgrade -y
      ;;
    5)
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo "Invalid choice. Try again."
      ;;
  esac
done

