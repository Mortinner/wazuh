#!/bin/bash
#       Filename:-              sad_wazuh.sh
#       Version:-               1.0
#       Updated:-               15/05/2024
#       Author:-                Marcos Arroyo
#       Brief descn:-           Deploy or re-deploy Wazuh-manager and call or
#                               not wazuh-sondas.sh to install agents remotely
#******************************************************************************
# Update History
#******************************************************************************
# Ver   Date            Who             Update
#
#******************************************************************************
# License
# This program is a free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License (version 2) as published
# by the FSF - Free Software Foundation.
#******************************************************************************

# Functions
# Check if script was launched with sudo
check_sudo() {
        clear
        if [ "$(id -u)" != "0" ]; then
                echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: Please, run the script with superuser privileges (sudo)."
                exit 1
        fi
}

# Show help message
show_help() {
        echo "Usage: $0 [OPTION]"
        echo "Options:"
        echo "  -a, --all        Installs Wazuh-manager locally and then prompts for the installation of sondas (Wazuh-agent)"
        echo "  -o, --overwrite  Overwrite Wazuh-manager locally"
        echo "  -m, --manager    Only installs Wazuh-manager locally"
        echo "  -u, --uninstall  Only uninstalls Wazuh-manager locally"
        echo "  -s, --sondas     Prompts for sondas (Wazuh-agent) to install"
        echo "  -h, --help       Shows this help"
        exit 1
}

# Check the number of parameters and call the corresponding function
check_params() {
        check_sudo
        if [ "$#" -ne 1 ]; then
                echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: Invalid number of parameters."
                show_help
        fi

        case $1 in
                -a|--all)
                        welcome
                        install_manager
                        install_sondas
                        ;;
                -o|--overwrite)
                        welcome
                        overwrite_manager
                        ;;
                -m|--manager)
                        welcome
                        install_manager
                        ;;
                -u|--uninstall)
                        welcome
                        uninstall_manager
                        ;;
                -s|--sondas)
                        welcome
                        install_sondas
                        ;;
                -h|--help)
                        show_help
                        ;;
                *)
                        echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: Invalid option."
                        show_help
                        ;;
        esac
}

# Function to install manager
install_manager() {
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: Installing and configuring Wazuh server, Wazuh indexer, Wazuh dashboard."
        curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
        rm wazuh-install.sh wazuh-install-files.tar > /dev/null 2>&1
}

# Function to overwrite manager
overwrite_manager() {
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: Overwrite Wazuh server, Wazuh indexer, Wazuh dashboard."
        curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh && sudo bash ./wazuh-install.sh -o
        rm wazuh-install.sh wazuh-install-files.tar > /dev/null 2>&1
}

# Function to uninstall manager
uninstall_manager() {
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: Installing and configuring Wazuh server, Wazuh indexer, Wazuh dashboard."
        curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh && sudo bash ./wazuh-install.sh -u
        rm wazuh-install.sh wazuh-install-files.tar > /dev/null 2>&1
}

# Function to install sondas
install_sondas() {
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: Installing sondas..."
        #sudo bash ./wazuh-sondas.sh
        wget -q https://github.com/Mortinner/wazuh/raw/main/wazuh-sondas.sh && sudo bash ./wazuh-sondas.sh
        sudo rm wazuh-sondas.sh
}

welcome(){
echo "+------------------------------------------------------------------------+
|                              WELCOME TO                                |
|                                                                        |
|                       SSSSSS      A      DDDDD                         |
|                       S          A A     D    D                        |
|                       SSSSSS    A   A    D     D                       |
|                            S   AAAAAAA   D    D                        |
|                       SSSSSS  A       A  DDDDD                         |
|                                                                        |
|                       SOC AUTOMATION DEPLOYEMENT                       |
+------------------------------------------------------------------------+"
}

# MAIN
check_params "$@"

