#!/bin/bash
# TUI MENU SYSTEM

main_menu() {
    while true; do
        choice=$(whiptail --title "SAID_TÉCH VPN MAIN MENU" --menu "Choose an option" 20 60 10 \
            "1" "Install Protocols" \
            "2" "User Management" \
            "3" "Firewall Configuration" \
            "4" "SSL Certificates" \
            "5" "Server Information" \
            "6" "Connection Logs" \
            "7" "Update System" \
            "8" "Exit" 3>&1 1>&2 2>&3)
        
        case $choice in
            1) protocol_menu ;;
            2) user_menu ;;
            3) source utils/firewall.sh && configure_firewall ;;
            4) source utils/certbot.sh && manage_certificates ;;
            5) show_server_info ;;
            6) show_logs ;;
            7) update_system ;;
            8) exit 0 ;;
            *) whiptail --msgbox "Invalid option" 10 40 ;;
        esac
    done
}

protocol_menu() {
    choice=$(whiptail --title "PROTOCOL SELECTION" --menu "Choose protocol to install" 20 60 10 \
        "1" "OpenVPN" \
        "2" "SSH + WebSocket" \
        "3" "SSH over SSL/Stunnel" \
        "4" "V2Ray (VMess/VLess/Reality)" \
        "5" "Shadowsocks" \
        "6" "Trojan" \
        "7" "Psiphon" \
        "8" "Back" 3>&1 1>&2 2>&3)
    
    case $choice in
        1) source modules/openvpn.sh && install_openvpn ;;
        2) source modules/openssh.sh && install_websocket ;;
        3) source modules/stunnel.sh && install_stunnel ;;
        4) source modules/v2ray.sh && install_v2ray ;;
        5) source modules/shadowsocks.sh && install_shadowsocks ;;
        6) source modules/trojan.sh && install_trojan ;;
        7) source modules/psiphon.sh && install_psiphon ;;
        *) return ;;
    esac
}

user_menu() {
    choice=$(whiptail --title "USER MANAGEMENT" --menu "Choose action" 15 50 5 \
        "1" "Add User" \
        "2" "List Users" \
        "3" "Extend Expiry" \
        "4" "Delete User" \
        "5" "Back" 3>&1 1>&2 2>&3)
    
    case $choice in
        1) add_user ;;
        2) list_users ;;
        3) extend_expiry ;;
        4) delete_user ;;
        *) return ;;
    esac
}

add_user() {
    protocol=$(whiptail --menu "Select Protocol" 15 40 5 \
        "OpenVPN" "" \
        "SSH" "" \
        "Shadowsocks" "" \
        "Trojan" "" \
        "V2Ray" "" 3>&1 1>&2 2>&3)
    
    username=$(whiptail --inputbox "Enter username:" 8 40 3>&1 1>&2 2>&3)
    password=$(whiptail --passwordbox "Enter password:" 8 40 3>&1 1>&2 2>&3)
    expiry=$(date -d "+30 days" +%F)
    
    jq --arg user "$username" --arg pass "$password" --arg proto "$protocol" --arg expiry "$expiry" \
        '.[$user] = {"password": $pass, "protocol": $proto, "expiry": $expiry}' \
        "$DB_FILE" > tmp && mv tmp "$DB_FILE"
    
    whiptail --msgbox "$protocol user $username created!" 10 40
}

show_server_info() {
    whiptail --title "SERVER INFORMATION" --msgbox \
        "IP Address: $SERVER_IP\nISP: $ISP_INFO\nTimezone: $TIMEZONE\nAdmin Email: $ADMIN_EMAIL\nDomain: $DOMAIN" 15 60
}