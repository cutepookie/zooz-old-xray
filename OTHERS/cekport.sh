#!/bin/bash
#personal use
clear
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

echo ""
echo -e " "
echo -e "      ${WB}Multiport Websocket cutepookie${NC}"
echo -e " "
echo -e "   Protocol Service	|	Network Protocol   "
echo -e " "
echo -e "   ${GB}Vmess Websocket${NC}           ${GB} Websocket (CDN) TLS${NC}"
echo -e "   ${GB}Vless Websocket${NC}           ${GB} Websocket (CDN) NTLS${NC}"
echo -e "   ${GB}Trojan Websocket${NC}          ${GB} TCP TLS${NC}"
echo -e "   ${GB}Vless TCP XTLS${NC}            ${GB} TCP XTLS${NC}"
echo -e "   ${GB}Trojan TCP TLS${NC}            "
echo -e " "
echo -e "            YAML Service Information           "
echo -e " "
echo -e "   ${GB}YAML XRAY VMESS WS${NC}"
echo -e "   ${GB}YAML XRAY VLESS WS${NC}"
echo -e "   ${GB}YAML XRAY TROJAN WS${NC}"
echo -e "   ${GB}YAML XRAY VLESS TCP XTLS${NC}"
echo -e "   ${GB}YAML XRAY TROJAN TCP TLS${NC}"
echo -e " "
echo -e "              Server Information                  "
echo -e " "
echo -e "   ${GB}Timezone: Asia/Jakarta (GMT +7)${NC}"
echo -e "   ${GB}Fail2Ban: [ON]${NC}"
echo -e "   ${GB}Deflate: [ON]${NC}"
echo -e "   ${GB}IPtables: [ON]${NC}"
echo -e "   ${GB}Auto-Reboot: [ON]${NC}"
echo -e "   ${GB}IPV6: [OFF]${NC}"
echo -e ""
echo -e "   ${GB}Autoreboot On 06.00 GMT +8${NC}"
echo -e "   ${GB}Automatic Delete Expired Account${NC}"
echo -e "   ${GB}Bandwith Monitor${NC}"
echo -e "   ${GB}RAM & CPU Monitor${NC}"
echo -e "   ${GB}Check Login User${NC}"
echo -e "   ${GB}Check Created Config${NC}"
echo -e "   ${GB}Automatic Clear Log${NC}"
echo -e "   ${GB}Media Checker${NC}"
echo -e "   ${GB}DNS Changer${NC}"
echo -e " "
echo -e "               Network Port Service              "
echo -e " "
echo -e "   ${GB}HTTP: 80${NC}"
echo -e "   ${GB}HTTPS: 443${NC}"
echo -e " "
echo ""

read -n 1 -s -r -p "Press any key to back on menu"
menu