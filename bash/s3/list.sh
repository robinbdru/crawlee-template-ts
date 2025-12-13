#!/bin/bash
# list.sh
# List files from S3 bucket
# Usage: ./list.sh [--path=optional/path]

set -e

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
S3_PATH=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Help function
show_help() {
    echo "Usage: ./list.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --path=PATH    Specific S3 path to list (optional)"
    echo "  --date=DATE    List files for a specific date (YYYY-MM-DD)"
    echo "  --help, -h     Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./list.sh                                    # List all files"
    echo "  ./list.sh --date=2024-01-15                  # List files for specific date"
    echo "  ./list.sh --path=sellers/123/contract/456    # List specific path"
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        --path=*)
            S3_PATH="${arg#*=}"
            shift
            ;;
        --date=*)
            DATE="${arg#*=}"
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

# Load environment variables
ENV_FILE="$PROJECT_ROOT/.env"
if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
else
    echo -e "${RED}Error: .env file not found at $ENV_FILE${NC}"
    exit 1
fi

# Validate AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${RED}Error: AWS credentials are not set in .env file${NC}"
    exit 1
fi

# Build S3 path
S3_BUCKET="${S3_BUCKET:-databoutique.com}"

if [ -n "$S3_PATH" ]; then
    # User provided specific path
    FULL_S3_PATH="s3://$S3_BUCKET/$S3_PATH"
elif [ -n "$DATE" ]; then
    # List files for specific date
    if [ -z "$SELLER_ID" ] || [ -z "$CONTRACT_ID" ]; then
        echo -e "${RED}Error: SELLER_ID and CONTRACT_ID must be set in .env for date filtering${NC}"
        exit 1
    fi
    FULL_S3_PATH="s3://$S3_BUCKET/sellers/$SELLER_ID/$CONTRACT_ID/$DATE/"
else
    # List all files for seller/contract
    if [ -z "$SELLER_ID" ]; then
        echo -e "${YELLOW}Warning: SELLER_ID not set, listing entire bucket${NC}"
        FULL_S3_PATH="s3://$S3_BUCKET/"
    elif [ -z "$CONTRACT_ID" ]; then
        echo -e "${YELLOW}Warning: CONTRACT_ID not set, listing all contracts for seller${NC}"
        FULL_S3_PATH="s3://$S3_BUCKET/sellers/$SELLER_ID/"
    else
        FULL_S3_PATH="s3://$S3_BUCKET/sellers/$SELLER_ID/$CONTRACT_ID/"
    fi
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    S3 FILE LISTING${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}S3 Bucket:${NC}      $S3_BUCKET"
echo -e "${YELLOW}Path:${NC}           $FULL_S3_PATH"
echo -e "${YELLOW}Access Key:${NC}     ${AWS_ACCESS_KEY_ID:0:8}...${AWS_ACCESS_KEY_ID: -4}"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# List files
aws s3 ls "$FULL_S3_PATH" --recursive --human-readable --summarize

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Listing complete!${NC}"
else
    echo ""
    echo -e "${RED}❌ Failed to list files!${NC}"
    exit 1
fi
