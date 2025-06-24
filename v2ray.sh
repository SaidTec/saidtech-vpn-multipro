#!/bin/bash
# V2RAY WITH 80/443 SUPPORT

install_v2ray() {
    echo -e "${YELLOW}Installing V2Ray with ports 80/443...${NC}"
    
    # Install V2Ray
    bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
    
    # Generate configuration
    local uuid=$(uuidgen)
    local path="/$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)"
    
    cat > /usr/local/etc/v2ray/config.json <<EOF
{
  "inbounds": [
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": [{ "id": "$uuid" }]
      },
      "streamSettings": {
        "network": "tcp",
        "tcpSettings": {
          "header": {
            "type": "http",
            "response": {
              "version": "1.1",
              "status": "200",
              "reason": "OK",
              "headers": {
                "Content-Type": ["application/octet-stream"],
                "Cache-Control": ["no-store"],
                "Connection": ["keep-alive"]
              }
            }
          }
        }
      }
    },
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [{ "id": "$uuid" }],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [{
            "certificateFile": "/etc/letsencrypt/live/$DOMAIN/fullchain.pem",
            "keyFile": "/etc/letsencrypt/live/$DOMAIN/privkey.pem"
          }]
        }
      }
    }
  ],
  "outbounds": [{"protocol": "freedom"}]
}
EOF

    # Add user to database
    local username=$(whiptail --inputbox "Enter V2Ray username:" 8 40 3>&1 1>&2 2>&3)
    local expiry=$(date -d "+30 days" +%F)
    
    jq --arg user "$username" --arg uuid "$uuid" --arg expiry "$expiry" \
        '.[$user] = {"protocol": "v2ray", "uuid": $uuid, "expiry": $expiry}' \
        "$DB_FILE" > tmp && mv tmp "$DB_FILE"
    
    # Restart service
    systemctl restart v2ray
    
    echo -e "${GREEN}V2Ray installation completed on ports 80/443!${NC}"
    echo -e "Share these details with your user:"
    echo -e "Server: $DOMAIN"
    echo -e "Ports: 80 (VMess), 443 (VLess)"
    echo -e "UUID: $uuid"
}