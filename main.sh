#!/bin/bash
# SAID_TÉCH PREMIUM VPN INSTALLER - MAIN SCRIPT

# Load configuration
source config/settings.conf
source utils/menu.sh
source modules/common.sh

# Initialize installation
init_installation() {
    clear
    check_root
    detect_os
    validate_ports
    load_banners
    setup_directories
    create_database
    authenticate
    setup_port_forwarding
    main_menu
}

# Start the installation
init_installation