#!/bin/bash
#personal use
P='\e[0;35m'
B='\033[0;36m'
N='\e[0m'
clear
echo -e "\e[36m\033[0m"
echo -e " \E[0;36m            XRAY TROJAN WS MENU             \E[0m"
echo -e "\e[36m\033[0m

  1   Add XRAY Trojan WS Account
  2   Add Trial XRAY Trojan WS Account
  3   Check User Login XRAY Trojan WS
  4   Delete XRAY Trojan WS Account
  5   Renew XRAY Trojan WS Account
  6   Check XRAY Trojan WS Config
 
  0   Back To Main Menu"
echo""
echo -e " \033[1;37mPress [ Ctrl+C ] • To-Exit-Script\033[0m"
echo ""
echo -ne "Select menu : "; read x
if [[ $(cat /opt/.ver) = $serverV ]] > /dev/null 2>&1; then
    if [[ $x -eq 1 ]]; then
       add-tr
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 2 ]]; then
       trial-tr
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 3 ]]; then
       cek-tr
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 4 ]]; then
       del-tr
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 5 ]]; then
       renew-tr
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 6 ]]; then
       user-tr
       read -n1 -r -p "Press any key to continue..."
       menu
    elif [[ $x -eq 0 ]]; then
       clear
       menu
    else
       clear
       menu-tr
    fi
fi
