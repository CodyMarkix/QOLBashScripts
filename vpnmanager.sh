#!/usr/bin/env bash

declare -A abnormalerrorsarr=(
    [01]="Bro, there is no VPN active"
    [02]="Hey, did you even write anything?"
    [03]="Woah buddy, we're managing VPNs right now"
    [04]="Dude, do you wanna choose a valid option?"
    [05]="Did you remember to register your VPN connections? (Manage -> Add VPN)"
)
declare -A normalerrorsarr=(
    [01]="No VPN active"
    [02]="No choice recieved"
    [03]="Not a VPN connection"
    [04]="Valid option not selected"
    [05]="No valid VPN connections registered. (Manage -> Add VPN)"
)

error () {
    if [[ "$normalerrors" == "off" ]]; then
        echo "Error (Code: ${1} - ${abnormalerrorsarr[$1]})"
    else
        echo "Error (Code: ${1} - ${normalerrorsarr[$1]})"
    fi
}

firstsetup () {
    echo "Preparing first time setup..."

    mkdir -p "$HOME/.config/vpnmanager"
    cd "$HOME/.config/vpnmanager" || exit 2

    touch config.conf
    config_file="$HOME/.config/vpnmanager/config.conf"

    default_config="# A default config file for
# this script. Not much here yet.

# The communication protocol that is used to connect.
current_protocol=udp

# Switch between normal-looking error messages and more casual ones.
# normal_errors=on for normal-looking, normal_errors=off for casual mode.
normal_errors=on
"
    echo "$default_config" > "$config_file"

    clear
}

# Main menu function
mainmenu () {    
    printf "What would you like to do?\n\n[0] Connect\n[1] Disconnect\n[2] Manager\n[3] Exit\n\n"
    read -r menuchoice

    if [[ "${menuchoice}" == "0" ]]; then
        connectmenu

    elif [[ "${menuchoice}" == "1" ]]; then
        disconnectmenu

    elif [[ "${menuchoice}" == "2" ]]; then
        optionsmenu

    elif [[ "${menuchoice}" == "3" ]]; then
        exitfunc
    else
        echo ""
        error "04"
        exit 3
    fi
}

# Function for connecting to the VPN
connectmenu () {
    if [[ -n "$(nmcli con show | grep vpn | grep "$currentprotocol")" ]]; then
        echo ""
        echo "Select one of the following: "
        echo -e "$(nmcli con show | grep vpn | grep "$currentprotocol")\n"

        read -r vpnchoice

        if [[ -z "${vpnchoice}" ]]; then
            error "02"
            exit 22
        else
            nmcli con up "${vpnchoice}"
        fi
    else
        error "05"
    fi 
}

disconnectmenu () {
    if [[ -z "$(nmcli con show --active | grep vpn | grep "$currentprotocol")" ]]; then
        error "01"
        exit 3
    else
        echo ""
        echo "Select one of the following: "
        echo -e "$(nmcli con show --active | grep vpn)\n"

        read -r vpnchoicedis
        
        if [[ -z "${vpnchoicedis}" ]]; then
            error "02"
            exit 22
        else
            nmcli con down "${vpnchoicedis}"
        fi
    fi
}

optionsmenu () {

    printf "\nOptions:\n\n[0] Add VPN\n[1] Remove VPN\n[2] Change username\n[3] Change password\n[4] Change communication protocol\n[5] Back\n\n"
    read -r optionschoice

    if [[ "${optionschoice}" == "0" ]]; then
        addvpn

    elif [[ "${optionschoice}" == "1" ]]; then
        rmvpn

    elif [[ "${optionschoice}" == "2" ]]; then
        chusername

    elif [[ "${optionschoice}" == "3" ]]; then
        chpasswd

    elif [[ "${optionschoice}" == "4" ]]; then
        chprotocol

    elif [[ "${optionschoice}" == "5" ]]; then
        mainmenu
    else
        echo ""
        error "04"
    fi

}

# All the options
addvpn () {
    read -r -e -p "Enter the file path: " ovpnfile
    nmcli con import type openvpn file "${ovpnfile}"
}

rmvpn () {
    echo "Select one of the following:"
    echo -e "$(nmcli con show | grep vpn)\n"

    read -r connectionfordelete

    if [[ "${connectionfordelete}" == *".udp"* ]] || [[ "${connectionfordelete}" == *".tcp"* ]]; then
        nmcli con delete "${connectionfordelete}"
    else
        error "03"
    fi
}

chusername () {
    echo "Select one of the following:"
    echo -e "$(nmcli con show | grep vpn)\n"

    read -r confornamechange

    echo ""
    read -r -p "Enter the new username: " newusername
    nmcli con modify "${confornamechange}" vpn.user-name "${newusername}"
}

chpasswd () {
    echo "Select one of the following:"
    echo -e "$(nmcli con show | grep vpn)\n"

    read -r CONFORPASSCHANGE

    echo ""
    read -r -sp "Enter the new password: " newpassword
    nmcli con modify "${CONFORPASSCHANGE}" vpn.secrets "password=${newpassword}"
    echo ""
}

chprotocol () {
    echo ""
    echo "Select one of the following: "
    echo "[0] UDP"
    echo -e "[1] TCP\n"

    read -r protocolchoice

    if [[ "${protocolchoice}" == "0" ]]; then
        if [[ "${}" == "udp" ]]; then
            sed -i 's/current_protocol=udp/current_protocol=udp/' "$HOME/.config/vpnmanager/config.conf"
        elif [[ "${currentprotocol}" == "tcp" ]]; then
            sed -i 's/current_protocol=tcp/current_protocol=udp/' "$HOME/.config/vpnmanager/config.conf"
        fi
    elif [[ "${protocolchoice}" == "1" ]]; then
        if [[ "${}" == "udp" ]]; then
            sed -i 's/current_protocol=udp/current_protocol=tcp/' "$HOME/.config/vpnmanager/config.conf"
        elif [[ "${currentprotocol}" == "tcp" ]]; then
            sed -i 's/current_protocol=tcp/current_protocol=tcp/' "$HOME/.config/vpnmanager/config.conf"
        fi
    else
        error "02"
        exit 22
    fi
}

# The exit function, meant for a normal exit
exitfunc () {
    printf "\nExiting...\n"
    exit 0
}


main () {
    # Checking if this is the first time you're running this script
    if [ -f "$HOME/.config/vpnmanager/config.conf" ]; then
        config_file="$HOME/.config/vpnmanager/config.conf" # If not, it declares the var for the config file...
        
        if [[ "$(grep current_protocol "$config_file")" == "current_protocol=udp" ]]; then # ...goes through a bunch of config read -rs...
            currentprotocol="udp"
        elif [[ "$(grep current_protocol "$config_file")" == "current_protocol=tcp" ]]; then
            currentprotocol="tcp"
        fi

        if [[ "$(grep normal_errors "$config_file")" == "normal_errors=off" ]]; then
            normalerrors="off"
        elif [[ "$(grep normal_errors "$config_file")" == "normal_errors=on" ]]; then
            normalerrors="on"
        else
            normalerrors="on"
        fi
    
        mainmenu # ...and runs the main menu function
    else
        firstsetup # If it is, it goes through the firstsetup function first...
        mainmenu # ...and then triggers the main function
    fi
}

main