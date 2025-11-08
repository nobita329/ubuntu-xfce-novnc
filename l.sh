#!/bin/bash
# ===========================================================
# Multi-Panel Interactive Script
# Mode By - Nobita
# ===========================================================

# --- COLORS ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
NC='\033[0m'

pause() { 
    echo -e "${CYAN}"
    read -p "Press Enter to continue..." fackEnterKey
    echo -e "${NC}"
}

banner() {
    clear
    echo -e "\033[96m"
    echo "  ██████  ██████  ██████  ██ ███    ██  ██████      ██   ██ ██    ██ ██████  "
    echo " ██      ██    ██ ██   ██ ██ ████   ██ ██           ██   ██ ██    ██ ██   ██ "
    echo " ██      ██    ██ ██   ██ ██ ██ ██  ██ ██   ███     ███████ ██    ██ ██████  "
    echo " ██      ██    ██ ██   ██ ██ ██  ██ ██ ██    ██     ██   ██ ██    ██ ██   ██ "
    echo "  ██████  ██████  ██████  ██ ██   ████  ██████      ██   ██  ██████  ██████  "
    echo "                                                                             "
    echo -e "\033[0m"
    echo -e "\033[96m                Mode By - Nobita\033[0m"
    echo -e "\033[94m=================================================================\033[0m"
    echo
}

# ---------------- PANEL MENU ----------------
panel_menu() {
    while true; do
        banner
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                     📦 PANEL MENU                       ║${NC}"
        echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║${NC}                                                          ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  ${YELLOW}1)${NC} 1 Panel          ${YELLOW}6)${NC} Dashboard v4           ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  ${YELLOW}2)${NC} Pterodactyl      ${YELLOW}7)${NC} Payment                ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  ${YELLOW}3)${NC} JackTera v3      ${YELLOW}8)${NC} CtrlPanel              ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  ${YELLOW}4)${NC} JackTera v4      ${YELLOW}9)${NC} CPanel                 ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}  ${YELLOW}5)${NC} Dashboard v3     ${YELLOW}10)${NC} Back to Main Menu     ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}                                                          ${GREEN}║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
        echo
        read -p "Select option: " pchoice

        case $pchoice in
            1) bash <(curl -s https://raw.githubusercontent.com/yourlink/1panel.sh) ;;
            2) bash <(curl -s https://raw.githubusercontent.com/yourlink/pterodactyl.sh) ;;
            3) bash <(curl -s https://raw.githubusercontent.com/yourlink/jacktera_v3.sh) ;;
            4) bash <(curl -s https://raw.githubusercontent.com/yourlink/jacktera_v4.sh) ;;
            5) bash <(curl -s https://raw.githubusercontent.com/yourlink/dashboard_v3.sh) ;;
            6) bash <(curl -s https://raw.githubusercontent.com/yourlink/dashboard_v4.sh) ;;
            7) bash <(curl -s https://raw.githubusercontent.com/yourlink/payment.sh) ;;
            8) bash <(curl -s https://raw.githubusercontent.com/yourlink/ctrlpanel.sh) ;;
            9) bash <(curl -s https://raw.githubusercontent.com/yourlink/cpanel.sh) ;;
            10) break ;;
            *) echo -e "${RED}Invalid choice${NC}"; pause ;;
        esac
    done
}

# ---------------- TOOLS MENU ----------------
tools_menu() {
    while true; do
        banner
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║                     🛠️ TOOLS MENU                       ║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC}                                                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC}  ${YELLOW}1)${NC} Root             ${YELLOW}5)${NC} IPv4                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC}  ${YELLOW}2)${NC} Tailscale        ${YELLOW}6)${NC} Port Forward          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC}  ${YELLOW}3)${NC} Cloudflare       ${YELLOW}7)${NC} RDP                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC}  ${YELLOW}4)${NC} System Info      ${YELLOW}8)${NC} Back to Main Menu     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC}                                                          ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
        echo
        read -p "Select option: " tchoice

        case $tchoice in
            1) bash <(curl -s https://raw.githubusercontent.com/yourlink/root.sh) ;;
            2) bash <(curl -s https://raw.githubusercontent.com/yourlink/tailscale.sh) ;;
            3) bash <(curl -s https://raw.githubusercontent.com/yourlink/cloudflare.sh) ;;
            4) bash <(curl -s https://raw.githubusercontent.com/yourlink/systeminfo.sh) ;;
            5) bash <(curl -s https://raw.githubusercontent.com/yourlink/ipv4.sh) ;;
            6) bash <(curl -s https://raw.githubusercontent.com/yourlink/portforward.sh) ;;
            7) bash <(curl -s https://raw.githubusercontent.com/yourlink/rdp.sh) ;;
            8) break ;;
            *) echo -e "${RED}Invalid choice${NC}"; pause ;;
        esac
    done
}

# ---------------- THEME MENU ----------------
theme_menu() {
    while true; do
        banner
        echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║                     🎨 THEME MENU                       ║${NC}"
        echo -e "${PURPLE}╠══════════════════════════════════════════════════════════╣${NC}"
        echo -e "${PURPLE}║${NC}                                                          ${PURPLE}║${NC}"
        echo -e "${PURPLE}║${NC}  ${YELLOW}1)${NC} Blueprint                              ${PURPLE}║${NC}"
        echo -e "${PURPLE}║${NC}  ${YELLOW}2)${NC} Change Theme                           ${PURPLE}║${NC}"
        echo -e "${PURPLE}║${NC}  ${YELLOW}3)${NC} Uninstall Theme                        ${PURPLE}║${NC}"
        echo -e "${PURPLE}║${NC}  ${YELLOW}4)${NC} Back to Main Menu                      ${PURPLE}║${NC}"
        echo -e "${PURPLE}║${NC}                                                          ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
        echo
        read -p "Select option: " thchoice

        case $thchoice in
            1) bash <(curl -s https://raw.githubusercontent.com/yourlink/blueprint.sh) ;;
            2) bash <(curl -s https://raw.githubusercontent.com/yourlink/change_theme.sh) ;;
            3) bash <(curl -s https://raw.githubusercontent.com/yourlink/theme_uninstall.sh) ;;
            4) break ;;
            *) echo -e "${RED}Invalid choice${NC}"; pause ;;
        esac
    done
}

# ---------------- UNINSTALL MENU ----------------
uninstall_menu() {
    while true; do
        banner
        echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                     🗑️ UNINSTALL MENU                   ║${NC}"
        echo -e "${RED}╠══════════════════════════════════════════════════════════╣${NC}"
        echo -e "${RED}║${NC}                                                          ${RED}║${NC}"
        echo -e "${RED}║${NC}  ${YELLOW}1)${NC} Pterodactyl      ${YELLOW}8)${NC} CPanel                 ${RED}║${NC}"
        echo -e "${RED}║${NC}  ${YELLOW}2)${NC} JackTera v3      ${YELLOW}9)${NC} Tailscale              ${RED}║${NC}"
        echo -e "${RED}║${NC}  ${YELLOW}3)${NC} JackTera v4      ${YELLOW}10)${NC} Cloudflare            ${RED}║${NC}"
        echo -e "${RED}║${NC}  ${YELLOW}4)${NC} Dashboard v3     ${YELLOW}11)${NC} IPv4                  ${RED}║${NC}"
        echo -e "${RED}║${NC}  ${YELLOW}5)${NC} Dashboard v4     ${YELLOW}12)${NC} Port Forward          ${RED}║${NC}"
        echo -e "${RED}║${NC}  ${YELLOW}6)${NC} Payment          ${YELLOW}13)${NC} Back to Main Menu     ${RED}║${NC}"
        echo -e "${RED}║${NC}  ${YELLOW}7)${NC} CtrlPanel        ${YELLOW}                              ${RED}║${NC}"
        echo -e "${RED}║${NC}                                                          ${RED}║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
        echo
        read -p "Select option: " uchoice

        case $uchoice in
            1) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_ptero.sh) ;;
            2) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_jacktera_v3.sh) ;;
            3) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_jacktera_v4.sh) ;;
            4) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_dash_v3.sh) ;;
            5) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_dash_v4.sh) ;;
            6) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_payment.sh) ;;
            7) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_ctrlpanel.sh) ;;
            8) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_cpanel.sh) ;;
            9) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_tailscale.sh) ;;
            10) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_cloudflare.sh) ;;
            11) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_ipv4.sh) ;;
            12) bash <(curl -s https://raw.githubusercontent.com/yourlink/uninstall_portforward.sh) ;;
            13) break ;;
            *) echo -e "${RED}Invalid choice${NC}"; pause ;;
        esac
    done
}

# ---------------- MAIN MENU ----------------
main_menu() {
    while true; do
        banner
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                     🏠 MAIN MENU                         ║${NC}"
        echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC}                                                          ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${YELLOW}1)${NC} Panel Installation                        ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${YELLOW}2)${NC} Wings Setup                               ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${YELLOW}3)${NC} System Tools                              ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${YELLOW}4)${NC} Theme Customization                       ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${YELLOW}5)${NC} Uninstall Components                      ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${YELLOW}6)${NC} Exit                                      ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}                                                          ${CYAN}║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
        echo
        read -p "Select option: " choice

        case $choice in
            1) panel_menu ;;
            2) bash <(curl -s https://raw.githubusercontent.com/yourlink/wings.sh) ;;
            3) tools_menu ;;
            4) theme_menu ;;
            5) uninstall_menu ;;
            6) echo -e "${YELLOW}Exiting... Mode By - Nobita${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice${NC}"; pause ;;
        esac
    done
}

main_menu
