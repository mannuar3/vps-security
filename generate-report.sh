#!/bin/bash
# Generate weekly HTML summary from vps-security.log

LOGFILE="~/vps-security/vps-security.log"
REPORT="~/vps-security/weekly-report.html"

echo "<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'>
<title>VPS Security Weekly Report</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
h1 { color: #2c3e50; }
table { border-collapse: collapse; width: 100%; margin-top: 20px; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
th { background-color: #f4f4f4; }
.pass { background-color: #d4edda; color: #155724; }
.fail { background-color: #f8d7da; color: #721c24; }
</style>
</head>
<body>
<h1>VPS Security Weekly Report</h1>
<table>
<tr>
<th>Date</th>
<th>SSH</th>
<th>Firewall</th>
<th>Fail2Ban</th>
<th>Auto Updates</th>
</tr>" > $REPORT

# Extract last 7 audits
grep "=== Daily Audit:" $LOGFILE | tail -n 7 | while read -r line; do
    DATE=$(echo $line | cut -d':' -f2-)
    BLOCK=$(awk "/$line/,/Status check complete/" $LOGFILE)

    # Checks
    SSH="fail"
    FIREWALL="fail"
    FAIL2BAN="fail"
    UPDATES="fail"

    if echo "$BLOCK" | grep -q "PermitRootLogin no" && echo "$BLOCK" | grep -q "PasswordAuthentication no"; then
        SSH="pass"
    fi
    if echo "$BLOCK" | grep -q "Status: active"; then
        FIREWALL="pass"
    fi
    if echo "$BLOCK" | grep -q "active (running)"; then
        FAIL2BAN="pass"
    fi
    if echo "$BLOCK" | grep -q "APT::Periodic::Unattended-Upgrade \"1\""; then
        UPDATES="pass"
    fi

    echo "<tr>
    <td>$DATE</td>
    <td class='$SSH'>${SSH^^}</td>
    <td class='$FIREWALL'>${FIREWALL^^}</td>
    <td class='$FAIL2BAN'>${FAIL2BAN^^}</td>
    <td class='$UPDATES'>${UPDATES^^}</td>
    </tr>" >> $REPORT
done

echo "</table>
</body>
</html>" >> $REPORT

echo "✅ Weekly HTML report generated: $REPORT"

