#!/bin/bash
# installPlaywrightFirefox.sh
# Install Firefox browser for use with Crawlee's PlaywrightCrawler
# Usage: ./installPlaywrightFirefox.sh

set -e

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         Firefox Browser Installation for Crawlee${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}ℹ️  Playwright is already included in Crawlee${NC}"
echo -e "${YELLOW}ℹ️  This script will only install the Firefox browser${NC}"
echo ""

cd "$PROJECT_ROOT"

echo -e "${BLUE}🦊 Installing Firefox browser...${NC}"
echo -e "${YELLOW}This may take a few minutes depending on your internet connection${NC}"
echo ""

npx playwright install --with-deps firefox

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Firefox browser installed successfully${NC}"
else
    echo -e "${RED}❌ Failed to install Firefox browser${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Usage example:${NC}"
echo ""
echo "import { PlaywrightCrawler } from 'crawlee';"
echo "import { firefox } from 'playwright';"
echo ""
echo "const crawler = new PlaywrightCrawler({"
echo "  launchContext: {"
echo "    launcher: firefox,"
echo "    launchOptions: {"
echo "      headless: true,"
echo "    },"
echo "  },"
echo "  async requestHandler({ request, page, log }) {"
echo "    const pageTitle = await page.title();"
echo "    log.info(\`URL: \${request.loadedUrl} | Page title: \${pageTitle}\`);"
echo "  },"
echo "});"
echo ""
echo "await crawler.addRequests(['https://example.com']);"
echo "await crawler.run();"
echo ""
