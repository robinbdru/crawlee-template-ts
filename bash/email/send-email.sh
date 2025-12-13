#!/bin/bash
# send-email.sh
# Send email notification via SMTP
# Usage: ./send-email.sh --subject "Subject" --body "Body"

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load environment variables
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
else
    echo "Error: .env file not found"
    exit 1
fi

# Parse arguments
SUBJECT=""
BODY=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --subject=*)
            SUBJECT="${1#*=}"
            shift
            ;;
        --body=*)
            BODY="${1#*=}"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Validate required variables
if [ -z "$EMAIL_FROM" ] || [ -z "$EMAIL_TO" ] || [ -z "$EMAIL_PASSWORD" ]; then
    echo "Error: EMAIL_FROM, EMAIL_TO, and EMAIL_PASSWORD must be set in .env"
    exit 1
fi

if [ -z "$SUBJECT" ] || [ -z "$BODY" ]; then
    echo "Error: --subject and --body are required"
    exit 1
fi

# iCloud SMTP settings
SMTP_SERVER="${SMTP_SERVER:-smtp.mail.me.com}"
SMTP_PORT="${SMTP_PORT:-587}"

# Create email message
EMAIL_MSG="From: $EMAIL_FROM
To: $EMAIL_TO
Subject: $SUBJECT

$BODY
"

# Send email using curl
echo "$EMAIL_MSG" | curl --ssl-reqd \
    --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
    --user "$EMAIL_FROM:$EMAIL_PASSWORD" \
    --mail-from "$EMAIL_FROM" \
    --mail-rcpt "$EMAIL_TO" \
    --upload-file - \
    --silent

if [ $? -eq 0 ]; then
    echo "✅ Email sent successfully"
else
    echo "❌ Failed to send email"
    exit 1
fi
