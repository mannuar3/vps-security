#!/bin/bash
# VPS Security Toolkit Menu with Logging + Rotation

# Paths to scripts (adjust if needed)
SECURE_SCRIPT="~/vps-security/secure-vps.sh"
ROLLBACK_SCRIPT="~/vps-security/rollback-ssh.sh"
CHECK_SCRIPT="~/vps-security/check-vps-status.sh"
LOGFILE="~/vps-security/vps-security.log"
MAXSIZE=1048576   # 1 MB in bytes

log_action() {
    # Rotate log if larger than MAXSIZE
    if [ -f "$LOGFILE" ] && [ $(stat -c%s "$LOGFILE") -ge $MAXSIZE ]; then
        mv "$LOGFILE" "${LOGFILE}.$(date '+%Y%m%d-%H%M%S').bak"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Log rotated" > "$LOGFILE"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

while true; do
    clear
    echo "======================================="
    echo "   VPS Security Toolkit Menu"
    echo "======================================="
    echo "1) Secure VPS (firewall, SSH keys, fail2ban, auto updates)"
    echo "2) Rollback SSH (re-enable root + password login)"
    echo "3) Check VPS Status (firewall, SSH, fail2ban, updates)"
    echo "4) Exit"
    echo "======================================="
    read -p "Choose an option [1-4]: " choice

    case $choice in
        1)
            echo "🔒 Running Secure VPS Script..."
            bash $SECURE_SCRIPT
            log_action "Ran secure-vps.sh (hardened VPS)"
            read -p "Press Enter to continue..."
            ;;
        2)
            echo "⚠️ Running Rollback SSH Script..."
            bash $ROLLBACK_SCRIPT
            log_action "Ran rollback-ssh.sh (re-enabled root/password)"
            read -p "Press Enter to continue..."
            ;;
        3)
            echo "📊 Running Check VPS Status Script..."
            bash $CHECK_SCRIPT
            log_action "Ran check-vps-status.sh (audit performed)"
            read -p "Press Enter to continue..."
            ;;
        4)
            echo "👋 Exiting Toolkit. Stay secure!"
            log_action "Exited toolkit menu"
            break
            ;;
        *)
            echo "Invalid option. Please choose 1-4."
            sleep 2
            ;;
    esac
done

