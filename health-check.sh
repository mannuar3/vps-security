#!/bin/bash
# VPS Security Toolkit Health Check with Self-Healing + Notifications

CONFIG="~/vps-security/config.env"
LOGFILE="~/vps-security/vps-security.log"
REPORT="~/vps-security/weekly-report.html"
CRON_TEMPLATE="~/vps-security/cron-template.txt"

# Load config silently
set -a
source $CONFIG
set +a

notify() {
    MESSAGE="$1"

    # Email notification
    IFS=',' read -ra RECIPIENTS <<< "$EMAIL_RECIPIENTS"
    for RECIPIENT in "${RECIPIENTS[@]}"; do
        mail -s "⚠️ VPS Health Check Alert" $RECIPIENT <<EOF
Hello,

Health check detected and fixed an issue:

$MESSAGE

Timestamp: $(date '+%Y-%m-%d %H:%M:%S')

Regards,
VPS Security Toolkit
EOF
    done

    # Slack notification
    curl -s -X POST -H 'Content-type: application/json' \
    --data "{\"text\": \"⚠️ VPS Health Check Alert\n\n$MESSAGE\n\nTimestamp: $(date '+%Y-%m-%d %H:%M:%S')\"}" $SLACK_WEBHOOK > /dev/null

    # Teams notification
    curl -s -H "Content-Type: application/json" -d "{\"text\": \"⚠️ VPS Health Check Alert\n\n$MESSAGE\n\nTimestamp: $(date '+%Y-%m-%d %H:%M:%S')\"}" $TEAMS_WEBHOOK > /dev/null
}

echo "=== Health Check: $(date '+%Y-%m-%d %H:%M:%S') ==="

# --- Cron Jobs ---
CRON_JOBS=$(crontab -l | grep vps-security)
if [ -z "$CRON_JOBS" ]; then
    if [ -f "$CRON_TEMPLATE" ]; then
        crontab $CRON_TEMPLATE
        notify "Cron jobs were missing and have been restored from template."
    fi
fi

# --- Log Rotation ---
if [ -f "$LOGFILE" ]; then
    SIZE=$(stat -c%s "$LOGFILE")
    if [ $SIZE -ge 1048576 ]; then
        mv "$LOGFILE" "${LOGFILE}.$(date '+%Y%m%d-%H%M%S').bak"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Log rotated by health check" > "$LOGFILE"
        notify "Log file exceeded 1MB and was rotated."
    fi
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - New log created by health check" > "$LOGFILE"
    notify "Log file was missing and has been recreated."
fi

# --- Report File ---
if [ ! -f "$REPORT" ]; then
    ~/vps-security/generate-report.sh
    notify "Weekly report was missing and has been regenerated."
fi

echo "Health check complete."

