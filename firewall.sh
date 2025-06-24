#!/bin/bash
# FIREWALL MANAGEMENT

configure_firewall() {
    echo -e "${YELLOW}Configuring firewall...${NC}"
    
    # Enable UFW
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow core ports
    ufw allow $SSH_PORT/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Allow protocol-specific ports
    ufw allow $OPENVPN_PORTS/udp
    ufw allow $WEBSOCKET_PORT/tcp
    ufw allow $STUNNEL_PORT/tcp
    ufw allow $SHADOWSOCKS_PORT/tcp
    ufw allow $TROJAN_PORT/tcp
    ufw allow $PSIPHON_PORT/tcp
    
    ufw --force enable
    systemctl enable ufw
    
    # Setup port forwarding
    iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $V2RAY_HTTP_PORT
    iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port $V2RAY_HTTPS_PORT
    netfilter-persistent save
    
    echo -e "${GREEN}Firewall configured successfully!${NC}"
}