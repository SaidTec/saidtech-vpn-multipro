#!/bin/bash
# SSL CERTIFICATE MANAGEMENT

manage_certificates() {
    if [ -z "$DOMAIN" ]; then
        DOMAIN=$(whiptail --inputbox "Enter your domain name:" 8 60 3>&1 1>&2 2>&3)
        [ -z "$DOMAIN" ] && return
    fi
    
    # Stop services using 80/443
    systemctl stop nginx
    systemctl stop v2ray
    
    # Install Certbot
    apt install -y certbot
    
    # Obtain certificate
    certbot certonly --standalone --agree-tos --non-interactive \
        -m "$ADMIN_EMAIL" -d "$DOMAIN" \
        --preferred-challenges http-01
    
    # Create renewal hook
    echo "#!/bin/bash" > /etc/letsencrypt/renewal-hooks/deploy/restart-services.sh
    echo "systemctl restart stunnel4" >> /etc/letsencrypt/renewal-hooks/deploy/restart-services.sh
    echo "systemctl restart v2ray" >> /etc/letsencrypt/renewal-hooks/deploy/restart-services.sh
    echo "systemctl restart nginx" >> /etc/letsencrypt/renewal-hooks/deploy/restart-services.sh
    chmod +x /etc/letsencrypt/renewal-hooks/deploy/restart-services.sh
    
    echo -e "${GREEN}SSL certificate for $DOMAIN configured!${NC}"
}