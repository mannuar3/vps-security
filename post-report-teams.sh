#!/bin/bash
# Post weekly VPS security report to Microsoft Teams channel

REPORT="$HOME/vps-security/weekly-report.html"
WEBHOOK_URL="https://outlook.office.com/webhook/XXXX/IncomingWebhook/XXXX/XXXX"  # Replace with Teams webhook

# Generate latest report
$HOME/vps-security/generate-report.sh

# Convert HTML to plain text summary (for Teams message body)
SUMMARY=$(grep "=== Daily Audit:" $HOME/vps-security.log | tail -n 7)

# Post to Teams
curl -H "Content-Type: application/json" -d "{
    \"text\": \"📊 Weekly VPS Security Report\n\n$SUMMARY\n\nFull HTML report available on server: $REPORT\"
}" $WEBHOOK_URL

echo "✅ Weekly report posted to Teams channel"

