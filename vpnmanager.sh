#!/usr/bin/env bash

function error () {
    if [[ "$NORMALERRORS" == "off" ]]; then
        if [[ "$1" == "01" ]]; then
        echo "Error (Code: 01 - Bro, there is no VPN active)"
        
        elif [[ "$1" == "02" ]]; then
            echo "Error (Code: 02 - Hey, did you even write anything?)"   
        
        elif [[ "$1" == "03" ]]; then
            echo "Error (Code: 03 - Woah buddy, we're managing VPNs right now)"
        
        elif [[ "$1" == "04" ]]; then
            echo "Error (Code: 04 - Dude, do you wanna choose a valid option?)"
        
        elif [[ "$1" == "05" ]]; then
            echo "Error (Code: 05 - Did you remember to register your VPN connections? (Manage -> Add VPN))"
        fi
    else
        if [[ "$1" == "01" ]]; then
        echo "Error (Code: 01 - No VPN active)"
        
        elif [[ "$1" == "02" ]]; then
            echo "Error (Code: 02 - No choice recieved)"   
        
        elif [[ "$1" == "03" ]]; then
            echo "Error (Code: 03 - Not a VPN connection)"
        
        elif [[ "$1" == "04" ]]; then
            echo "Error (Code: 04 - Valid option not selected)"
        
        elif [[ "$1" == "05" ]]; then
            echo "Error (Code: 05 - No valid VPN connections registered. (Manage -> Add VPN))"
        fi        
    fi
}

function firstsetup () {
    echo "Preparing first time setup..."

    mkdir -p "$HOME/.config/vpnmanager"
    cd "$HOME/.config/vpnmanager" || exit 2

    touch config.conf
    CONFIG_FILE="$HOME/.config/vpnmanager/config.conf"

    DEFAULT_CONFIG="# A default config file for
# this script. Not much here yet.

# The communication protocol that is used to connect.
current_protocol=udp

# Switch between normal-looking error messages and more casual ones.
# normal_errors=on for normal-looking, normal_errors=off for casual mode.
normal_errors=on
"
    echo "$DEFAULT_CONFIG" > "$CONFIG_FILE"

    clear
}

function main () {    
    echo -e "What would you like to do?\n"
    echo "[0] Connect"
    echo "[1] Disconnect"
    echo "[2] Manage"
    echo -e "[3] Exit\n"

    read MENUCHOICE

    if [[ "${MENUCHOICE}" == "0" ]]; then
            if [[ -n "$(nmcli con show | grep vpn | grep "$CURRENTPROTOCOL")" ]]; then
                echo ""
                echo "Select one of the following: "
                echo -e "$(nmcli con show | grep vpn | grep "$CURRENTPROTOCOL")\n"

                read VPNCHOICE

                if [[ -z "${VPNCHOICE}" ]]; then
                    error "02"
                    exit 22
                else
                    nmcli con up "${VPNCHOICE}"
                fi
            else
                error "05"
            fi
    elif [[ "${MENUCHOICE}" == "1" ]]; then
        if [[ -z "$(nmcli con show --active | grep vpn | grep "$CURRENTPROTOCOL")" ]]; then
            error "01"
            exit 3
        else
            echo ""
            echo "Select one of the following: "
            echo -e "$(nmcli con show --active | grep vpn)\n"

            read VPNCHOICEDIS
            
            if [[ -z "${VPNCHOICEDIS}" ]]; then
                error "02"
                exit 22
            else
                nmcli con down "${VPNCHOICEDIS}"
            fi
        fi

    elif [[ "${MENUCHOICE}" == "2" ]]; then
        echo ""
        echo -e "Options:\n"
        echo "[0] Add VPN"
        echo "[1] Remove VPN"
        echo "[2] Change username"
        echo "[3] Change password"
        echo -e "[4] Change communication protocol\n"

        read OPTIONSCHOICE

        if [[ "${OPTIONSCHOICE}" == "0" ]]; then
            read -p "Enter the file path: " OVPNFILE
            nmcli con import type openvpn file "${OVPNFILE}"
        
        elif [[ "${OPTIONSCHOICE}" == "1" ]]; then
            echo "Select one of the following:"
            echo -e "$(nmcli con show | grep vpn)\n"

            read CONNECTIONFORDELETE

            if [[ "${CONNECTIONFORDELETE}" == *".udp"* ]] || [[ "${CONNECTIONFORDELETE}" == *".tcp"* ]]; then
                nmcli con delete "${CONNECTIONFORDELETE}"
            else
                error "03"
            fi
        elif [[ "${OPTIONSCHOICE}" == "2" ]]; then
            echo "Select one of the following:"
            echo -e "$(nmcli con show | grep vpn)\n"

            read CONFORNAMECHANGE

            echo ""
            read -p "Enter the new username: " NEWUSERNAME
            nmcli con modify "${CONFORNAMECHANGE}" vpn.user-name "${NEWUSERNAME}"

        elif [[ "${OPTIONSCHOICE}" == "3" ]]; then
            echo "Select one of the following:"
            echo -e "$(nmcli con show | grep vpn)\n"

            read CONFORPASSCHANGE

            echo ""
            read -sp "Enter the new password: " NEWPASSWORD
            nmcli con modify "${CONFORPASSCHANGE}" vpn.secrets "password=${NEWPASSWORD}"
            echo ""
        
        elif [[ "${OPTIONSCHOICE}" == "4" ]]; then
            echo ""
            echo "Select one of the following: "
            echo "[0] UDP"
            echo -e "[1] TCP\n"

            read PROTOCOLCHOICE

            if [[ "${PROTOCOLCHOICE}" == "0" ]]; then
                if [[ "${CURRENTPROTOCOL}" == "udp" ]]; then
                    sed -i 's/current_protocol=udp/current_protocol=udp/' "$HOME/.config/vpnmanager/config.conf"
                elif [[ "${CURRENTPROTOCOL}" == "tcp" ]]; then
                    sed -i 's/current_protocol=tcp/current_protocol=udp/' "$HOME/.config/vpnmanager/config.conf"
                fi
            elif [[ "${PROTOCOLCHOICE}" == "1" ]]; then
                if [[ "${CURRENTPROTOCOL}" == "udp" ]]; then
                    sed -i 's/current_protocol=udp/current_protocol=tcp/' "$HOME/.config/vpnmanager/config.conf"
                elif [[ "${CURRENTPROTOCOL}" == "tcp" ]]; then
                    sed -i 's/current_protocol=tcp/current_protocol=tcp/' "$HOME/.config/vpnmanager/config.conf"
                fi
            else
                error "02"
                exit 22
            fi

        else
            echo ""
            error "04"
        fi

    elif [[ "${MENUCHOICE}" == "3" ]]; then
        echo ""
        echo "Exiting..."
        exit 0
    else
        echo ""
        error "04"
        exit 3
    fi
}


# Reading the config file and setting up appropriate variables

# Checking if this is the first time you're running this script
if [ -f "$HOME/.config/vpnmanager/config.conf" ]; then
    CONFIG_FILE="$HOME/.config/vpnmanager/config.conf" # If not, it declares the var for the config file...
    
    if [[ "$(grep current_protocol $CONFIG_FILE)" == "current_protocol=udp" ]]; then # ...goes through a bunch of config reads...
        CURRENTPROTOCOL="udp"
    elif [[ "$(grep current_protocol $CONFIG_FILE)" == "current_protocol=tcp" ]]; then
        CURRENTPROTOCOL="tcp"
    fi

    if [[ "$(grep normal_errors $CONFIG_FILE)" == "normal_errors=off" ]]; then
        NORMALERRORS="off"
    elif [[ "$(grep normal_errors $CONFIG_FILE)" == "normal_errors=on" ]]; then
        NORMALERRORS="on"
    else
        NORMALERRORS="on"
    fi
 
    main # ...and runs the main function
else
    firstsetup # If it is it goes through the firstsetup function first...
    main # ...and then triggers the main function
fi