#!/bin/bash
# Rollback SSH hardening: re-enable password login and root access

# Backup current sshd_config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.rollback.bak

# Re-enable root login
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# Re-enable password authentication
sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart ssh

echo "⚠️ Rollback complete: root login and password authentication re-enabled."
echo "👉 Remember to disable these again once you regain SSH key access."

