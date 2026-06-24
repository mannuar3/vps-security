#!/bin/bash
# Secure VPS baseline: SSH keys, firewall, fail2ban, auto updates

# --- Variables ---
# Replace with your actual public key string from ~/.ssh/id_ed25519.pub
PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXAMPLEKEYSTRING user@example.com"

# --- System Update ---
sudo apt update && sudo apt upgrade -y

# --- Firewall Setup (UFW) ---
sudo apt install -y ufw fail2ban unattended-upgrades

sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow 22/tcp

# Block direct VNC (only allow via SSH tunnel)
sudo ufw deny 5901/tcp

# --- SSH Key Configuration ---
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add public key
echo "$PUBKEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Backup sshd_config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Disable root login and password login
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config

# Restart SSH
sudo systemctl restart ssh

# --- Fail2Ban Setup ---
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

cat <<EOF | sudo tee /etc/fail2ban/jail.local
[sshd]
enabled = true
port    = ssh
logpath = /var/log/auth.log
maxretry = 5
EOF

sudo systemctl restart fail2ban

# --- Automatic Security Updates ---
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Ensure unattended-upgrades service is active
sudo systemctl enable unattended-upgrades
sudo systemctl start unattended-upgrades

# --- Final Status ---
sudo ufw status verbose
sudo systemctl status fail2ban --no-pager
sudo systemctl status unattended-upgrades --no-pager

echo "✅ VPS secured: SSH key login only, root disabled, firewall active, fail2ban running, auto updates enabled."

