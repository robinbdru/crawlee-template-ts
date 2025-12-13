#!/bin/bash
# status.sh
# Check validation status of today's uploaded datasets or the latest upload
# Verifies if uploaded files have been approved or refused by the data validation system
# Usage: ./status.sh [OPTIONS]

set -e

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
S3_PATH=""
STATUS_FILTER=""
CHECK_LATEST=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Help function
show_help() {
    echo "Usage: ./status.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --status=STATUS    Filter by status: approved, refused, or all (default: all)"
    echo "  --date=DATE        Check files for a specific date (YYYY-MM-DD, default: today)"
    echo "  --latest           Check the most recent upload (ignores --date)"
    echo "  --path=PATH        Specific S3 path to check"
    echo "  --help, -h         Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./status.sh                           # Check today's uploads"
    echo "  ./status.sh --latest                  # Check the most recent upload"
    echo "  ./status.sh --status=approved         # Check today's approved files only"
    echo "  ./status.sh --date=2024-01-15         # Check specific date"
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        --status=*)
            STATUS_FILTER="${arg#*=}"
            shift
            ;;
        --date=*)
            DATE="${arg#*=}"
            shift
            ;;
        --latest)
            CHECK_LATEST=true
            shift
            ;;
        --path=*)
            S3_PATH="${arg#*=}"
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

# Validate status filter
if [ -n "$STATUS_FILTER" ] && [ "$STATUS_FILTER" != "approved" ] && [ "$STATUS_FILTER" != "refused" ] && [ "$STATUS_FILTER" != "all" ]; then
    echo -e "${RED}Error: Invalid status. Must be 'approved', 'refused', or 'all'${NC}"
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

# Validate AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${RED}Error: AWS credentials are not set in .env file${NC}"
    exit 1
fi

# Build S3 path
S3_BUCKET="${S3_BUCKET:-databoutique.com}"

if [ -n "$S3_PATH" ]; then
    FULL_S3_PATH="s3://$S3_BUCKET/$S3_PATH"
    DISPLAY_DATE="custom path"
elif [ "$CHECK_LATEST" = true ]; then
    # Check for latest upload across all dates
    if [ -z "$SELLER_ID" ] || [ -z "$CONTRACT_ID" ]; then
        echo -e "${RED}Error: SELLER_ID and CONTRACT_ID must be set in .env${NC}"
        exit 1
    fi
    FULL_S3_PATH="s3://$S3_BUCKET/sellers/$SELLER_ID/$CONTRACT_ID/"
    DISPLAY_DATE="latest upload"
else
    # Use provided date or default to today
    if [ -z "$DATE" ]; then
        DATE=$(date +%Y-%m-%d)
        DISPLAY_DATE="today ($DATE)"
    else
        DISPLAY_DATE="$DATE"
    fi
    
    if [ -z "$SELLER_ID" ] || [ -z "$CONTRACT_ID" ]; then
        echo -e "${RED}Error: SELLER_ID and CONTRACT_ID must be set in .env${NC}"
        exit 1
    fi
    FULL_S3_PATH="s3://$S3_BUCKET/sellers/$SELLER_ID/$CONTRACT_ID/$DATE/"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}            DATASET VALIDATION STATUS CHECK${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}S3 Bucket:${NC}      $S3_BUCKET"
echo -e "${YELLOW}Path:${NC}           $FULL_S3_PATH"
echo -e "${YELLOW}Checking:${NC}       $DISPLAY_DATE"
ec

if [ -z "$ALL_FILES" ]; then
    echo -e "${YELLOW}No files found for $DISPLAY_DATE${NC}"
    exit 0
fiho -e "${YELLOW}Status Filter:${NC}  ${STATUS_FILTER:-all}"
echo ""
echo -e "${BLUE}Checking dataset validation status...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# List all files
if [ "$CHECK_LATEST" = true ]; then
    # Get the latest directory (most recent date)
    LATEST_DIR=$(aws s3 ls "$FULL_S3_PATH" | grep "PRE" | tail -n 1 | awk '{print $2}' | tr -d '/')
    
    if [ -z "$LATEST_DIR" ]; then
        echo -e "${YELLOW}No uploads found${NC}"
        exit 0
    fi
    
    FULL_S3_PATH="$FULL_S3_PATH$LATEST_DIR/"
    echo -e "${BLUE}Latest upload found: $LATEST_DIR${NC}"
    echo ""
fi

ALL_FILES=$(aws s3 ls "$FULL_S3_PATH" --recursive)

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to list files from S3${NC}"
    exit 1
fi

# Filter files based on status
if [ -z "$STATUS_FILTER" ] || [ "$STATUS_FILTER" = "all" ]; then
    APPROVED_FILES=$(echo "$ALL_FILES" | grep -i "approved" || true)
    REFUSED_FILES=$(echo "$ALL_FILES" | grep -i "refused" || true)
    
    echo -e "${GREEN}✓ APPROVED FILES:${NC}"
    if [ -n "$APPROVED_FILES" ]; then
        echo "$APPROVED_FILES" | awk '{printf "  %s %s  %-10s  %s\n", $1, $2, $3, $4}'
        APPROVED_COUNT=$(echo "$APPROVED_FILES" | wc -l | tr -d ' ')
    else
        echo "  No approved files found"
        APPROVED_COUNT=0
    fi
    
    echo ""
    echo -e "${RED}✗ REFUSED FILES:${NC}"
    if [ -n "$REFUSED_FILES" ]; then
        echo "$REFUSED_FILES" | awk '{printf "  %s %s  %-10s  %s\n", $1, $2, $3, $4}'
        REFUSED_COUNT=$(echo "$REFUSED_FILES" | wc -l | tr -d ' ')
    else
        echo "  No refused files found"
        REFUSED_COUNT=0
    fi
    
    echo ""
    echo -e "${BLUE}══Validation Summary:${NC}"
    echo -e "  ${GREEN}Approved (conformant):${NC} $APPROVED_COUNT dataset(s)"
    echo -e "  ${RED}Refused (non-conformant):${NC}  $REFUSED_COUNT dataset(s)les"
    echo -e "  ${RED}Refused:${NC}  $REFUSED_COUNT files"
    
elif [ "$STATUS_FILTER" = "approved" ]; then
    APPROVED_FILES=$(echo "$ALL_FILES" | grep -i "approved" || true)
    
    echo -e "${GREEN}✓ APPROVED FILES:${NC}"
    if [ -n "$APPROVED_FILES" ]; then
        echo "$APPROVED_FILES" | awk '{printf "  %s %s  %-10s  %s\n", $1, $2, $3, $4}'
        APPROVED_COUNT=$(echo "$APPROVED_FILES" | wc -l | tr -d ' ')
        echo ""
        echo -e "${GREEN}Total: $APPROVED_COUNT approved file(s)${NC}"
    else
        echo "  No approved files found"
    fi
    
elif [ "$STATUS_FILTER" = "refused" ]; then
    REFUSED_FILES=$(echo "$ALL_FILES" | grep -i "refused" || true)
    
    echo -e "${RED}✗ REFUSED FILES:${NC}"
    if [ -n "$REFUSED_FILES" ]; then
        echo "$REFUSED_FILES" | awk '{printf "  %s %s  %-10s  %s\n", $1, $2, $3, $4}'
        REFUSED_COUNT=$(echo "$REFUSED_FILES" | wc -l | tr -d ' ')
        echo ""
        echo -e "${RED}Total: $REFUSED_COUNT refused file(s)${NC}"
    else
        echo "  No refused files found"
    fi
fi

echo ""
echo -e "${GREEN}✅ Status check complete!${NC}"
