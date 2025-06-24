#!/bin/bash
# OPENVPN INSTALLATION

install_openvpn() {
    echo -e "${YELLOW}Installing OpenVPN on ports $OPENVPN_PORTS...${NC}"
    
    # Install OpenVPN
    apt install -y openvpn easy-rsa
    make-cadir /etc/openvpn/easy-rsa
    cd /etc/openvpn/easy-rsa
    
    # Setup PKI
    ./easyrsa init-pki
    ./easyrsa build-ca nopass
    ./easyrsa gen-dh
    ./easyrsa build-server-full server nopass
    
    # Generate config
    cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun
ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key
dh /etc/openvpn/easy-rsa/pki/dh.pem
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
keepalive 10 120
tls-crypt /etc/openvpn/easy-rsa/pki/ta.key
cipher AES-256-GCM
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn-status.log
verb 3
script-security 2
client-connect /etc/openvpn/client-connect.sh
EOF

    # Create client connect script
    cat > /etc/openvpn/client-connect.sh <<'EOF'
#!/bin/bash
USERNAME=$common_name
source /etc/saidtech/banners/ovpn_banner > /tmp/vpn_banner_$USERNAME
cat /tmp/vpn_banner_$USERNAME
rm /tmp/vpn_banner_$USERNAME
EOF
    chmod +x /etc/openvpn/client-connect.sh
    
    # Enable multi-port
    for port in $(echo $OPENVPN_PORTS); do
        [ "$port" != "1194" ] && {
            cp /etc/openvpn/server.conf /etc/openvpn/server-$port.conf
            sed -i "s/port 1194/port $port/" /etc/openvpn/server-$port.conf
            systemctl start openvpn@server-$port
        }
    done
    
    # Start main service
    systemctl enable --now openvpn@server
    
    echo -e "${GREEN}OpenVPN installation completed!${NC}"
}