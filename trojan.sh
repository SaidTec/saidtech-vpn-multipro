#!/bin/bash
# TROJAN INSTALLATION

install_trojan() {
    echo -e "${YELLOW}Installing Trojan with TLS encryption...${NC}"
    
    # Install Trojan
    apt install -y trojan
    
    # Generate config
    local password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)
    
    cat > /etc/trojan/config.json <<EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": $TROJAN_PORT,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": ["$password"],
    "ssl": {
        "cert": "/etc/letsencrypt/live/$DOMAIN/fullchain.pem",
        "key": "/etc/letsencrypt/live/$DOMAIN/privkey.pem"
    }
}
EOF

    systemctl restart trojan
    
    # Add user to database
    local username=$(whiptail --inputbox "Enter Trojan username:" 8 40 3>&1 1>&2 2>&3)
    local expiry=$(date -d "+30 days" +%F)
    
    jq --arg user "$username" --arg pass "$password" --arg expiry "$expiry" \
        '.[$user] = {"protocol": "trojan", "password": $pass, "expiry": $expiry}' \
        "$DB_FILE" > tmp && mv tmp "$DB_FILE"
    
    echo -e "${GREEN}Trojan installation completed!${NC}"
    echo -e "Share these details with your user:"
    echo -e "Server: $DOMAIN"
    echo -e "Port: $TROJAN_PORT"
    echo -e "Password: $password"
}