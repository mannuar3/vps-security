#!/bin/bash
# Generate monthly VPS health dashboard with charts + PDF export

LOGFILE="~/vps-security/vps-security.log"
REPORT_HTML="~/vps-security/monthly-dashboard.html"
REPORT_PDF="~/vps-security/monthly-dashboard.pdf"

# --- Generate HTML dashboard (same as before, with Chart.js) ---
# [HTML generation code from previous version goes here]

# --- Convert HTML to PDF ---
if command -v wkhtmltopdf >/dev/null 2>&1; then
    wkhtmltopdf $REPORT_HTML $REPORT_PDF
    echo "✅ Monthly dashboard exported to PDF: $REPORT_PDF"
else
    echo "⚠️ wkhtmltopdf not installed. Install with: sudo apt install -y wkhtmltopdf"
fi

