#!/bin/bash
#personal use
NC='\e[0m'
## Foreground
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'

xray_service=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
nginx_service=$(systemctl status nginx | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)

# STATUS SERVICE XRAY
if [[ $xray_service == "running" ]]; then
   status_xray="${GB}ON${NC}"
else
   status_xray="${RB}OFF${NC}"
fi

# STATUS SERVICE NGINX
if [[ $nginx_service == "running" ]]; then
   status_nginx="${GB}ON${NC}"
else
   status_nginx="${RB}OFF${NC}"
fi

# // script version
#myver="$(cat /home/ver)"

# // script version check
serverV=$( curl -sS https://raw.githubusercontent.com/cutepookie/zooz-old-xray/main/UPDATE/version)


domain=$(cat /usr/local/etc/xray/domain)
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
WKT=$(cat /usr/local/etc/xray/timezone)
MYIP2=$(curl -sS ipv4.icanhazip.com)
SERONLINE=$(uptime -p | cut -d " " -f 2-10000)
load_cpu=$(printf '%-3s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")
ram_used=$(free -m | grep Mem: | awk '{print $3}')
total_ram=$(free -m | grep Mem: | awk '{print $2}')
ram_usage=$(echo "scale=2; ($ram_used / $total_ram) * 100" | bc | cut -d. -f1)
daily_usage=$(vnstat -d --oneline | awk -F\; '{print $6}' | sed 's/ //')
monthly_usage=$(vnstat -m --oneline | awk -F\; '{print $11}' | sed 's/ //')

clear
echo -e ""
echo -e "      [ XRAY-CORE${NC} : ${status_xray} ]  [ NGINX${NC} : ${status_nginx} ]"
echo -e ""
echo -e ""
echo -e "     ${WB}----- [ Bandwidth Monitoring ] -----${NC}"
echo -e ""
echo -e " Daily Data Usage   :  ${YB}$daily_usage${NC}"
echo -e " Monthly Data Usage :  ${YB}$monthly_usage${NC}"
echo -e ""
echo -e ""
echo -e " \E[1;36m                 XRAY MENU                  \E[0m"
echo -e "
 \033[1;36m  1\033[0m  XRAY Vmess WS Panel
 \033[1;36m  2\033[0m  XRAY Vless WS Panel
 \033[1;36m  3\033[0m  XRAY Trojan WS Panel
 \033[1;36m  4\033[0m  XRAY Vless TCP XTLS Panel
 \033[1;36m  5\033[0m  XRAY Trojan TCP Panel
 \033[1;36m  6\033[0m  DNS Changer
 \033[1;36m  7\033[0m  Netflix Checker
 \033[1;36m  8\033[0m  Limit Bandwith Speed
 \033[1;36m  9\033[0m  Change Domain
 \033[1;36m 10\033[0m  Renew Certificate
 \033[1;36m 11\033[0m  Check VPN Status
 \033[1;36m 12\033[0m  Check VPN Port
 \033[1;36m 13\033[0m  Restart VPN Services
 \033[1;36m 14\033[0m  Speedtest VPS
 \033[1;36m 15\033[0m  Check RAM & CPU Usage
 \033[1;36m 16\033[0m  Reboot VPS"
echo ""
echo ""
echo -e " \033[1;37mType [ x ] To Exit From Menu \033[0m"
echo -e ""
read -p " Select Menu :  "  opt
case $opt in
1) clear ; menu-ws ;;
2) clear ; menu-vless ;;
3) clear ; menu-tr ;;
4) clear ; menu-xray ;;
5) clear ; menu-xtr ;;
6) clear ; dns ; echo "" ; menu ;;
7) clear ; nf ; echo "" ; read -n1 -r -p "Press any key to continue..." ; menu ;;
8) clear ; limit ; echo "" ; menu ;;
9) clear ; add-host ;;
10) clear ; certxray ;;
11) clear ; status ; read -n1 -r -p "Press any key to continue..." ; menu ;;
12) clear ; cekport ;;
13) clear ; restart ; menu ;;
14) clear ; speedtest ; echo "" ; read -n1 -r -p "Press any key to continue..." ; menu ;;
15) clear ; gotop ; menu ;;
16) clear ; reboot ;;
00 | 0) clear ; menu ;;
x | X) exit ;;
*) clear ; menu ;;
esac
