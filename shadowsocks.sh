#!/bin/bash
# SHADOWSOCKS INSTALLATION

install_shadowsocks() {
    echo -e "${YELLOW}Installing Shadowsocks with obfuscation...${NC}"
    
    # Install dependencies
    apt install -y python3-pip libsodium-dev
    pip3 install shadowsocks
    
    # Generate config
    local password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
    local method="chacha20-ietf-poly1305"
    
    cat > /etc/shadowsocks.json <<EOF
{
    "server":"0.0.0.0",
    "server_port":$SHADOWSOCKS_PORT,
    "password":"$password",
    "method":"$method",
    "timeout":300,
    "plugin":"obfs-server",
    "plugin_opts":"obfs=http"
}
EOF

    # Create service
    cat > /etc/systemd/system/shadowsocks.service <<EOF
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks.json
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now shadowsocks
    
    # Add user to database
    local username=$(whiptail --inputbox "Enter Shadowsocks username:" 8 40 3>&1 1>&2 2>&3)
    local expiry=$(date -d "+30 days" +%F)
    
    jq --arg user "$username" --arg pass "$password" --arg expiry "$expiry" \
        '.[$user] = {"protocol": "shadowsocks", "password": $pass, "expiry": $expiry}' \
        "$DB_FILE" > tmp && mv tmp "$DB_FILE"
    
    echo -e "${GREEN}Shadowsocks installation completed!${NC}"
    echo -e "Share these details with your user:"
    echo -e "Server: $DOMAIN"
    echo -e "Port: $SHADOWSOCKS_PORT"
    echo -e "Password: $password"
    echo -e "Method: $method"
    echo -e "Plugin: obfs (http)"
}