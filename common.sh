#!/bin/bash
# COMMON FUNCTIONS MODULE

check_root() {
    [ "$(id -u)" != "0" ] && {
        echo -e "${RED}This script must be run as root${NC}" >&2
        exit 1
    }
}

detect_os() {
    if ! grep -qiP 'ubuntu|debian' /etc/os-release; then
        echo -e "${RED}Unsupported OS. Use Debian or Ubuntu.${NC}"
        exit 1
    fi
}

validate_ports() {
    local ports=("80" "443" "22" "1194")
    for port in "${ports[@]}"; do
        if ss -tulpn | grep -q ":$port "; then
            echo -e "${RED}Port $port is already in use!${NC}"
            echo -e "${YELLOW}Please stop the conflicting service or choose different ports${NC}"
            exit 1
        fi
    done
}

setup_directories() {
    mkdir -p {$INSTALL_DIR,$LOG_DIR,$BANNER_DIR,$TMP_DIR}
}

create_database() {
    [ ! -f "$DB_FILE" ] && echo '{}' > "$DB_FILE"
}

authenticate() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════╗"
    echo -e "║      SAID_TÉCH PREMIUM VPN INSTALLER      ║"
    echo -e "╠══════════════════════════════════════════╣${NC}"
    
    local attempt=0
    while [ $attempt -lt 3 ]; do
        read -sp "Enter installation password: " input_pass
        echo
        [ "$input_pass" == "$PASSWORD" ] && return 0
        attempt=$((attempt + 1))
        echo -e "${RED}Incorrect password ($attempt/3 attempts)${NC}"
    done
    
    echo -e "${RED}Authentication failed. Exiting.${NC}"
    exit 1
}

load_banners() {
    cat > $BANNER_DIR/ssh_banner <<'EOF'
╔════════════════════════════════════════════╗
       🌐 SAID_TÉCH PREMIUM VPN SERVICE      
╠════════════════════════════════════════════╣
║ ✅ Connected: $(date +"%Y-%m-%d %H:%M:%S")                 
║ 📡 Protocol : SSH                         
║ 👤 Client   : $USER                       
║ ⏳ Expiry   : $(jq -r ".[\"$USER\"].expiry" $DB_FILE)
║ 📜 Note     : Stay ethical. No torrenting.
╚════════════════════════════════════════════╝
EOF

    cat > $BANNER_DIR/ovpn_banner <<'EOF'
╔════════════════════════════════════════════╗
       🌐 SAID_TÉCH PREMIUM VPN SERVICE      
╠════════════════════════════════════════════╣
║ ✅ Connected: $(date +"%Y-%m-%d %H:%M:%S")                 
║ 📡 Protocol : OpenVPN                     
║ 👤 Client   : $common_name                
║ ⏳ Expiry   : $(jq -r ".[\"$common_name\"].expiry" $DB_FILE)
║ 📜 Note     : Stay ethical. No torrenting.
╚════════════════════════════════════════════╝
EOF
}

setup_port_forwarding() {
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
    sysctl -p
    iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $V2RAY_HTTP_PORT
    iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port $V2RAY_HTTPS_PORT
    apt install -y iptables-persistent
    netfilter-persistent save
}