#!/bin/bash
# Generate weekly health summary digest

CONFIG="~/vps-security/config.env"
LOGFILE="~/vps-security/vps-security.log"
SUMMARY="~/vps-security/weekly-health-summary.txt"

# Load config silently
set -a
source $CONFIG
set +a

echo "=== VPS Weekly Health Summary ===" > $SUMMARY
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> $SUMMARY
echo "" >> $SUMMARY

# Count fixes
CRON_FIXES=$(grep "Cron jobs restored" $LOGFILE | tail -n 20 | wc -l)
LOG_ROTATIONS=$(grep "Log rotated" $LOGFILE | tail -n 20 | wc -l)
REPORT_REGENS=$(grep "Weekly report regenerated" $LOGFILE | tail -n 20 | wc -l)

# Status summary
if [ $CRON_FIXES -eq 0 ] && [ $LOG_ROTATIONS -eq 0 ] && [ $REPORT_REGENS -eq 0 ]; then
    echo "✅ All systems OK this week. No self-healing actions required." >> $SUMMARY
else
    echo "⚠️ Issues detected and fixed this week:" >> $SUMMARY
    echo "   - Cron jobs restored: $CRON_FIXES times" >> $SUMMARY
    echo "   - Log rotations: $LOG_ROTATIONS times" >> $SUMMARY
    echo "   - Reports regenerated: $REPORT_REGENS times" >> $SUMMARY
fi

echo "" >> $SUMMARY
echo "End of summary." >> $SUMMARY

# --- Email Digest ---
IFS=',' read -ra RECIPIENTS <<< "$EMAIL_RECIPIENTS"
for RECIPIENT in "${RECIPIENTS[@]}"; do
    mail -s "📊 VPS Weekly Health Summary" $RECIPIENT < $SUMMARY
done

# --- Slack Digest ---
curl -s -X POST -H 'Content-type: application/json' \
--data "{\"text\": \"$(cat $SUMMARY)\"}" $SLACK_WEBHOOK > /dev/null

# --- Teams Digest ---
curl -s -H "Content-Type: application/json" -d "{\"text\": \"$(cat $SUMMARY)\"}" $TEAMS_WEBHOOK > /dev/null

echo "✅ Weekly health summary sent to email, Slack, and Teams"

