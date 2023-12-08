#!/bin/bash
# =========================================
# Multiport Fallback By cutepookie
# Version    : V1.0 Multiport Fallback
# Script By  : cutepookie
# (C) Copyright 2022 By cutepookie
# =========================================
clear
#Color
RED="\033[31m"
export NC='\e[0m'
export DEFBOLD='\e[39;1m'
export RB='\e[31;1m'
export GB='\e[32;1m'
export YB='\e[33;1m'
export BB='\e[34;1m'
export MB='\e[35;1m'
export CB='\e[35;1m'
export WB='\e[37;1m'

if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

echo -e ""
echo -e "\e[94m              .-----------------------------------------------.    "
echo -e "\e[94m              |          Installing Autoscript Begin          |    "
echo -e "\e[94m              '-----------------------------------------------'    "
echo -e "\e[0m"
echo ""
sleep 3
clear

if [ -f "/usr/local/etc/xray/domain" ]; then
echo "Script Already Installed"
exit 0
fi

secs_to_human() {
    echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
start=$(date +%s)

#update
apt update -y
apt full-upgrade -y
apt dist-upgrade -y
apt install socat curl screen cron neofetch screenfetch netfilter-persistent vnstat fail2ban -y
apt-get --reinstall --fix-missing install bzip2 gzip coreutils wget screen rsyslog iftop htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof -y
apt-get remove --purge ufw firewalld exim4 -y
mkdir /backup
mkdir /user
clear

# install resolvconf service
apt install resolvconf -y

#start resolvconf service
systemctl enable resolvconf.service
systemctl start resolvconf.service

# Make Folder Log XRAY
mkdir -p /var/log/xray
chmod +x /var/log/xray

# Make Folder XRAY
mkdir -p /usr/local/etc/xray

# Make Folder Config Logs
mkdir -p /usr/local/etc/xray/configlogs

#Download XRAY Core V1.7.5
wget -O /usr/local/bin/xray "https://github.com/cutepookie/zooz-old-xray/raw/main/BIN/xray"
chmod +x /usr/local/bin/xray
#Server Info
curl -s ipinfo.io/city >> /usr/local/etc/xray/city
curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /usr/local/etc/xray/org
curl -s ipinfo.io/timezone >> /usr/local/etc/xray/timezone
clear
cd
# Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest
clear

# Install dig/dnsutils
sudo apt-get install dnsutils -y

# set time GMT +8 Jakarta
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime


# Install Nginx
apt install nginx -y
rm /var/www/html/*.html
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
systemctl restart nginx
clear

# Insert Domain Features
touch /usr/local/etc/xray/domain
echo ""
echo "Please Insert Your Domain Before Proceed Installing"
echo " "
read -rp "Insert Domain : " -e dns
if [ -z $dns ]; then
echo -e "Please Insert Domain!"
else
echo "$dns" > /usr/local/etc/xray/domain
echo "DNS=$dns" > /var/lib/dnsvps.conf
fi
clear

# Install Cert Domain For XRAY 
systemctl stop nginx
domain=$(cat /usr/local/etc/xray/domain)
curl https://get.acme.sh | sh
source ~/.bashrc
cd .acme.sh
bash acme.sh --issue -d $domain --server letsencrypt --keylength ec-256 --fullchain-file /usr/local/etc/xray/xray.crt --key-file /usr/local/etc/xray/xray.key --standalone --force

# Nginx directory file download
mkdir -p /home/vps/public_html
cd
chown -R www-data:www-data /home/vps/public_html

# Random UUID For XRAY
uuid=$(cat /proc/sys/kernel/random/uuid)

#INSTALLING WEBSOCKET TLS
cat> /usr/local/etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}",
                        "flow": "xtls-rprx-direct",
                        "level": 0,
                        "email": ""
#xtls
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "dest": 1310,
                        "xver": 1
                    },
                    {
                        "path": "/vmess-ws",
                        "dest": 1311,
                        "xver": 1
                    },
                    {
                        "path": "/vless-ws",
                        "dest": 1312,
                        "xver": 1
                    },
                    {
                        "path": "/trojan-ws",
                        "dest": 1313,
                        "xver": 1
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "xtls",
                "xtlsSettings": {
                "alpn": ["http/1.1"],
                "certificates": [
                 {
                 "certificateFile": "/usr/local/etc/xray/xray.crt",
                  "keyFile": "/usr/local/etc/xray/xray.key"
                  }
                ],
                "minVersion": "1.2",
                 "cipherSuites": "TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256:TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256:TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
                }
            }
        },
    {
      "port": 1311,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0,
            "level": 0,
            "email": ""
#vmtls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings":
            {
              "acceptProxyProtocol": true,
              "path": "/vmess-ws"
            }
      }
    },
    {
      "port": 1312,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "level": 0,
            "email": ""
#vltls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings":
            {
              "acceptProxyProtocol": true,
              "path": "/vless-ws"
            }
        }
     },
    {
      "port": 1313,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid}",
            "level": 0,
            "email": ""
#trtls
          }
        ],
        "decryption":"none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings":
            {
              "acceptProxyProtocol": true,
              "path": "/trojan-ws"
            }
        }
    },
        {
            "port": 1310,
            "listen": "127.0.0.1",
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}",
                        "password": "xxxxx"
#tr
                    }
                ],
                "fallbacks": [
                    {
                        "dest": 80
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "none",
                "tcpSettings": {
                    "acceptProxyProtocol": true
                }
            }
        }
  ],
    "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  }
}
END

# // INSTALLING WEBSOCKET NONE-TLS
cat> /usr/local/etc/xray/none.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10086,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
      {
      "port": 80,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 1314,
            "xver": 1
          },
          {
              "path": "/vmess-ws",
              "dest": 1311,
              "xver": 1
          },
          {
              "path": "/vless-ws",
              "dest": 1312,
              "xver": 1
          },
          {
              "path": "/trojan-ws",
              "dest": 1313,
              "xver": 1
          }
        ]
      },
      "streamSettings": {
       "network": "tcp",
        "security": "none",
         "tlsSettings": {
          "alpn": ["http/1.1"]
             }
          }
       }
    ],
"outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink" : true,
      "statsOutboundDownlink" : true
    }
  }
}
END

#Remove Old Service
rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service.d

#XRAY Service
cat> /etc/systemd/system/xray.service << END
[Unit]
Description=XRAY-MULTIPORT SERVICE
Documentation= https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartSec=3s
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

END

#XRAY Service
cat> /etc/systemd/system/xray@.service << END
[Unit]
Description=XRAY-MULTIPORT SERVICE
Documentation= https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/%i.json
Restart=on-failure
RestartSec=3s
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

END

# Set Nginx Conf
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes 1;
pid /var/run/nginx.pid;
events {
	multi_accept on;
	worker_connections 1024;
}
http {
	gzip on;
	gzip_vary on;
	gzip_comp_level 5;
	gzip_types text/plain application/x-javascript text/xml text/css;
	autoindex on;
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	server_tokens off;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;
	client_max_body_size 32M;
	client_header_buffer_size 8m;
	large_client_header_buffers 8 8m;
	fastcgi_buffer_size 8m;
	fastcgi_buffers 8 8m;
	fastcgi_read_timeout 600;
	#CloudFlare IPv4
	set_real_ip_from 199.27.128.0/21;
	set_real_ip_from 173.245.48.0/20;
	set_real_ip_from 103.21.244.0/22;
	set_real_ip_from 103.22.200.0/22;
	set_real_ip_from 103.31.4.0/22;
	set_real_ip_from 141.101.64.0/18;
	set_real_ip_from 108.162.192.0/18;
	set_real_ip_from 190.93.240.0/20;
	set_real_ip_from 188.114.96.0/20;
	set_real_ip_from 197.234.240.0/22;
	set_real_ip_from 198.41.128.0/17;
	set_real_ip_from 162.158.0.0/15;
	set_real_ip_from 104.16.0.0/12;
	#Incapsula
	set_real_ip_from 199.83.128.0/21;
	set_real_ip_from 198.143.32.0/19;
	set_real_ip_from 149.126.72.0/21;
	set_real_ip_from 103.28.248.0/22;
	set_real_ip_from 45.64.64.0/22;
	set_real_ip_from 185.11.124.0/22;
	set_real_ip_from 192.230.64.0/18;
	real_ip_header CF-Connecting-IP;
	include /etc/nginx/conf.d/*.conf;
}
EOF

#Nginx Webserver
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/cutepookie/zooz-old-xray/main/OTHERS/vps.conf"

echo -e "[ ${RB}INFO${NC} ] Restart Daemon Service"
echo ""
systemctl daemon-reload
sleep 1

# enable xray ws tls
echo -e "[ ${GB}OK${NC} ] Restarting XRAY Core Service"
systemctl daemon-reload
systemctl enable xray.service
systemctl start xray.service
systemctl restart xray.service

# enable xray ws ntls
systemctl daemon-reload
systemctl enable xray@none.service
systemctl start xray@none.service
systemctl restart xray@none.service

# enable nginx
echo -e "[ ${GB}OK${NC} ] Restarting Nginx Service"
systemctl restart nginx

sleep 1

# Blokir TORRENT
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# Enable BBR
clear
echo -e "[ ${GB}INFO${NC} ] Installing TCP BBR Please Wait . . ."
echo ""
sleep 1
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sed -i '/fs.file-max/d' /etc/sysctl.conf
sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo -e "[ ${GB}INFO${NC} ] TCP BBR Successfully Installed !"
echo ""
sleep 2
clear


############# INSTALL RC.LOCAL
# go to root
cd

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

#######END OF RC.LOCAL INSTALL

# Github Profile Repo
api_url="https://raw.githubusercontent.com/cutepookie/zooz-old-xray/main"
echo -e "[ ${GB}INFO${NC} ] Download Autoscript Files Into VPS"
echo ""
sleep 1

#MENU
wget -O /usr/bin/menu "${api_url}/MENU/menu.sh" && chmod +x /usr/bin/menu
wget -O /usr/bin/menu-ws "${api_url}/MENU/menu-ws.sh" && chmod +x /usr/bin/menu-ws
wget -O /usr/bin/menu-vless "${api_url}/MENU/menu-vless.sh" && chmod +x /usr/bin/menu-vless
wget -O /usr/bin/menu-tr "${api_url}/MENU/menu-tr.sh" && chmod +x /usr/bin/menu-tr
wget -O /usr/bin/menu-xray "${api_url}/MENU/menu-xray.sh" && chmod +x /usr/bin/menu-xray
wget -O /usr/bin/menu-xtr "${api_url}/MENU/menu-xtr.sh" && chmod +x /usr/bin/menu-xtr
wget -O /usr/bin/backupmenu "${api_url}/MENU/backupmenu.sh" && chmod +x /usr/bin/backupmenu

#XRAY
wget -O /usr/bin/add-ws "${api_url}/XRAY/add-ws.sh" && chmod +x /usr/bin/add-ws
wget -O /usr/bin/add-vless "${api_url}/XRAY/add-vless.sh" && chmod +x /usr/bin/add-vless
wget -O /usr/bin/add-tr "${api_url}/XRAY/add-tr.sh" && chmod +x /usr/bin/add-tr
wget -O /usr/bin/add-xray "${api_url}/XRAY/add-xray.sh" && chmod +x /usr/bin/add-xray
wget -O /usr/bin/add-xtr "${api_url}/XRAY/add-xtr.sh" && chmod +x /usr/bin/add-xtr
wget -O /usr/bin/del-ws "${api_url}/XRAY/del-ws.sh" && chmod +x /usr/bin/del-ws
wget -O /usr/bin/del-vless "${api_url}/XRAY/del-vless.sh" && chmod +x /usr/bin/del-vless
wget -O /usr/bin/del-tr "${api_url}/XRAY/del-tr.sh" && chmod +x /usr/bin/del-tr
wget -O /usr/bin/del-xray "${api_url}/XRAY/del-xray.sh" && chmod +x /usr/bin/del-xray
wget -O /usr/bin/del-xtr "${api_url}/XRAY/del-xtr.sh" && chmod +x /usr/bin/del-xtr
wget -O /usr/bin/cek-ws "${api_url}/XRAY/cek-ws.sh" && chmod +x /usr/bin/cek-ws
wget -O /usr/bin/cek-vless "${api_url}/XRAY/cek-vless.sh" && chmod +x /usr/bin/cek-vless
wget -O /usr/bin/cek-tr "${api_url}/XRAY/cek-tr.sh" && chmod +x /usr/bin/cek-tr
wget -O /usr/bin/cek-xray "${api_url}/XRAY/cek-xray.sh" && chmod +x /usr/bin/cek-xray
wget -O /usr/bin/cek-xtr "${api_url}/XRAY/cek-xtr.sh" && chmod +x /usr/bin/cek-xtr
wget -O /usr/bin/renew-ws "${api_url}/XRAY/renew-ws.sh" && chmod +x /usr/bin/renew-ws
wget -O /usr/bin/renew-vless "${api_url}/XRAY/renew-vless.sh" && chmod +x /usr/bin/renew-vless
wget -O /usr/bin/renew-tr "${api_url}/XRAY/renew-tr.sh" && chmod +x /usr/bin/renew-tr
wget -O /usr/bin/renew-xray "${api_url}/XRAY/renew-xray.sh" && chmod +x /usr/bin/renew-xray
wget -O /usr/bin/renew-xtr "${api_url}/XRAY/renew-xtr.sh" && chmod +x /usr/bin/renew-xtr
wget -O /usr/bin/user-ws "${api_url}/XRAY/user-ws.sh" && chmod +x /usr/bin/user-ws
wget -O /usr/bin/user-vless "${api_url}/XRAY/user-vless.sh" && chmod +x /usr/bin/user-vless
wget -O /usr/bin/user-tr "${api_url}/XRAY/user-tr.sh" && chmod +x /usr/bin/user-tr
wget -O /usr/bin/user-xray "${api_url}/XRAY/user-xray.sh" && chmod +x /usr/bin/user-xray
wget -O /usr/bin/user-xtr "${api_url}/XRAY/user-xtr.sh" && chmod +x /usr/bin/user-xtr
wget -O /usr/bin/trial-ws "${api_url}/XRAY/trial-ws.sh" && chmod +x /usr/bin/trial-ws
wget -O /usr/bin/trial-vless "${api_url}/XRAY/trial-vless.sh" && chmod +x /usr/bin/trial-vless
wget -O /usr/bin/trial-tr "${api_url}/XRAY/trial-tr.sh" && chmod +x /usr/bin/trial-tr
wget -O /usr/bin/trial-xray "${api_url}/XRAY/trial-xray.sh" && chmod +x /usr/bin/trial-xray
wget -O /usr/bin/trial-xtr "${api_url}/XRAY/trial-xtr.sh" && chmod +x /usr/bin/trial-xtr

#OTHERS
wget -O /usr/bin/limit "${api_url}/OTHERS/limit-speed.sh" && chmod +x /usr/bin/limit
wget -O /usr/bin/add-host "${api_url}/OTHERS/add-host.sh" && chmod +x /usr/bin/add-host
wget -O /usr/bin/cekport "${api_url}/OTHERS/cekport.sh" && chmod +x /usr/bin/cekport
wget -O /usr/bin/certxray "${api_url}/OTHERS/certxray.sh" && chmod +x /usr/bin/certxray
wget -O /usr/bin/dns "${api_url}/OTHERS/dns.sh" && chmod +x /usr/bin/dns
wget -O /usr/bin/get-backres "${api_url}/OTHERS/get-backres.sh" && chmod +x /usr/bin/get-backres
wget -O /usr/bin/restart "${api_url}/OTHERS/restart.sh" && chmod +x /usr/bin/restart
wget -O /usr/bin/status "${api_url}/OTHERS/status.sh" && chmod +x /usr/bin/status
wget -O /usr/bin/cleaner "${api_url}/OTHERS/logcleaner.sh" && chmod +x /usr/bin/cleaner
wget -O /usr/bin/xp "${api_url}/OTHERS/xp.sh" && chmod +x /usr/bin/xp
wget -O /usr/bin/nf "https://gist.githubusercontent.com/linulinu/e4df2a6ca3959271270a5dcc8a61b363/raw/0c812dd502d43fe263253d27eccc28fb447f3cc1/check.sh" && chmod +x /usr/bin/nf

# Installing RAM & CPU Monitor
curl https://raw.githubusercontent.com/xxxserxxx/gotop/master/scripts/download.sh | bash && chmod +x gotop && sudo mv gotop /usr/local/bin/

echo -e "[ ${GB}INFO${NC} ] Autoscript Files Successfully Download !"
echo ""
sleep 2
clear

# Crontab settings
echo "0 6 * * * root reboot" >> /etc/crontab
echo "0 0 * * * root /usr/bin/xp" >> /etc/crontab
echo "*/2 * * * * root /usr/bin/cleaner" >> /etc/crontab

#Set Log Cleaner
if [ ! -f "/etc/cron.d/cleaner" ]; then
cat> /etc/cron.d/cleaner << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/2 * * * * root /usr/bin/cleaner
END
fi

systemctl restart cron
systemctl restart sshd

#Install Rclone
apt install rclone
printf "q\n" | rclone config
wget -O /root/.config/rclone/rclone.conf "${api_url}/OTHERS/rclone.conf" >/dev/null 2>&1

#Install Wondershape for limit bandwith
git clone  https://github.com/MrMan21/wondershaper.git
cd wondershaper
make install
cd
rm -rf wondershaper

cat > /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
menu
END

# remove unnecessary files
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove bind9*;
apt-get -y remove sendmail*
apt autoremove -y

#Autoscript Version
echo "1.0" > /home/ver

clear
echo ""
echo -e "${RB}      .-------------------------------------------.${NC}"
echo -e "${RB}      |${NC}      ${CB}Installation Has Been Completed${NC}      ${RB}|${NC}"
echo -e "${RB}      '-------------------------------------------'${NC}"
echo -e " "
echo -e ""
echo -e " "
echo -e "   Protocol Service   |   Network Protocol   "
echo -e " "
echo -e "   ${CB}Vmess Websocket${NC}         ${WB}|${NC}  ${CB} Websocket (CDN) TLS${NC}"
echo -e "   ${CB}Vless Websocket${NC}         ${WB}|${NC}  ${CB} Websocket (CDN) NTLS${NC}"
echo -e "   ${CB}Trojan Websocket${NC}        ${WB}|${NC}  ${CB} TCP XTLS${NC}"
echo -e "   ${CB}Vless TCP XTLS${NC}          ${WB}|${NC}  ${CB} TCP TLS${NC}"
echo -e "   ${CB}Trojan TCP TLS${NC}          ${WB}|${NC}"
echo -e " "
echo -e "            YAML Service Information           "
echo -e " "
echo -e "   ${CB}YAML XRAY VMESS WS${NC}"
echo -e "   ${CB}YAML XRAY VLESS WS${NC}"
echo -e "   ${CB}YAML XRAY TROJAN WS${NC}"
echo -e "   ${CB}YAML XRAY VLESS TCP XTLS${NC}"
echo -e "   ${CB}YAML XRAY TROJAN TCP TLS${NC}"
echo -e " "
echo -e "              Server Information                  "
echo -e " "
echo -e "   ${CB}Timezone: Asia/Jakarta (GMT +7)${NC}"
echo -e "   ${CB}Fail2Ban: [ON]${NC}"
echo -e "   ${CB}Deflate: [ON]${NC}"
echo -e "   ${CB}IPtables: [ON]${NC}"
echo -e "   ${CB}Auto-Reboot: [ON]${NC}"
echo -e "   ${CB}IPV6: [OFF]${NC}"
echo -e ""
echo -e "   ${CB}Autoreboot On 06.00 GMT +8${NC}"
echo -e "   ${CB}Automatic Delete Expired Account${NC}"
echo -e "   ${CB}Bandwith Monitor${NC}"
echo -e "   ${CB}RAM & CPU Monitor${NC}"
echo -e "   ${CB}Check Login User${NC}"
echo -e "   ${CB}Check Created Config${NC}"
echo -e "   ${CB}Automatic Clear Log${NC}"
echo -e "   ${CB}Media Checker${NC}"
echo -e "   ${CB}DNS Changer${NC}"
echo -e " "
echo -e "               Network Port Service              "
echo -e " "
echo -e "   ${CB}HTTP: 80${NC}"
echo -e "   ${CB}HTTPS: 443${NC}"
echo -e " "
echo ""
secs_to_human "$(($(date +%s) - ${start}))"
echo ""
echo -ne "${YB}[ WARNING ] Reboot now ? (Y/N)${NC} : "
read REDDIR
if [ "$REDDIR" == "${REDDIR#[Yy]}" ]; then
    rm -r setup.sh
	clear
    menu
else
    rm -r setup.sh
    reboot
fi
