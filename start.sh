#!/bin/bash
set -euo pipefail

# =============================
# Enhanced Multi-VM Manager with TUI
# =============================

# Function to detect available UI mode
detect_ui_mode() {
    if [[ "$UI_MODE" == "auto" ]]; then
        if command -v "dialog" &> /dev/null; then
            UI_MODE="dialog"
        elif command -v "whiptail" &> /dev/null; then
            UI_MODE="whiptail"
        else
            UI_MODE="text"
        fi
    fi
}

# Function to display header (text mode)
display_header_text() {
    clear
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║              QEMU VM MANAGER - Enhanced TUI                   ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo
}

# Function to display colored output
print_status() {
    local type=$1
    local message=$2
    
    case $type in
        "INFO") echo -e "\033[1;34m[INFO]\033[0m $message" ;;
        "WARN") echo -e "\033[1;33m[WARN]\033[0m $message" ;;
        "ERROR") echo -e "\033[1;31m[ERROR]\033[0m $message" ;;
        "SUCCESS") echo -e "\033[1;32m[SUCCESS]\033[0m $message" ;;
        "INPUT") echo -e "\033[1;36m[INPUT]\033[0m $message" ;;
        "TITLE") echo -e "\033[1;35m$message\033[0m" ;;
        "MENU") echo -e "\033[1;33m$message\033[0m" ;;
        *) echo "[$type] $message" ;;
    esac
}

# =============================
# DIALOG UI FUNCTIONS
# =============================

# Show dialog message box
dialog_msg() {
    local title="$1"
    local message="$2"
    local height="$3"
    local width="$4"
    
    dialog --title "$title" --msgbox "$message" "$height" "$width" 2>&1 >/dev/tty
}

# Show dialog menu
dialog_menu() {
    local title="$1"
    local message="$2"
    local height="$3"
    local width="$4"
    local menu_height="$5"
    shift 5
    
    local args=()
    while [ $# -gt 0 ]; do
        args+=("$1" "$2")
        shift 2
    done
    
    dialog --title "$title" --menu "$message" "$height" "$width" "$menu_height" "${args[@]}" 2>&1 >/dev/tty
}

# Show dialog inputbox
dialog_input() {
    local title="$1"
    local message="$2"
    local default="$3"
    
    dialog --title "$title" --inputbox "$message" 10 60 "$default" 2>&1 >/dev/tty
}

# Show dialog yesno
dialog_yesno() {
    local title="$1"
    local message="$2"
    
    dialog --title "$title" --yesno "$message" 10 60 2>&1 >/dev/tty
    return $?
}

# Show dialog checklist
dialog_checklist() {
    local title="$1"
    local message="$2"
    local height="$3"
    local width="$4"
    local list_height="$5"
    shift 5
    
    local args=()
    while [ $# -gt 0 ]; do
        args+=("$1" "$2" "$3")
        shift 3
    done
    
    dialog --title "$title" --checklist "$message" "$height" "$width" "$list_height" "${args[@]}" 2>&1 >/dev/tty
}

# Show dialog gauge
dialog_gauge() {
    local title="$1"
    local message="$2"
    local percent="$3"
    
    echo "$percent" | dialog --title "$title" --gauge "$message" 10 60 0 2>&1 >/dev/tty
}

# =============================
# WHIPTAIL UI FUNCTIONS
# =============================

# Show whiptail message box
whiptail_msg() {
    local title="$1"
    local message="$2"
    local height="$3"
    local width="$4"
    
    whiptail --title "$title" --msgbox "$message" "$height" "$width" 2>&1 >/dev/tty
}

# Show whiptail menu
whiptail_menu() {
    local title="$1"
    local message="$2"
    local height="$3"
    local width="$4"
    local menu_height="$5"
    shift 5
    
    local args=()
    while [ $# -gt 0 ]; do
        args+=("$1" "$2")
        shift 2
    done
    
    whiptail --title "$title" --menu "$message" "$height" "$width" "$menu_height" "${args[@]}" 2>&1 >/dev/tty
}

# Show whiptail inputbox
whiptail_input() {
    local title="$1"
    local message="$2"
    local default="$3"
    
    whiptail --title "$title" --inputbox "$message" 10 60 "$default" 2>&1 >/dev/tty
}

# Show whiptail yesno
whiptail_yesno() {
    local title="$1"
    local message="$2"
    
    whiptail --title "$title" --yesno "$message" 10 60 2>&1 >/dev/tty
    return $?
}

# =============================
# UNIFIED UI FUNCTIONS
# =============================

# Show message based on UI mode
show_msg() {
    local title="$1"
    local message="$2"
    
    case $UI_MODE in
        "dialog")
            dialog_msg "$title" "$message" 12 60
            ;;
        "whiptail")
            whiptail_msg "$title" "$message" 12 60
            ;;
        "text")
            display_header_text
            print_status "TITLE" "$title"
            echo "$message"
            echo
            read -p "$(print_status "INPUT" "Press Enter to continue...")" dummy
            ;;
    esac
}

# Show menu based on UI mode
show_menu() {
    local title="$1"
    local message="$2"
    shift 2
    
    case $UI_MODE in
        "dialog")
            dialog_menu "$title" "$message" 20 60 12 "$@"
            ;;
        "whiptail")
            whiptail_menu "$title" "$message" 20 60 12 "$@"
            ;;
        "text")
            display_header_text
            print_status "MENU" "$title"
            echo "$message"
            echo
            
            local i=1
            local menu_items=()
            while [ $# -gt 0 ]; do
                echo "  $i) $2"
                menu_items[$i]="$1"
                shift 2
                ((i++))
            done
            echo "  0) Exit"
            
            local choice
            while true; do
                read -p "$(print_status "INPUT" "Enter your choice (0-$(($i-1))): ")" choice
                if [[ "$choice" == "0" ]]; then
                    echo "0"
                    return
                elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt $i ]; then
                    echo "${menu_items[$choice]}"
                    return
                else
                    print_status "ERROR" "Invalid selection"
                fi
            done
            ;;
    esac
}

# Show input box based on UI mode
show_input() {
    local title="$1"
    local message="$2"
    local default="$3"
    
    case $UI_MODE in
        "dialog")
            dialog_input "$title" "$message" "$default"
            ;;
        "whiptail")
            whiptail_input "$title" "$message" "$default"
            ;;
        "text")
            display_header_text
            print_status "INPUT" "$title"
            echo "$message"
            read -p "$(print_status "INPUT" "Enter value [$default]: ")" value
            echo "${value:-$default}"
            ;;
    esac
}

# Show yes/no prompt based on UI mode
show_yesno() {
    local title="$1"
    local message="$2"
    
    case $UI_MODE in
        "dialog")
            dialog_yesno "$title" "$message"
            return $?
            ;;
        "whiptail")
            whiptail_yesno "$title" "$message"
            return $?
            ;;
        "text")
            display_header_text
            print_status "INPUT" "$title"
            echo "$message"
            read -p "$(print_status "INPUT" "(y/N): ")" response
            [[ "$response" =~ ^[Yy]$ ]]
            return $?
            ;;
    esac
}

# Show gauge/progress bar based on UI mode
show_gauge() {
    local title="$1"
    local message="$2"
    local percent="$3"
    
    case $UI_MODE in
        "dialog")
            dialog_gauge "$title" "$message" "$percent"
            ;;
        "whiptail")
            # whiptail doesn't have gauge, use dialog if available
            if command -v "dialog" &> /dev/null; then
                dialog_gauge "$title" "$message" "$percent"
            else
                # Fallback to text mode
                echo -ne "\r$message: $percent%"
                if [ "$percent" -eq 100 ]; then
                    echo
                fi
            fi
            ;;
        "text")
            echo -ne "\r$message: $percent%"
            if [ "$percent" -eq 100 ]; then
                echo
            fi
            ;;
    esac
}

# =============================
# ENHANCED UI MAIN MENU
# =============================

# Enhanced main menu with TUI
enhanced_main_menu() {
    while true; do
        local vms=($(get_vm_list))
        local vm_count=${#vms[@]}
        
        # Prepare VM list for menu
        local menu_options=()
        if [ $vm_count -gt 0 ]; then
            for vm in "${vms[@]}"; do
                local status="Stopped"
                if is_vm_running "$vm"; then
                    status="Running"
                fi
                menu_options+=("$vm" "$vm ($status)")
            done
            menu_options+=("---" "────────────────────")
        fi
        
        # Add main menu options
        menu_options+=(
            "create"    "Create New VM"
            "start"     "Start VM"
            "stop"      "Stop VM"
            "info"      "Show VM Info"
            "edit"      "Edit VM Configuration"
            "delete"    "Delete VM"
            "resize"    "Resize VM Disk"
            "perf"      "Performance Metrics"
            "settings"  "Settings"
            "help"      "Help"
            "exit"      "Exit"
        )
        
        local choice
        choice=$(show_menu "QEMU VM Manager" "Select an option:" "${menu_options[@]}")
        
        if [ -z "$choice" ] || [ "$choice" == "exit" ] || [ "$choice" == "0" ]; then
            print_status "INFO" "Goodbye!"
            exit 0
        fi
        
        case $choice in
            "create")
                create_new_vm_ui
                ;;
            "start")
                if [ $vm_count -gt 0 ]; then
                    start_vm_ui
                else
                    show_msg "No VMs" "No virtual machines found. Please create one first."
                fi
                ;;
            "stop")
                if [ $vm_count -gt 0 ]; then
                    stop_vm_ui
                else
                    show_msg "No VMs" "No virtual machines found."
                fi
                ;;
            "info")
                if [ $vm_count -gt 0 ]; then
                    show_vm_info_ui
                else
                    show_msg "No VMs" "No virtual machines found."
                fi
                ;;
            "edit")
                if [ $vm_count -gt 0 ]; then
                    edit_vm_config_ui
                else
                    show_msg "No VMs" "No virtual machines found."
                fi
                ;;
            "delete")
                if [ $vm_count -gt 0 ]; then
                    delete_vm_ui
                else
                    show_msg "No VMs" "No virtual machines found."
                fi
                ;;
            "resize")
                if [ $vm_count -gt 0 ]; then
                    resize_vm_disk_ui
                else
                    show_msg "No VMs" "No virtual machines found."
                fi
                ;;
            "perf")
                if [ $vm_count -gt 0 ]; then
                    show_vm_performance_ui
                else
                    show_msg "No VMs" "No virtual machines found."
                fi
                ;;
            "settings")
                show_settings_menu
                ;;
            "help")
                show_help
                ;;
            "---")
                continue
                ;;
            *)
                # Check if it's a VM name
                if [[ " ${vms[@]} " =~ " ${choice} " ]]; then
                    # Quick actions menu for selected VM
                    quick_vm_menu "$choice"
                fi
                ;;
        esac
    done
}

# Create new VM with UI
create_new_vm_ui() {
    # Step 1: Select OS
    local os_options=()
    for os in "${!OS_OPTIONS[@]}"; do
        os_options+=("$os" "$os")
    done
    
    local os_choice
    os_choice=$(show_menu "Create New VM" "Select Operating System:" "${os_options[@]}")
    
    if [ -z "$os_choice" ]; then
        return
    fi
    
    IFS='|' read -r OS_TYPE CODENAME IMG_URL DEFAULT_HOSTNAME DEFAULT_USERNAME DEFAULT_PASSWORD <<< "${OS_OPTIONS[$os_choice]}"
    
    # Step 2: Get VM details
    VM_NAME=$(show_input "VM Name" "Enter VM name:" "$DEFAULT_HOSTNAME")
    if [ -z "$VM_NAME" ]; then
        show_msg "Cancelled" "VM creation cancelled."
        return
    fi
    
    # Validate VM name
    if ! validate_input "name" "$VM_NAME"; then
        show_msg "Error" "Invalid VM name. Only letters, numbers, hyphens, and underscores allowed."
        return
    fi
    
    # Check if VM already exists
    if [[ -f "$VM_DIR/$VM_NAME.conf" ]]; then
        show_msg "Error" "VM with name '$VM_NAME' already exists."
        return
    fi
    
    HOSTNAME=$(show_input "Hostname" "Enter hostname:" "$VM_NAME")
    if [ -z "$HOSTNAME" ]; then
        show_msg "Cancelled" "VM creation cancelled."
        return
    fi
    
    USERNAME=$(show_input "Username" "Enter username:" "$DEFAULT_USERNAME")
    if [ -z "$USERNAME" ]; then
        show_msg "Cancelled" "VM creation cancelled."
        return
    fi
    
    # Get password with confirmation
    while true; do
        PASSWORD=$(show_input "Password" "Enter password:" "$DEFAULT_PASSWORD")
        if [ -z "$PASSWORD" ]; then
            show_msg "Error" "Password cannot be empty."
            continue
        fi
        
        CONFIRM_PASSWORD=$(show_input "Confirm Password" "Confirm password:" "")
        if [ "$PASSWORD" != "$CONFIRM_PASSWORD" ]; then
            show_msg "Error" "Passwords do not match. Please try again."
        else
            break
        fi
    done
    
    # Hardware configuration
    DISK_SIZE=$(show_input "Disk Size" "Enter disk size (e.g., 20G):" "20G")
    MEMORY=$(show_input "Memory" "Enter memory in MB:" "2048")
    CPUS=$(show_input "CPUs" "Enter number of CPUs:" "2")
    SSH_PORT=$(show_input "SSH Port" "Enter SSH port:" "2222")
    
    # Validate SSH port
    if ! validate_input "port" "$SSH_PORT"; then
        show_msg "Error" "Invalid SSH port. Must be between 23 and 65535."
        return
    fi
    
    # Check if port is in use
    if ss -tln 2>/dev/null | grep -q ":$SSH_PORT "; then
        show_msg "Error" "Port $SSH_PORT is already in use."
        return
    fi
    
    # GUI Mode
    if show_yesno "GUI Mode" "Enable GUI mode?"; then
        GUI_MODE=true
    else
        GUI_MODE=false
    fi
    
    # Additional port forwards
    PORT_FORWARDS=$(show_input "Port Forwards" "Additional port forwards (e.g., 8080:80,443:443):" "")
    
    IMG_FILE="$VM_DIR/$VM_NAME.img"
    SEED_FILE="$VM_DIR/$VM_NAME-seed.iso"
    CREATED="$(date)"
    
    # Show summary
    local summary="VM Creation Summary:\n\n"
    summary+="Name: $VM_NAME\n"
    summary+="OS: $os_choice\n"
    summary+="Hostname: $HOSTNAME\n"
    summary+="Username: $USERNAME\n"
    summary+="Memory: $MEMORY MB\n"
    summary+="CPUs: $CPUS\n"
    summary+="Disk: $DISK_SIZE\n"
    summary+="SSH Port: $SSH_PORT\n"
    summary+="GUI Mode: $GUI_MODE\n"
    summary+="Port Forwards: ${PORT_FORWARDS:-None}\n"
    
    if show_yesno "Confirm Creation" "$summary\nCreate this VM?"; then
        # Download and setup VM with progress
        setup_vm_image_with_progress
        save_vm_config
        show_msg "Success" "VM '$VM_NAME' created successfully!"
    else
        show_msg "Cancelled" "VM creation cancelled."
    fi
}

# Setup VM image with progress indicator
setup_vm_image_with_progress() {
    mkdir -p "$VM_DIR"
    
    if [[ ! -f "$IMG_FILE" ]]; then
        show_msg "Download" "Downloading image from $IMG_URL..."
        
        # Create a temporary file for download progress
        (
            wget --progress=dot:giga "$IMG_URL" -O "$IMG_FILE.tmp" 2>&1 | \
            grep --line-buffered "%" | \
            sed -u -e "s/\.//g" -e "s/.* \([0-9]\+\)%.*/\1/" | \
            while read progress; do
                show_gauge "Downloading" "Downloading OS image..." "$progress"
            done
        ) || true
        
        if [ -f "$IMG_FILE.tmp" ]; then
            mv "$IMG_FILE.tmp" "$IMG_FILE"
            show_gauge "Downloading" "Download completed!" 100
        else
            show_msg "Error" "Failed to download image."
            return 1
        fi
    fi
    
    # Resize disk with progress
    show_gauge "Preparing" "Resizing disk image..." 30
    qemu-img resize "$IMG_FILE" "$DISK_SIZE" 2>/dev/null || \
    qemu-img create -f qcow2 "$IMG_FILE" "$DISK_SIZE"
    
    # Create cloud-init config
    show_gauge "Preparing" "Creating cloud-init configuration..." 60
    cat > user-data <<EOF
#cloud-config
hostname: $HOSTNAME
ssh_pwauth: true
disable_root: false
users:
  - name: $USERNAME
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    password: $(openssl passwd -6 "$PASSWORD" | tr -d '\n')
chpasswd:
  list: |
    root:$PASSWORD
    $USERNAME:$PASSWORD
  expire: false
EOF

    cat > meta-data <<EOF
instance-id: iid-$VM_NAME
local-hostname: $HOSTNAME
EOF

    show_gauge "Preparing" "Creating seed image..." 90
    cloud-localds "$SEED_FILE" user-data meta-data
    
    show_gauge "Preparing" "VM setup completed!" 100
}

# Start VM with UI
start_vm_ui() {
    local vms=($(get_vm_list))
    local vm_options=()
    
    for vm in "${vms[@]}"; do
        if ! is_vm_running "$vm"; then
            vm_options+=("$vm" "Stopped")
        fi
    done
    
    if [ ${#vm_options[@]} -eq 0 ]; then
        show_msg "No VMs" "No stopped VMs found."
        return
    fi
    
    local vm_choice
    vm_choice=$(show_menu "Start VM" "Select VM to start:" "${vm_options[@]}")
    
    if [ -n "$vm_choice" ]; then
        if show_yesno "Start VM" "Start VM '$vm_choice'?"; then
            # Run in background and show status
            (
                if start_vm "$vm_choice"; then
                    show_msg "Success" "VM '$vm_choice' started successfully!\n\nSSH: ssh -p $SSH_PORT $USERNAME@localhost\nPassword: $PASSWORD"
                fi
            ) &
            
            # Show loading message
            for i in {1..10}; do
                show_gauge "Starting" "Starting VM '$vm_choice'..." $((i*10))
                sleep 1
            done
        fi
    fi
}

# Stop VM with UI
stop_vm_ui() {
    local vms=($(get_vm_list))
    local vm_options=()
    
    for vm in "${vms[@]}"; do
        if is_vm_running "$vm"; then
            vm_options+=("$vm" "Running")
        fi
    done
    
    if [ ${#vm_options[@]} -eq 0 ]; then
        show_msg "No VMs" "No running VMs found."
        return
    fi
    
    local vm_choice
    vm_choice=$(show_menu "Stop VM" "Select VM to stop:" "${vm_options[@]}")
    
    if [ -n "$vm_choice" ]; then
        if show_yesno "Stop VM" "Stop VM '$vm_choice'?"; then
            stop_vm "$vm_choice"
            show_msg "Success" "VM '$vm_choice' stopped successfully."
        fi
    fi
}

# Show VM info with UI
show_vm_info_ui() {
    local vms=($(get_vm_list))
    local vm_choice
    vm_choice=$(show_menu "VM Info" "Select VM:" "${vms[@]/%/}")
    
    if [ -n "$vm_choice" ]; then
        if load_vm_config "$vm_choice"; then
            local info="VM Information: $vm_choice\n"
            info+="═══════════════════════════════════════\n"
            info+="OS: $OS_TYPE\n"
            info+="Hostname: $HOSTNAME\n"
            info+="Username: $USERNAME\n"
            info+="Password: ********\n"
            info+="SSH Port: $SSH_PORT\n"
            info+="Memory: $MEMORY MB\n"
            info+="CPUs: $CPUS\n"
            info+="Disk: $DISK_SIZE\n"
            info+="GUI Mode: $GUI_MODE\n"
            info+="Port Forwards: ${PORT_FORWARDS:-None}\n"
            info+="Created: $CREATED\n"
            info+="Status: $(is_vm_running "$vm_choice" && echo "Running" || echo "Stopped")\n"
            info+="═══════════════════════════════════════\n"
            
            show_msg "VM Info" "$info"
        fi
    fi
}

# Quick VM actions menu
quick_vm_menu() {
    local vm_name="$1"
    
    while true; do
        local status=$(is_vm_running "$vm_name" && echo "Running" || echo "Stopped")
        local menu_options=()
        
        if [ "$status" == "Stopped" ]; then
            menu_options+=("start" "Start VM")
        else
            menu_options+=("stop" "Stop VM")
            menu_options+=("console" "Open Console")
        fi
        
        menu_options+=(
            "info"    "Show Info"
            "edit"    "Edit Config"
            "resize"  "Resize Disk"
            "perf"    "Performance"
            "delete"  "Delete VM"
            "back"    "Back to Main"
        )
        
        local choice
        choice=$(show_menu "VM: $vm_name ($status)" "Select action:" "${menu_options[@]}")
        
        case $choice in
            "start")
                if show_yesno "Start VM" "Start VM '$vm_name'?"; then
                    start_vm "$vm_name"
                fi
                ;;
            "stop")
                if show_yesno "Stop VM" "Stop VM '$vm_name'?"; then
                    stop_vm "$vm_name"
                fi
                ;;
            "console")
                # Open console in new terminal if available
                if command -v "xterm" &> /dev/null; then
                    xterm -e "echo 'Connecting to VM console...'; ssh -p $SSH_PORT $USERNAME@localhost" &
                elif command -v "gnome-terminal" &> /dev/null; then
                    gnome-terminal -- ssh -p $SSH_PORT $USERNAME@localhost
                else
                    show_msg "Console" "SSH: ssh -p $SSH_PORT $USERNAME@localhost\nPassword: $PASSWORD"
                fi
                ;;
            "info")
                show_vm_info_ui
                ;;
            "edit")
                edit_vm_config_ui_single "$vm_name"
                ;;
            "resize")
                resize_vm_disk_ui_single "$vm_name"
                ;;
            "perf")
                show_vm_performance_ui_single "$vm_name"
                ;;
            "delete")
                delete_vm_ui_single "$vm_name"
                return  # Return to main menu after deletion
                ;;
            "back")
                return
                ;;
        esac
    done
}

# Settings menu
show_settings_menu() {
    while true; do
        local current_ui="$UI_MODE"
        local current_vm_dir="$VM_DIR"
        
        local choice
        choice=$(show_menu "Settings" "Select setting to change:" \
            "ui" "UI Mode (Current: $current_ui)" \
            "dir" "VM Directory (Current: $current_vm_dir)" \
            "back" "Back to Main")
        
        case $choice in
            "ui")
                local ui_choice
                ui_choice=$(show_menu "UI Mode" "Select UI mode:" \
                    "auto" "Auto-detect" \
                    "dialog" "Dialog-based" \
                    "whiptail" "Whiptail-based" \
                    "text" "Text-only")
                
                if [ -n "$ui_choice" ]; then
                    UI_MODE="$ui_choice"
                    detect_ui_mode
                    show_msg "Settings" "UI mode changed to: $UI_MODE"
                fi
                ;;
            "dir")
                local new_dir
                new_dir=$(show_input "VM Directory" "Enter new VM directory:" "$current_vm_dir")
                
                if [ -n "$new_dir" ] && [ "$new_dir" != "$current_vm_dir" ]; then
                    if [ -d "$new_dir" ] || mkdir -p "$new_dir" 2>/dev/null; then
                        VM_DIR="$new_dir"
                        show_msg "Settings" "VM directory changed to: $VM_DIR"
                    else
                        show_msg "Error" "Cannot create directory: $new_dir"
                    fi
                fi
                ;;
            "back")
                return
                ;;
        esac
    done
}

# Help screen
show_help() {
    local help_text="QEMU VM Manager Help\n\n"
    help_text+="This tool helps you manage QEMU virtual machines.\n\n"
    help_text+="Features:\n"
    help_text+="• Create VMs from cloud images\n"
    help_text+="• Start/Stop VMs\n"
    help_text+="• Edit VM configuration\n"
    help_text+="• Resize VM disks\n"
    help_text+="• SSH access to VMs\n"
    help_text+="• GUI and Console modes\n\n"
    help_text+="Keyboard Shortcuts:\n"
    help_text+="• Use arrow keys to navigate\n"
    help_text+="• Enter to select\n"
    help_text+="• ESC to go back\n"
    help_text+="• Tab to switch fields\n\n"
    help_text+="Requirements:\n"
    help_text+="• qemu-system-x86_64\n"
    help_text+="• cloud-image-utils\n"
    help_text+="• wget\n"
    help_text+="• ssh client\n\n"
    help_text+="For best experience, install 'dialog' package."
    
    show_msg "Help" "$help_text"
}

# =============================
# MAIN EXECUTION
# =============================

# Initialize with auto UI detection
UI_MODE="auto"
detect_ui_mode

# Check dependencies
check_dependencies

# Initialize paths
VM_DIR="${VM_DIR:-$HOME/vms}"
mkdir -p "$VM_DIR"

# Supported OS list
declare -A OS_OPTIONS=(
    ["Ubuntu 22.04"]="ubuntu|jammy|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu22|ubuntu|ubuntu"
    ["Ubuntu 24.04"]="ubuntu|noble|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu24|ubuntu|ubuntu"
    ["Debian 11"]="debian|bullseye|https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2|debian11|debian|debian"
    ["Debian 12"]="debian|bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|debian12|debian|debian"
    ["Fedora 40"]="fedora|40|https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40-1.14.x86_64.qcow2|fedora40|fedora|fedora"
    ["CentOS Stream 9"]="centos|stream9|https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2|centos9|centos|centos"
    ["AlmaLinux 9"]="almalinux|9|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2|almalinux9|alma|alma"
    ["Rocky Linux 9"]="rockylinux|9|https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2|rocky9|rocky|rocky"
)

# Set trap to cleanup on exit
trap cleanup EXIT

# Start the enhanced UI
if [[ "$1" == "--text" ]] || [[ "$1" == "-t" ]]; then
    UI_MODE="text"
    main_menu
else
    enhanced_main_menu
fi
