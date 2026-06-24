#!/bin/bash
# Post weekly VPS security report to Slack channel

REPORT="~/vps-security/weekly-report.html"
WEBHOOK_URL="https://hooks.slack.com/services/XXXX/XXXX/XXXX"  # Replace with your Slack webhook

# Generate latest report
~/vps-security/generate-report.sh

# Convert HTML to plain text summary (for Slack message body)
SUMMARY=$(grep "=== Daily Audit:" ~/vps-security/vps-security.log | tail -n 7)

# Post to Slack
curl -X POST -H 'Content-type: application/json' \
--data "{
    \"text\": \"📊 Weekly VPS Security Report\n\n$SUMMARY\n\nFull HTML report available on server: $REPORT\"
}" $WEBHOOK_URL

echo "✅ Weekly report posted to Slack channel"

