#!/bin/bash
# Check VPS security status: firewall, SSH, fail2ban, auto updates

echo ""
echo "=== Daily Audit: $(date '+%Y-%m-%d %H:%M:%S') ==="

echo "=== 🔒 Firewall (UFW) Status ==="
sudo ufw status verbose

echo ""
echo "=== 🔑 SSH Configuration ==="
grep -E "PermitRootLogin|PasswordAuthentication|ChallengeResponseAuthentication" /etc/ssh/sshd_config

echo ""
echo "=== 🚨 Fail2Ban Status ==="
sudo systemctl status fail2ban --no-pager | grep Active
sudo fail2ban-client status sshd

echo ""
echo "=== 🔄 Auto Updates (Unattended-Upgrades) ==="
sudo systemctl status unattended-upgrades --no-pager | grep Active
cat /etc/apt/apt.conf.d/20auto-upgrades

echo ""
echo "✅ Status check complete."

