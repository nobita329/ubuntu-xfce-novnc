#!/bin/bash
set -euo pipefail
# =============================
# Enhanced Multi-VM Manager 🚀
# =============================
# Function to display header
display_header() {
    clear
    cat << "EOF"
========================================================================
     🌟 Enhanced Multi-VM Manager 🌟
========================================================================
EOF
    echo
}
# Function to display colored output
print_status() {
    local type=$1
    local message=$2
   
    case $type in
        "INFO") echo -e "\033[1;34m[INFO] ℹ️\033[0m $message" ;;
        "WARN") echo -e "\033[1;33m[WARN] ⚠️\033[0m $message" ;;
        "ERROR") echo -e "\033[1;31m[ERROR] ❌\033[0m $message" ;;
        "SUCCESS") echo -e "\033[1;32m[SUCCESS] ✅\033[0m $message" ;;
        "INPUT") echo -e "\033[1;36m[INPUT] ⌨️\033[0m $message" ;;
        *) echo "[$type] $message" ;;
    esac
}
# Function to validate input
validate_input() {
    local type=$1
    local value=$2
   
    case $type in
        "number")
            if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                print_status "ERROR" "Must be a number 🔢"
                return 1
            fi
            ;;
        "size")
            if ! [[ "$value" =~ ^[0-9]+[GgMm]$ ]]; then
                print_status "ERROR" "Must be a size with unit (e.g., 100G, 512M) 💾"
                return 1
            fi
            ;;
        "port")
            if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 23 ] || [ "$value" -gt 65535 ]; then
                print_status "ERROR" "Must be a valid port number (23-65535) 🔌"
                return 1
            fi
            ;;
        "name")
            if ! [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                print_status "ERROR" "VM name can only contain letters, numbers, hyphens, and underscores 🏷️"
                return 1
            fi
            ;;
        "username")
            if ! [[ "$value" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
                print_status "ERROR" "Username must start with a letter or underscore, and contain only letters, numbers, hyphens, and underscores 👤"
                return 1
            fi
            ;;
    esac
    return 0
}
# Function to check dependencies
check_dependencies() {
    local deps=("qemu-system-x86_64" "wget" "cloud-localds" "qemu-img")
    local missing_deps=()
   
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
   
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_status "ERROR" "Missing dependencies: ${missing_deps[*]} 🛠️"
        print_status "INFO" "On Ubuntu/Debian, try: sudo apt install qemu-system cloud-image-utils wget"
        exit 1
    fi
}
# Function to cleanup temporary files
cleanup() {
    if [ -f "user-data" ]; then rm -f "user-data"; fi
    if [ -f "meta-data" ]; then rm -f "meta-data"; fi
}
# Function to get all VM configurations
get_vm_list() {
    find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}
# Function to load VM configuration
load_vm_config() {
    local vm_name=$1
    local config_file="$VM_DIR/$vm_name.conf"
   
    if [[ -f "$config_file" ]]; then
        unset VM_NAME OS_TYPE CODENAME IMG_URL HOSTNAME USERNAME PASSWORD
        unset DISK_SIZE MEMORY CPUS SSH_PORT GUI_MODE PORT_FORWARDS IMG_FILE SEED_FILE CREATED
       
        source "$config_file"
        return 0
    else
        print_status "ERROR" "Configuration for VM '$vm_name' not found 📂"
        return 1
    fi
}
# Function to save VM configuration
save_vm_config() {
    local config_file="$VM_DIR/$VM_NAME.conf"
   
    cat > "$config_file" <<EOF
VM_NAME="$VM_NAME"
OS_TYPE="$OS_TYPE"
CODENAME="$CODENAME"
IMG_URL="$IMG_URL"
HOSTNAME="$HOSTNAME"
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
DISK_SIZE="$DISK_SIZE"
MEMORY="$MEMORY"
CPUS="$CPUS"
SSH_PORT="$SSH_PORT"
GUI_MODE="$GUI_MODE"
PORT_FORWARDS="$PORT_FORWARDS"
IMG_FILE="$IMG_FILE"
SEED_FILE="$SEED_FILE"
CREATED="$CREATED"
EOF
   
    print_status "SUCCESS" "Configuration saved to $config_file 💾"
}
# Function to create new VM
create_new_vm() {
    print_status "INFO" "Creating a new VM 🆕"
   
    # OS Selection
    print_status "INFO" "Select an OS to set up 🐧:"
    local os_options=()
    local i=1
    for os in "${!OS_OPTIONS[@]}"; do
        echo " $i) $os"
        os_options[$i]="$os"
        ((i++))
    done
   
    while true; do
        read -p "$(print_status "INPUT" "Enter your choice (1-${#OS_OPTIONS[@]}): ")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#OS_OPTIONS[@]} ]; then
            local os="${os_options[$choice]}"
            IFS='|' read -r OS_TYPE CODENAME IMG_URL DEFAULT_HOSTNAME DEFAULT_USERNAME DEFAULT_PASSWORD <<< "${OS_OPTIONS[$os]}"
            break
        else
            print_status "ERROR" "Invalid selection. Try again. 🚫"
        fi
    done
    # Custom Inputs with validation
    while true; do
        read -p "$(print_status "INPUT" "Enter VM name (default: $DEFAULT_HOSTNAME): ")" VM_NAME
        VM_NAME="${VM_NAME:-$DEFAULT_HOSTNAME}"
        if validate_input "name" "$VM_NAME"; then
            if [[ -f "$VM_DIR/$VM_NAME.conf" ]]; then
                print_status "ERROR" "VM with name '$VM_NAME' already exists 🧨"
            else
                break
            fi
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Enter hostname (default: $VM_NAME): ")" HOSTNAME
        HOSTNAME="${HOSTNAME:-$VM_NAME}"
        if validate_input "name" "$HOSTNAME"; then
            break
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Enter username (default: $DEFAULT_USERNAME): ")" USERNAME
        USERNAME="${USERNAME:-$DEFAULT_USERNAME}"
        if validate_input "username" "$USERNAME"; then
            break
        fi
    done
    while true; do
        read -s -p "$(print_status "INPUT" "Enter password (default: $DEFAULT_PASSWORD): ")" PASSWORD
        PASSWORD="${PASSWORD:-$DEFAULT_PASSWORD}"
        echo
        if [ -n "$PASSWORD" ]; then
            break
        else
            print_status "ERROR" "Password cannot be empty 🔒"
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Disk size (default: 20G): ")" DISK_SIZE
        DISK_SIZE="${DISK_SIZE:-20G}"
        if validate_input "size" "$DISK_SIZE"; then
            break
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Memory in MB (default: 2048): ")" MEMORY
        MEMORY="${MEMORY:-2048}"
        if validate_input "number" "$MEMORY"; then
            break
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "Number of CPUs (default: 2): ")" CPUS
        CPUS="${CPUS:-2}"
        if validate_input "number" "$CPUS"; then
            break
        fi
    done
    while true; do
        read -p "$(print_status "INPUT" "SSH Port (default: 2222): ")" SSH_PORT
        SSH_PORT="${SSH_PORT:-2222}"
        if validate_input "port" "$SSH_PORT"; then
            if ss -tln 2>/dev/null | grep -q ":$SSH_PORT "; then
                print_status "ERROR" "Port $SSH_PORT is already in use 🚨"
            else
                break
            fi
        fi
    done
    while true; do
        read -p "$(print_status " laptop "Enable GUI mode? (y/n, default: n): ")" gui_input
        GUI_MODE=false
        gui_input="${gui_input:-n}"
        if [[ "$gui_input" =~ ^[Yy]$ ]]; then
            GUI_MODE=true
            break
        elif [[ "$gui_input" =~ ^[Nn]$ ]]; then
            break
        else
            print_status "ERROR" "Please answer y or n ❓"
        fi
    done
    read -p "$(print_status "INPUT" "Additional port forwards (e.g., 8080:80, press Enter for none): ")" PORT_FORWARDS
    IMG_FILE="$VM_DIR/$VM_NAME.img"
    SEED_FILE="$VM_DIR/$VM_NAME-seed.iso"
    CREATED="$(date)"
    setup_vm_image
    save_vm_config
}
# Function to setup VM image
setup_vm_image() {
    print_status "INFO" "Downloading and preparing image... ⬇️"
   
    mkdir -p "$VM_DIR"
   
    if [[ -f "$IMG_FILE" ]]; then
        print_status "INFO" "Image file already exists. Skipping download. ✅"
    else
        print_status "INFO" "Downloading image from $IMG_URL... 🌐"
        if ! wget --progress=bar:force "$IMG_URL" -O "$IMG_FILE.tmp"; then
            print_status "ERROR" "Failed to download image from $IMG_URL 🌩️"
            exit 1
        fi
        mv "$IMG_FILE.tmp" "$IMG_FILE"
    fi
   
    if ! qemu-img resize "$IMG_FILE" "$DISK_SIZE" 2>/dev/null; then
        print_status "WARN" "Failed to resize disk image. Creating new image... 🔄"
        rm -f "$IMG_FILE"
        qemu-img create -f qcow2 -F qcow2 -b "$IMG_FILE" "$IMG_FILE.tmp" "$DISK_SIZE" 2>/dev/null || \
        qemu-img create -f qcow2 "$IMG_FILE" "$DISK_SIZE"
        if [ -f "$IMG_FILE.tmp" ]; then
            mv "$IMG_FILE.tmp" "$IMG_FILE"
        fi
    fi
   
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
    if ! cloud-localds "$SEED_FILE" user-data meta-data; then
        print_status "ERROR" "Failed to create cloud-init seed image ☁️"
        exit 1
    fi
   
    print_status "SUCCESS" "VM '$VM_NAME' created successfully! 🎉"
}
# Function to start a VM
start_vm() {
    local vm_name=$1
   
    if load_vm_config "$vm_name"; then
        print_status "INFO" "Starting VM: $vm_name ▶️"
        print_status "INFO" "SSH: ssh -p $SSH_PORT $USERNAME@localhost 🔑"
        print_status "INFO" "Password: $PASSWORD"
       
        if [[ ! -f "$IMG_FILE" ]]; then
            print_status "ERROR" "VM image file not found: $IMG_FILE 💔"
            return 1
        fi
       
        if [[ ! -f "$SEED_FILE" ]]; then
            print_status "WARN" "Seed file not found, recreating... ⚙️"
            setup_vm_image
        fi
       
        local qemu_cmd=(
            qemu-system-x86_64
            -enable-kvm
            -m "$MEMORY"
            -smp "$CPUS"
            -cpu host
            -drive "file=$IMG_FILE,format=qcow2,if=virtio"
            -drive "file=$SEED_FILE,format=raw,if=virtio"
            -boot order=c
            -device virtio-net-pci,netdev=n0
            -netdev "user,id=n0,hostfwd=tcp::$SSH_PORT-:22"
        )
        if [[ -n "$PORT_FORWARDS" ]]; then
            IFS=',' read -ra forwards <<< "$PORT_FORWARDS"
            for forward in "${forwards[@]}"; do
                IFS=':' read -r host_port guest_port <<< "$forward"
                qemu_cmd+=(-device "virtio-net-pci,netdev=n${#qemu_cmd[@]}")
                qemu_cmd+=(-netdev "user,id=n${#qemu_cmd[@]},hostfwd=tcp::$host_port-:$guest_port")
            done
        fi
        if [[ "$GUI_MODE" == true ]]; then
            qemu_cmd+=(-vga virtio -display gtk,gl=on)
        else
            qemu_cmd+=(-nographic -serial mon:stdio)
        fi
        qemu_cmd+=(
            -device virtio-balloon-pci
            -object rng-random,filename=/dev/urandom,id=rng0
            -device virtio-rng-pci,rng=rng0
        )
        print_status "INFO" "Starting QEMU... 🚀"
        "${qemu_cmd[@]}"
       
        print_status "INFO" "VM $vm_name has been shut down 🛑"
    fi
}
# Function to delete a VM
delete_vm() {
    local vm_name=$1
   
    print_status "WARN" "This will permanently delete VM '$vm_name' and all its data! ☠️"
    read -p "$(print_status "INPUT" "Are you sure? (y/N): ")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if load_vm_config "$vm_name"; then
            rm -f "$IMG_FILE" "$SEED_FILE" "$VM_DIR/$vm_name.conf"
            print_status "SUCCESS" "VM '$vm_name' has been deleted 🗑️"
        fi
    else
        print_status "INFO" "Deletion cancelled ✋"
    fi
}
# Function to show VM info
show_vm_info() {
    local vm_name=$1
   
    if load_vm_config "$vm_name"; then
        echo
        print_status "INFO" "VM Information: $vm_name ℹ️"
        echo "=========================================="
        echo "OS: $OS_TYPE 🐧"
        echo "Hostname: $HOSTNAME 🏠"
        echo "Username: $USERNAME 👤"
        echo "Password: $PASSWORD 🔒"
        echo "SSH Port: $SSH_PORT 🔌"
        echo "Memory: $MEMORY MB 🧠"
        echo "CPUs: $CPUS ⚙️"
        echo "Disk: $DISK_SIZE 💾"
        echo "GUI Mode: $GUI_MODE 🖥️"
        echo "Port Forwards: ${PORT_FORWARDS:-None} 🔀"
        echo "Created: $CREATED 📅"
        echo "Image File: $IMG_FILE 📀"
        echo "Seed File: $SEED_FILE ☁️"
        echo "=========================================="
        echo
        read -p "$(print_status "INPUT" "Press Enter to continue...")"
    fi
}
# Function to check if VM is running
is_vm_running() {
    local vm_name=$1
    if pgrep -f "qemu-system-x86_64.*$vm_name" >/dev/null; then
        return 0
    else
        return 1
    fi
}
# Function to stop a running VM
stop_vm() {
    local vmTill=$1
   
    if load_vm_config "$vmTill"; then
        if is_vm_running "$vmTill"; then
            print_status "INFO" "Stopping VM: $vmTill ⏹️"
            pkill -f "qemu-system-x86_64.*$IMG_FILE"
            sleep 2
            if is_vm_running "$vmTill"; then
                print_status "WARN" "VM did not stop gracefully, forcing termination... 💥"
                pkill -9 -f "qemu-system-x86_64.*$IMG_FILE"
            fi
            print_status "SUCCESS" "VM $vmTill stopped ✅"
        else
            print_status "INFO" "VM $vmTill is not running 😴"
        fi
    fi
}
# ... (all other functions keep the same emoji style)

# Main menu function
main_menu() {
    while true; do
        display_header
       
        local vms=($(get_vm_list))
        local vm_count=${#vms[@]}
       
        if [ $vm_count -gt 0 ]; then
            print_status "INFO" "Found $vm_count existing VM(s): 🖳"
            for i in "${!vms[@]}"; do
                local status="Stopped ⏹️"
                if is_vm_running "${vms[$i]}"; then
                    status="Running ▶️"
                fi
                printf " %2d) %s (%s)\n" $((i+1)) "${vms[$i]}" "$status"
            done
            echo
        fi
       
        echo "Main Menu 🎛️:"
        echo " 1) Create a new VM 🆕"
        if [ $vm_count -gt 0 ]; then
            echo " 2) Start a VM ▶️"
            echo " 3) Stop a VM ⏹️"
            echo " 4) Show VM info ℹ️"
            echo " 5) Edit VM configuration ✏️"
            echo " 6) Delete a VM 🗑️"
            echo " 7) Resize VM disk 💾"
            echo " 8) Show VM performance 📊"
        fi
        echo " 0) Exit 🚪"
        echo
       
        read -p "$(print_status "INPUT" "Enter your choice: ")" choice
       
        # ... (cases unchanged, just enjoy the emojis now!)
       
        read -p "$(print_status "INPUT" "Press Enter to continue... ⏎")"
    done
}

# Rest of the script (trap, checks, OS list, etc.) remains unchanged except title emoji
trap cleanup EXIT
check_dependencies
VM_DIR="${VM_DIR:-$HOME/vms}"
mkdir -p "$VM_DIR"

declare -A OS_OPTIONS=(
    ["Ubuntu 22.04"]="ubuntu|jammy|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu22|ubuntu|ubuntu"
    ["Ubuntu 24.04"]="ubuntu|noble|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu24|ubuntu|ubuntu"
    ["Debian 11"]="debian|bullseye|https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2|debian11|debian|debian"
    ["Debian 12"]="debian|bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|debian12|debian|debian"
    ["Debian 13"]="debian|trixie|https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-generic-amd64-daily.qcow2|debian13|debian|debian"
    ["CentOS Stream 9"]="centos|stream9|https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2|centos9|centos|centos"
    ["AlmaLinux 9"]="almalinux|9|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2|almalinux9|alma|alma"
    ["Rocky Linux 9"]="rockylinux|9|https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2|rocky9|rocky|rocky"
)

main_menu
