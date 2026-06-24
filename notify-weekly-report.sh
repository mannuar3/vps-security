#!/bin/bash
# Combined notifier: email + Slack/Teams using secure config loader

CONFIG="$HOME/vps-security/config.env"
REPORT="$HOME/vps-security/weekly-report.html"
LOGFILE="$HOME/vps-security/vps-security.log"

# Load config silently (no echo)
set -a
source $CONFIG
set +a

# Generate latest report
$HOME/vps-security/generate-report.sh

# --- Email Section ---
IFS=',' read -ra RECIPIENTS <<< "$EMAIL_RECIPIENTS"
for RECIPIENT in "${RECIPIENTS[@]}"; do
    mail -s "$EMAIL_SUBJECT" -a $REPORT $RECIPIENT <<EOF
Hello,

Attached is the weekly VPS Security Report generated on $(date '+%Y-%m-%d %H:%M:%S').

Summary log entries:
$(tail -n 20 $LOGFILE)

Regards,
VPS Security Toolkit
EOF
    echo "✅ Report emailed to $RECIPIENT"
done

# --- Slack Section ---
SUMMARY=$(grep "=== Daily Audit:" $LOGFILE | tail -n 7)
curl -s -X POST -H 'Content-type: application/json' \
--data "{
    \"text\": \"📊 Weekly VPS Security Report\n\n$SUMMARY\n\nFull HTML report available on server: $REPORT\"
}" $SLACK_WEBHOOK > /dev/null
echo "✅ Report posted to Slack"

# --- Teams Section ---
curl -s -H "Content-Type: application/json" -d "{
    \"text\": \"📊 Weekly VPS Security Report\n\n$SUMMARY\n\nFull HTML report available on server: $REPORT\"
}" $TEAMS_WEBHOOK > /dev/null
echo "✅ Report posted to Teams"

