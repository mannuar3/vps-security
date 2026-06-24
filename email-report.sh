#!/bin/bash
# Email the weekly VPS security report to multiple recipients

REPORT="~/vps-security/weekly-report.html"
LOGFILE="~/vps-security/vps-security.log"
TO=("your-email@example.com" "teammate@example.com" "family@example.com")  # Add as many as needed
SUBJECT="Weekly VPS Security Report"

# Generate the latest report before sending
~/vps-security/generate-report.sh

# Loop through recipients and send individually
for RECIPIENT in "${TO[@]}"; do
    mail -s "$SUBJECT" -a $REPORT $RECIPIENT <<EOF
Hello,

Attached is the weekly VPS Security Report generated on $(date '+%Y-%m-%d %H:%M:%S').

Summary log entries:
$(tail -n 20 $LOGFILE)

Regards,
VPS Security Toolkit
EOF
    echo "✅ Weekly report emailed to $RECIPIENT"
done

