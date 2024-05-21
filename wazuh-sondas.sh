#!/bin/bash
#       Filename:-              wazuh-sondas.sh
#       Version:-               1.0
#       Updated:-               16/05/2024
#       Author:-                Marcos Arroyo
#       Brief descn:-           Collect info to deploy Wazuh-agents remotely
#                               This script must be called from sad_wazuh.sh
#******************************************************************************
# Update History
#******************************************************************************
# Ver   Date            Who             Update
#
#******************************************************************************

# Functions
# Ask for required data to deploy agent
ask_parameters() {
        read -p "$(date '+%d/%m/%Y %H:%M:%S') INFO: Please enter of this server which IP to use: " ip_server
        read -p "$(date '+%d/%m/%Y %H:%M:%S') INFO: Please enter the target server IP: " ip
        read -p "$(date '+%d/%m/%Y %H:%M:%S') INFO: Please enter the target server username: " user
        read -sp "$(date '+%d/%m/%Y %H:%M:%S') INFO: Please enter the target server password: " password
        echo
        check_parameters "$ip" "$user" "$password"
}

# Check if parameters are valid: not empty and IP with four digits between 0-255 separated by dots
check_parameters() {
        local ip=$1
        local user=$2
        local password=$3

        # Check if any parameter is empty
        if [[ -z "$ip" || -z "$user" || -z "$password" ]]; then
                echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: All parameters must be provided."
                ask_parameters
        fi

        # Validate IP address format
        if ! [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
                echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: Invalid IP address format."
                ask_parameters
        fi

        # Validate each octet is between 0 and 255
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
                if ((octet < 0 || octet > 255)); then
                        echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: Invalid number/s for the IP address."
                        ask_parameters
                fi
        done
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: Parameters appear ok. Lets check connectivity"
        check_connectivity "$ip" "$user" "$password"
}

# Check if sshpass is installed, and install it if not
check_sshpass() {
    if ! command -v sshpass &> /dev/null; then
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: sshpass not found. checking system and updating sources..."
        if command -v apt-get &> /dev/null; then
            pkg_manager="apt-get"
            sudo apt-get update -qq
        elif command -v yum &> /dev/null; then
            pkg_manager="yum"
            sudo yum install -y -q epel-release
        elif command -v dnf &> /dev/null; then
            pkg_manager="dnf"
        else
            echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: Package manager not supported. Please install sshpass manually."
            exit 1
        fi
		
	if [ $? -ne 0 ]; then
            echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: There was a problem updating the system. Exiting..."
            exit 1
        fi

        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: sshpass not found. Installing sshpass..."
	sudo $pkg_manager install -y sshpass > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: There was a problem installing sshpass on the system. Exiting..."
            exit 1
        fi

        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: sshpass installed successfully."
    else
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: sshpass is already installed."
    fi
}

# Check connectivity to the server using SSH
check_connectivity() {
        check_sshpass
        local ip=$1
        local user=$2
        local password=$3
        echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: Trying to connect to $ip with user $user and pasword ******** using SSH."
        if sshpass -p "$password" ssh -o StrictHostKeyChecking=accept-new "$user@$ip" exit &> /dev/null; then
                echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: Successfully connected to $ip using SSH."
                install_remote_agent
                run_again
        else
                echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR: Unable to reach $ip using SSH. Please check the IP address, username, or password."
                try_again
        fi
}

install_remote_agent(){
        sshpass -p "$password" ssh -o StrictHostKeyChecking=accept-new "$user@$ip" wget https://github.com/Mortinner/wazuh/raw/main/deploy_agent.sh && sudo bash ./deploy_agent.sh $ip_server
}

# Ask yes or no to user, to try again whole script removing variables
try_again() {
        read -p "$(date '+%d/%m/%Y %H:%M:%S') INFO: Would you like to try again? (yes/no): " YesOrNot
        if [[ "$YesOrNot" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                ask_parameters
        else
                echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: See you, bye bye"
                exit 0
        fi
}

# Ask yes or no to user, to run again whole script removing variables
run_again() {
        read -p "$(date '+%d/%m/%Y %H:%M:%S') INFO: Would you like to add another agent? (yes/no): " YesOrNot
        if [[ "$YesOrNot" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                ask_parameters
        else
                echo "$(date '+%d/%m/%Y %H:%M:%S') INFO: See you, bye bye"
                exit 0
        fi
}

# Main
ask_parameters
run_again
