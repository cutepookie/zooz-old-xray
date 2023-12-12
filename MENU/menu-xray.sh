#!/bin/bash
#personal use
P='\e[0;35m'
B='\033[0;36m'
N='\e[0m'
clear
echo -e "\e[36m\033[0m"
echo -e " \E[0;36m          XRAY VLESS TCP XTLS MENU          \E[0m"
echo -e "\e[36m\033[0m

  1   Add XRAY Vless TCP XTLS Account
  2   Add Trial XRAY Vless TCP XTLS Account
  3   Check User Login XRAY Vless TCP XTLS
  4   Delete XRAY Vless TCP XTLS Account
  5   Renew XRAY Vless TCP XTLS Account
  6   Check XRAY Vless TCP XTLS Config
 
  0   Back To Main Menu"
echo ""
echo -e " \033[1;37mPress [ Ctrl+C ] • To-Exit-Script\033[0m"
echo ""
echo -ne "Select menu : "; read x
if [[ $(cat /opt/.ver) = $serverV ]] > /dev/null 2>&1; then
    if [[ $x -eq 1 ]]; then
       add-xray
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 2 ]]; then
       trial-xray
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 3 ]]; then
       cek-xray
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 4 ]]; then
       del-xray
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 5 ]]; then
       renew-xray
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 6 ]]; then
       user-xray
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 0 ]]; then
       clear
       menu
    else
       clear
       menu-xray
    fi
fi
