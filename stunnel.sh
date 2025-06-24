#!/bin/bash
# STUNNEL FOR SSH ON 80/443

install_stunnel() {
    echo -e "${YELLOW}Configuring Stunnel for SSH on port 80/443...${NC}"
    
    # Install Stunnel
    apt install -y stunnel4
    
    # Create configuration
    cat > /etc/stunnel/stunnel.conf <<EOF
cert = /etc/letsencrypt/live/$DOMAIN/fullchain.pem
key = /etc/letsencrypt/live/$DOMAIN/privkey.pem

[ssh-https]
accept = 443
connect = 127.0.0.1:22

[ssh-http]
accept = 80
connect = 127.0.0.1:8888
EOF

    # Enable service
    sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
    systemctl restart stunnel4
    
    echo -e "${GREEN}Stunnel configured for SSH on ports 80/443!${NC}"
}