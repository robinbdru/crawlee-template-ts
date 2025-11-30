#!/bin/bash

# Script to create a new crawler from a template
# Usage: ./createNewCrawler.sh --type=http --name=my-custom-http

set -e

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default variables
TYPE=""
NAME=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEFAULTS_DIR="$PROJECT_ROOT/src/crawlers/DEFAULTS"
CRAWLERS_DIR="$PROJECT_ROOT/src/crawlers"

# Help function
show_help() {
    echo "Usage: ./createNewCrawler.sh --type=TYPE --name=NAME"
    echo ""
    echo "Options:"
    echo "  --type=TYPE    Crawler type (http, playwright, cheerio, etc.)"
    echo "  --name=NAME    New crawler name"
    echo ""
    echo "Example:"
    echo "  ./createNewCrawler.sh --type=http --name=my-custom-http"
    echo ""
    echo "Available templates in $DEFAULTS_DIR:"
    if [ -d "$DEFAULTS_DIR" ]; then
        ls -1 "$DEFAULTS_DIR" | grep -v "router.ts"
    fi
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        --type=*)
            TYPE="${arg#*=}"
            shift
            ;;
        --name=*)
            NAME="${arg#*=}"
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

# Validate arguments
if [ -z "$TYPE" ]; then
    echo -e "${RED}Error: --type is required${NC}"
    show_help
    exit 1
fi

if [ -z "$NAME" ]; then
    echo -e "${RED}Error: --name is required${NC}"
    show_help
    exit 1
fi

# Convert type to uppercase to match template folder name
TYPE_UPPER=$(echo "$TYPE" | tr '[:lower:]' '[:upper:]')

# Check if type already ends with _CRAWLER
if [[ "$TYPE_UPPER" == *_CRAWLER ]]; then
    TEMPLATE_NAME="$TYPE_UPPER"
else
    TEMPLATE_NAME="${TYPE_UPPER}_CRAWLER"
fi

TEMPLATE_DIR="$DEFAULTS_DIR/$TEMPLATE_NAME"

# Check if template exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo -e "${RED}Error: Template '$TEMPLATE_NAME' does not exist in $DEFAULTS_DIR${NC}"
    echo ""
    echo "Available templates:"
    ls -1 "$DEFAULTS_DIR" | grep -v "router.ts"
    exit 1
fi

# Create destination path
DEST_DIR="$CRAWLERS_DIR/$NAME"

# Check if destination folder already exists
if [ -d "$DEST_DIR" ]; then
    echo -e "${RED}Error: Crawler '$NAME' already exists in $DEST_DIR${NC}"
    exit 1
fi

# Create new crawler
echo -e "${YELLOW}Creating crawler '$NAME' from template '$TEMPLATE_NAME'...${NC}"

# Copy template
cp -r "$TEMPLATE_DIR" "$DEST_DIR"

echo -e "${GREEN}✓ Crawler created successfully in: $DEST_DIR${NC}"
echo ""
echo "Created files:"
find "$DEST_DIR" -type f -exec echo "  - {}" \;
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Customize files in $DEST_DIR"
echo "  2. Modify initial URLs in index.ts"
echo "  3. Implement your logic in router.ts"
echo "  4. Import and use your crawler in src/main.ts"
