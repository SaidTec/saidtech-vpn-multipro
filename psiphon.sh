#!/bin/bash
# PSIPHON INSTALLATION

install_psiphon() {
    echo -e "${YELLOW}Installing Psiphon server...${NC}"
    
    # Download and install
    wget https://psiphon.ca/psiphon3-linux-x86_64.tar.gz
    tar -xvf psiphon3-linux-x86_64.tar.gz -C /usr/local/bin/
    chmod +x /usr/local/bin/psiphon-tunnel-core
    
    # Create config
    cat > /etc/psiphon.conf <<EOF
{
    "PropagationChannelId": "FFFFFFFFFFFFFFFF",
    "SponsorId": "FFFFFFFFFFFFFFFF",
    "Server": {
        "Protocol": "SSH",
        "BindAddress": [":$PSIPHON_PORT"],
        "ObfuscatedSSHKey": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    }
}
EOF

    # Create service
    cat > /etc/systemd/system/psiphon.service <<EOF
[Unit]
Description=Psiphon Server
After=network.target

[Service]
ExecStart=/usr/local/bin/psiphon-tunnel-core -config /etc/psiphon.conf
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now psiphon
    
    echo -e "${GREEN}Psiphon server installed on port $PSIPHON_PORT!${NC}"
}