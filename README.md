# Crawlee TypeScript Template

A (opinionated) production-ready template for building web crawlers with Crawlee and TypeScript. This template provides a structured foundation with built-in utilities, multiple crawler types, and easy-to-use scripts for rapid development.

## Requirements

-   **Node.js**: v18.0.0 or higher
-   **npm**: v9.0.0 or higher (or yarn/pnpm equivalent)
-   **Operating System**: macOS, Linux, or Windows with WSL2
-   **Optional**: AWS CLI (for S3 upload functionality)

## Features

-   **Multiple Crawler Templates**: Pre-configured HTTP, Cheerio, and Firefox (Playwright) crawlers
-   **TypeScript Support**: Full type safety with path aliases
-   **Proxy Management**: Built-in support for datacenter and residential proxies
-   **Dataset Management**: Easy data export and AWS S3 integration
-   **CLI Tools**: Convenient bash scripts for common tasks
-   **AI-Friendly**: Includes LLM instructions template for AI-assisted development

## Quick Start

### Installation

```bash
npm install
```

### Make Scripts Executable

```bash
npm run scripts:allow
```

### Create Your First Crawler

```bash
# Create an HTTP crawler (fast, lightweight)
npm run crawler:new -- --type=http --name=my-crawler

# Create a Cheerio crawler (HTML parsing with jQuery-like syntax)
npm run crawler:new -- --type=cheerio --name=my-cheerio-crawler

# Create a Firefox crawler (JavaScript rendering)
npm run crawler:new -- --type=firefox --name=my-browser-crawler
```

### Add Crawler to main.ts

After creating a crawler, import and run it in `src/main.ts`:

```typescript
// src/main.ts
import myCrawler from "./crawlers/my-crawler/index.js";

// Run the crawler
await myCrawler.run();

console.log("Crawler finished!");
```

**Multiple crawlers example:**

```typescript
// src/main.ts
import httpCrawler from "./crawlers/products-crawler/index.js";
import firefoxCrawler from "./crawlers/reviews-crawler/index.js";

// Run crawlers sequentially
await httpCrawler.run();
console.log("Product crawler finished!");

await firefoxCrawler.run();
console.log("Reviews crawler finished!");

// Or run in parallel
// await Promise.all([
//     httpCrawler.run(),
//     firefoxCrawler.run()
// ]);
```

### Run the Crawler

```bash
npm run start
```

## Project Structure

```
crawlee-template-ts/
├── src/
│   ├── main.ts                    # Application entry point
│   ├── crawlers/
│   │   ├── DEFAULTS/              # Crawler templates
│   │   │   ├── HTTP_CRAWLER/      # HTTP crawler template
│   │   │   ├── CHEERIO_CRAWLER/   # Cheerio crawler template
│   │   │   └── FIREFOX_CRAWLER/   # Playwright Firefox template
│   │   └── [your-crawlers]/       # Your custom crawlers
│   ├── utils/                     # Utility functions
│   │   └── index.ts               # Proxy loader and helpers
│   ├── types/                     # TypeScript type definitions
│   └── schemas/                   # Data validation schemas
├── bash/
│   ├── crawlers/                  # Crawler management scripts
│   │   ├── createNewCrawler.sh    # Create crawler from template
│   │   └── installPlaywrightFirefox.sh
│   └── s3/                        # AWS S3 upload utilities
│       └── upload.sh              # Upload datasets to S3
├── proxies/                       # Proxy configuration
│   ├── proxy-datacenter.txt       # Datacenter proxy URLs
│   └── proxy-residential.txt      # Residential proxy URLs
└── storage/                       # Local data storage
    └── datasets/                  # Crawler output data
```

## Available Commands

### Development

```bash
npm run start              # Run the crawler (development mode)
npm run start:dev          # Same as above
npm run start:prod         # Run production build
npm run build              # Build TypeScript to JavaScript
```

### Crawler Management

```bash
# Create a new crawler from template
npm run crawler:new -- --type=http --name=my-crawler
npm run crawler:new -- --type=cheerio --name=cheerio-crawler
npm run crawler:new -- --type=firefox --name=browser-crawler

# Install Playwright Firefox browser
npm run crawler:install-playwright

# View help
npm run crawler:new -- --help
```

### Utilities

```bash
# Make all bash scripts executable
npm run scripts:allow
```

## Path Aliases

The following import aliases are configured:

```typescript
import { loadProxies } from "#utils/index.js";
import type { MyType } from "#types/index.js";
import { schema } from "#schemas/index.js";
```

-   `#utils` → `./src/utils`
-   `#actors` → `./src/actors`
-   `#schemas` → `./src/schemas`
-   `#types` → `./src/types`

## Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# AWS S3 Configuration (optional)
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
SELLER_ID=your_seller_id
CONTRACT_ID=your_contract_id
S3_BUCKET=your-bucket-name

# Proxy Configuration (optional)
PROXIES_PATH=proxies
DATACENTER_PROXIES_FILE=proxy-datacenter.txt
RESIDENTIAL_PROXIES_FILE=proxy-residential.txt
```

### Proxy Setup

Add proxy URLs to the proxy files (one per line):

**proxies/proxy-datacenter.txt**

```
http://user:pass@proxy1.example.com:8080
http://user:pass@proxy2.example.com:8080
```

**proxies/proxy-residential.txt**

```
http://user:pass@residential1.example.com:8080
http://user:pass@residential2.example.com:8080
```

The template automatically handles empty proxy files and will run without proxies if none are configured.

## Crawler Templates

### HTTP Crawler

Fast and lightweight for simple HTTP requests. Best for static websites or APIs.

```typescript
import { HttpCrawler } from "crawlee";

const crawler = new HttpCrawler({
    maxConcurrency: 50,
    requestHandler: async ({ request, log }) => {
        log.info(`Processing: ${request.url}`);
    },
});
```

**Features:**

-   High concurrency (up to 50+ simultaneous requests)
-   Low memory footprint
-   No JavaScript rendering

### Cheerio Crawler

Fast HTML parsing with jQuery-like syntax. Best for static websites that don't require JavaScript rendering.

```typescript
import { CheerioCrawler } from "crawlee";

const crawler = new CheerioCrawler({
    maxConcurrency: 30,
    requestHandler: async ({ request, $, log }) => {
        const title = $("title").text();
        log.info(`Title: ${title}`);
    },
});
```

**Features:**

-   jQuery-like API for HTML parsing
-   Moderate concurrency (up to 30+ simultaneous requests)
-   Fast and efficient for static content
-   No browser overhead

### Firefox Crawler (Playwright)

Full browser automation with Firefox. Best for JavaScript-heavy websites.

```typescript
import { PlaywrightCrawler } from "crawlee";
import { firefox } from "playwright";

const crawler = new PlaywrightCrawler({
    launchContext: {
        launcher: firefox,
        launchOptions: { headless: true },
    },
    requestHandler: async ({ request, page, log }) => {
        const title = await page.title();
        log.info(`Title: ${title}`);
    },
});
```

**Features:**

-   Full JavaScript rendering
-   Browser interactions (click, scroll, type)
-   Screenshot and PDF generation
-   Lower concurrency (recommended: 10 or less)

## Data Export

### Local Storage

Data is automatically saved to `./storage/datasets/[DATASET_NAME]/` in JSON format.

```typescript
await dataset.pushData({
    url: request.url,
    title: pageTitle,
    // ... your data
});
```

### AWS S3 Upload

Upload datasets to S3 with confirmation:

```bash
./bash/s3/upload.sh --file=storage/datasets/default/000001.json
```

The script will:

1. Load AWS credentials from `.env`
2. Display upload details
3. Ask for confirmation
4. Upload to S3 with proper path structure

## AI-Assisted Development

This template includes `LLM-INSTRUCTIONS.md`, a comprehensive guide for AI assistants. Fill it out to:

-   Define crawling objectives
-   Document extraction strategy
-   Specify data structure
-   Configure anti-bot measures
-   Track implementation progress

This enables effective collaboration with AI coding assistants like GitHub Copilot, ChatGPT, or Claude.

## Examples

### Basic HTTP Crawler

```typescript
import { HttpCrawler, Dataset } from "crawlee";

const dataset = await Dataset.open();

const crawler = new HttpCrawler({
    maxConcurrency: 20,
    async requestHandler({ request, body, log }) {
        log.info(`Scraping: ${request.url}`);

        // Extract data from HTML
        const data = {
            url: request.url,
            // ... your extraction logic
        };

        await dataset.pushData(data);
    },
});

await crawler.addRequests(["https://example.com"]);
await crawler.run();
```

### Cheerio Crawler with Routing

```typescript
import { CheerioCrawler, createCheerioRouter, Dataset } from "crawlee";

const dataset = await Dataset.open();
const router = createCheerioRouter();

router.addDefaultHandler(async ({ $, enqueueLinks, log }) => {
    // Extract product links and enqueue them
    await enqueueLinks({
        selector: "a.product-link",
        label: "DETAIL",
    });

    log.info("Enqueued product links");
});

router.addHandler("DETAIL", async ({ $, request, log }) => {
    const title = $("h1.product-title").text();
    const price = $(".price").text();
    const description = $(".description").text();

    await dataset.pushData({
        url: request.url,
        title,
        price,
        description,
    });

    log.info(`Scraped product: ${title}`);
});

const crawler = new CheerioCrawler({
    requestHandler: router,
});

await crawler.addRequests(["https://example.com/products"]);
await crawler.run();
```

### Firefox Crawler with Routing

```typescript
import { PlaywrightCrawler, createPlaywrightRouter } from "crawlee";
import { firefox } from "playwright";

const router = createPlaywrightRouter();

router.addDefaultHandler(async ({ page, enqueueLinks }) => {
    await enqueueLinks({
        selector: "a.product-link",
        label: "DETAIL",
    });
});

router.addHandler("DETAIL", async ({ page, request, log }) => {
    const title = await page.textContent("h1");
    log.info(`Product: ${title}`);
});

const crawler = new PlaywrightCrawler({
    launchContext: { launcher: firefox },
    requestHandler: router,
});
```

## Troubleshooting

### Playwright Installation Issues

Playwright (included in Crawlee) requires specific browser binaries to operate. Each version of Crawlee/Playwright supports specific browser versions.

**Install Firefox browser:**

```bash
# Using the built-in script
npm run crawler:install-playwright

# Or manually
npx playwright install firefox
```

**Install system dependencies (Linux/CI environments):**

```bash
# Install OS dependencies for Firefox
npx playwright install-deps firefox

# Or install browsers with dependencies in one command
npx playwright install --with-deps firefox
```

**Common issues:**

-   If you update Crawlee, you may need to reinstall browsers: `npx playwright install`
-   Check Playwright version: `npx playwright --version`
-   See [Playwright system requirements](https://playwright.dev/docs/browsers#install-system-dependencies) for supported operating systems

### Proxy Connection Errors

-   Verify proxy URLs are correctly formatted
-   Test proxies individually
-   Check authentication credentials
-   Review proxy provider documentation

### TypeScript Path Alias Errors

Ensure your `tsconfig.json` includes:

```json
{
    "compilerOptions": {
        "baseUrl": ".",
        "paths": {
            "#utils/*": ["./src/utils/*"],
            "#types/*": ["./src/types/*"]
        }
    }
}
```

## Resources

-   [Crawlee Documentation](https://crawlee.dev/)
-   [Playwright Documentation](https://playwright.dev/)
-   [TypeScript Handbook](https://www.typescriptlang.org/docs/)
-   [Crawlee Examples](https://crawlee.dev/js/docs/examples)

## License

ISC

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

# crawlee-template-ts
