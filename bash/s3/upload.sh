#!/bin/bash
# upload.sh
# Upload a file to S3 with confirmation
# Usage: ./upload.sh --file=path/to/file.txt

set -e

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
FILE_PATH=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Help function
show_help() {
    echo "Usage: ./upload.sh --file=FILE_PATH"
    echo ""
    echo "Options:"
    echo "  --file=PATH    Path to the file to upload (required)"
    echo "  --help, -h     Show this help message"
    echo ""
    echo "Example:"
    echo "  ./upload.sh --file=exports/2024-01-15/data_file.txt"
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        --file=*)
            FILE_PATH="${arg#*=}"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown argument: $arg${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Validate file path argument
if [ -z "$FILE_PATH" ]; then
    echo -e "${RED}Error: --file is required${NC}"
    show_help
    exit 1
fi

# Convert to absolute path if relative
if [[ "$FILE_PATH" != /* ]]; then
    FILE_PATH="$PROJECT_ROOT/$FILE_PATH"
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo -e "${RED}Error: File not found: $FILE_PATH${NC}"
    exit 1
fi

# Load environment variables
ENV_FILE="$PROJECT_ROOT/.env"
if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
else
    echo -e "${RED}Error: .env file not found at $ENV_FILE${NC}"
    exit 1
fi

# Validate required environment variables
if [ -z "$SELLER_ID" ]; then
    echo -e "${RED}Error: SELLER_ID is not set in .env file${NC}"
    exit 1
fi

if [ -z "$CONTRACT_ID" ]; then
    echo -e "${YELLOW}Warning: CONTRACT_ID is not set in .env file${NC}"
    echo "Continue anyway? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        exit 1
    fi
fi

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${RED}Error: AWS credentials are not set in .env file${NC}"
    exit 1
fi

# Get current date in YYYY-MM-DD format
CURRENT_DATE=$(date +%Y-%m-%d)

# Get filename from path
FILENAME=$(basename "$FILE_PATH")

# Build S3 path
S3_BUCKET="${S3_BUCKET:-databoutique.com}"
S3_PATH="s3://$S3_BUCKET/sellers/$SELLER_ID/$CONTRACT_ID/$CURRENT_DATE/$FILENAME"

# Get file size
FILE_SIZE=$(ls -lh "$FILE_PATH" | awk '{print $5}')

# Display upload information
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    UPLOAD CONFIRMATION${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Local file:${NC}     $FILE_PATH"
echo -e "${YELLOW}File size:${NC}      $FILE_SIZE"
echo -e "${YELLOW}S3 bucket:${NC}      $S3_BUCKET"
echo -e "${YELLOW}S3 path:${NC}        $S3_PATH"
echo ""
echo -e "${YELLOW}AWS credentials:${NC}"
echo -e "  Access Key ID: ${AWS_ACCESS_KEY_ID:0:8}...${AWS_ACCESS_KEY_ID: -4}"
echo -e "  Seller ID:     $SELLER_ID"
echo -e "  Contract ID:   ${CONTRACT_ID:-<not set>}"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Do you want to proceed with the upload? (y/n)${NC}"
read -r confirm

if [ "$confirm" != "y" ]; then
    echo -e "${YELLOW}Upload cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}📤 Uploading file to S3...${NC}"

# Upload to S3
aws s3 cp "$FILE_PATH" "$S3_PATH"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Upload successful!${NC}"
    echo -e "${GREEN}File uploaded to: $S3_PATH${NC}"
else
    echo ""
    echo -e "${RED}❌ Upload failed!${NC}"
    exit 1
fi
