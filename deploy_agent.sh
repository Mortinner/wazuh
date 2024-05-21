#!/bin/bash
#       Filename:-              deploy_agent.sh
#       Version:-               1.0
#       Updated:-               21/05/2024
#       Author:-                Marcos Arroyo
#       Brief descn:-           Deploy Wazuh-agents remotely
#                               This script must be called from wazuh-sondas.sh
#******************************************************************************
# Update History
#******************************************************************************
# Ver   Date            Who             Update
#
#******************************************************************************

# Variables
# Set Parameter into variable
WAZUH_SERVER_IP=$1

# Funtions
# Check if wazuh-agent is installed, and install it if not
check_wazuh_agent() {
    if ! command -v wazuh-agent &> /dev/null; then
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: wazuh-agent not found on remote host. Installing wazuh-agent..."		
	set_parts
    else
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: wazuh-agent is already installed on remote host."
	exit 1
    fi
}

# Funtion for setting package agent and download urls for diferent OS
set_parts(){
    echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: Checking remote OS and updating sources..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq
        if [ $? -ne 0 ]; then
            echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: There was a problem updating sources on remote host. Exiting..."
            exit 1
        fi
        pkg_manager="apt-get"
        pkg_manager_system="dpkg -i ./"
        package_url="https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.4-1_amd64.deb"
        package_name="wazuh-agent_4.7.4-1_amd64.deb"
    elif command -v yum &> /dev/null; then
        sudo yum install -y -q epel-release
        if [ $? -ne 0 ]; then
            echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: There was a problem updating sources on remote host. Exiting..."
            exit 1
        fi
        pkg_manager="yum"
        pkg_manager_system="rpm -ihv "
        package_url="https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.4-1.x86_64.rpm"
        package_name="wazuh-agent-4.7.4-1.x86_64.rpm"
    elif command -v dnf &> /dev/null; then
        pkg_manager="dnf"
        pkg_manager_system="rpm -ihv "
        package_url="https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.4-1.x86_64.rpm"
        package_name="wazuh-agent-4.7.4-1.x86_64.rpm"
    else
        echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: Package agent not supported on remote host. Please install wget manually."
        exit 1
    fi
    check_wget
}

# Check if wget is installed, and install it if not
check_wget() {
    if ! command -v wget &> /dev/null; then
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: wget not found on remote host. Installing wget..."		
	sudo $pkg_manager install -y wget > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: There was a problem installing wget on remote host system. Exiting..."
            exit 1
        fi
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: wget installed on remote host successfully."
    else
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: wget is already on remote host installed."
    fi
    run_launcher
}

run_launcher (){
    wget $package_url > /dev/null 2>&1 && sudo WAZUH_MANAGER=$WAZUH_SERVER_IP WAZUH_AGENT_NAME=$(hostname) $pkg_manager_system$package_name > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: There was a problem installing wazuh-agent on remote host system. Exiting..."
    else
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: wazuh-agent installed on remote host successfully."
        sleep 5
        sudo systemctl enable wazuh-agent > /dev/null 2>&1
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: Starting service wazuh-agent on remote host."
        sudo systemctl start wazuh-agent
	if [ $? -ne 0 ]; then
            echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: wazuh-agent service not started on remote host. Exiting..."
            exit 1
        fi
	echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: wazuh-agent service started on remote host."
    fi
    sudo rm $package_name
    sudo rm deploy_agent.sh
}

# Main
check_wazuh_agent
