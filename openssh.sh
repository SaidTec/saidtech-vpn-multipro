#!/bin/bash
# OPENSSH WITH 80/443 SUPPORT

install_openssh() {
    echo -e "${YELLOW}Configuring OpenSSH with ports 80/443...${NC}"
    
    # Install required packages
    apt install -y dropbear gost
    
    # Configure Dropbear (port 443)
    cat > /etc/default/dropbear <<EOF
NO_START=0
DROPBEAR_PORT=443
DROPBEAR_EXTRA_ARGS="-p 80"
DROPBEAR_BANNER="$BANNER_DIR/ssh_banner"
EOF

    # Create WebSocket tunnel
    wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
    gzip -d gost-linux-amd64-2.11.5.gz
    mv gost-linux-amd64-2.11.5 /usr/bin/gost
    chmod +x /usr/bin/gost
    
    cat > /etc/systemd/system/ssh-websocket.service <<EOF
[Unit]
Description=SSH WebSocket Tunnel
After=network.target

[Service]
ExecStart=/usr/bin/gost -L "ws://0.0.0.0:8888?path=/ssh"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # Create SSL tunnel
    cat > /etc/stunnel/stunnel.conf <<EOF
cert = /etc/letsencrypt/live/$DOMAIN/fullchain.pem
key = /etc/letsencrypt/live/$DOMAIN/privkey.pem
[ssh]
accept = 465
connect = 127.0.0.1:22
EOF

    systemctl daemon-reload
    systemctl enable --now dropbear
    systemctl enable --now ssh-websocket
    systemctl enable --now stunnel4

    # Configure banner
    sed -i 's/#Banner none/Banner \/etc\/saidtech\/banners\/ssh_banner/' /etc/ssh/sshd_config
    systemctl restart sshd

    echo -e "${GREEN}OpenSSH configured on ports 22, 80, 443, 465, 8888!${NC}"
}