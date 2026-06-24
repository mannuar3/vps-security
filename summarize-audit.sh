#!/bin/bash
# Summarize last 7 days of VPS audits from vps-security.log

LOGFILE="~/vps-security/vps-security.log"

echo "=== VPS Security Summary (Last 7 Days) ==="
echo ""

# Extract last 7 days of audit headers
grep "=== Daily Audit:" $LOGFILE | tail -n 7 | while read -r line; do
    DATE=$(echo $line | cut -d':' -f2-)
    echo "📅 $DATE"

    # Grab the block of lines for this audit
    BLOCK=$(awk "/$line/,/Status check complete/" $LOGFILE)

    # Check SSH hardened
    if echo "$BLOCK" | grep -q "PermitRootLogin no" && echo "$BLOCK" | grep -q "PasswordAuthentication no"; then
        echo "   🔑 SSH: Hardened"
    else
        echo "   🔑 SSH: Weak"
    fi

    # Check firewall
    if echo "$BLOCK" | grep -q "Status: active"; then
        echo "   🔒 Firewall: Active"
    else
        echo "   🔒 Firewall: Inactive"
    fi

    # Check fail2ban
    if echo "$BLOCK" | grep -q "active (running)"; then
        echo "   🚨 Fail2Ban: Running"
    else
        echo "   🚨 Fail2Ban: Not running"
    fi

    # Check auto updates
    if echo "$BLOCK" | grep -q "APT::Periodic::Unattended-Upgrade \"1\""; then
        echo "   🔄 Auto Updates: Enabled"
    else
        echo "   🔄 Auto Updates: Disabled"
    fi

    echo ""
done

echo "✅ Summary complete."

