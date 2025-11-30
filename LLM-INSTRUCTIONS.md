# LLM Instructions for Crawler Development

> This file serves as a comprehensive guide for AI assistants helping with crawler development. Fill in the sections below to provide clear context and requirements for your crawler project.

---

## 🎯 Project Overview

### Crawler Objective

<!-- Describe the main goal of this crawler -->

**What data needs to be collected?**

-   Product listings
-   Pricing information
-   User reviews
-   Other: _[specify]_

**Target website(s):**

-   Primary URL: `https://example.com`
-   Additional URLs: _[if any]_

**Business purpose:**

<!-- Why is this data being collected? What problem does it solve? -->

Why are we building this crawler?

## 🕷️ Crawling Strategy

### Crawler Type

<!-- Which type of crawler is being used? -->

-   **HttpCrawler** - For simple HTTP requests (fast, lightweight)
-   **PlaywrightCrawler (Firefox)** - For JavaScript-heavy sites requiring browser rendering
-   **CheerioCrawler** - For HTML parsing without JavaScript
-   **Other**: _[specify]_

**Reason for choice:**

<!-- Why is this crawler type appropriate for this target? -->

### Crawling Strategy

**1. Step One:** _[Describe the first step, e.g., start from category pages]_
**2. Step Two:** _[Describe the second step, e.g., extract product links from listing pages]_
**3. Step Three:** _[Describe the third step, e.g., visit product detail pages to extract data]_
**4. Additional Steps:** _[If any, describe further steps]_

### Rate Limiting & Concurrency

```typescript
maxConcurrency: 10; // Concurrent requests
maxRequestsPerCrawl: 1000; // Total requests limit
requestHandlerTimeoutSecs: 60; // Timeout per request
maxRequestRetries: 3; // Retry failed requests
```

**Justification:**

Why these specific values? Consider server load, blocking risks, etc.

## 🔒 Anti-Bot & Security Measures

### Proxy Configuration

-   Datacenter proxies (fast, may be blocked)
-   Residential proxies (slower, more reliable)

The current strategy uses tiered proxies. If the datacenter proxies fail, it falls back to residential proxies.

**Proxy files:**

-   `proxies/proxy-datacenter.txt`
-   `proxies/proxy-residential.txt`

## 💾 Data Storage & Export

### Local Storage

Data is stored in `./storage/datasets/[DATASET_NAME]/`

```typescript
// In router
await dataset.pushData({
    // Your data object
});
```

### AWS S3 Upload

<!-- If using S3 export -->

**Upload command:**

```bash
./bash/s3/upload.sh --file=storage/datasets/default/000001.json
```

**S3 Configuration:**

-   Bucket: `databoutique.com`
-   Path structure: `sellers/{SELLER_ID}/{CONTRACT_ID}/{DATE}/`
-   Required env vars: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `SELLER_ID`, `CONTRACT_ID`

### Data Format

-   [ ] JSON (default)
-   [ ] CSV
-   [ ] Custom format: _[specify]_

---

## 🏗️ Project Structure

### Current Setup

This project uses **Crawlee** with TypeScript and follows this structure:

```
crawlee-template-ts/
├── src/
│   ├── main.ts              # Entry point
│   ├── crawlers/            # Crawler implementations
│   │   ├── DEFAULTS/        # Templates (HTTP, FIREFOX, etc.)
│   │   └── [your-crawler]/  # Your custom crawlers
│   ├── utils/               # Utility functions (proxies, helpers)
│   ├── types/               # TypeScript type definitions
│   └── schemas/             # Data validation schemas
├── bash/                    # Utility scripts
│   ├── crawlers/            # Crawler management scripts
│   └── s3/                  # AWS S3 upload scripts
├── proxies/                 # Proxy configuration files
└── storage/                 # Local data storage (datasets, requests)
```

### Available Commands

```bash
# Development
npm run start              # Run the crawler
npm run build              # Build for production

# Crawler Management
npm run crawler:new -- --type=http --name=my-crawler
npm run crawler:new -- --type=firefox --name=my-browser-crawler
npm run crawler:install-playwright

# Scripts
npm run scripts:allow      # Make all bash scripts executable
```

### Path Aliases

The following path aliases are configured:

-   `#utils` → `./src/utils`
-   `#actors` → `./src/actors`
-   `#schemas` → `./src/schemas`
-   `#types` → `./src/types`

---

## 🧪 Testing & Validation

### Test URLs

<!-- Provide specific URLs for testing -->

1. `https://example.com/product/123` - Standard product
2. `https://example.com/product/456` - Out of stock product
3. `https://example.com/product/789` - Product with sale price

---

## 📝 Additional Notes

<!-- Any other important information for the AI assistant -->

### Code Style Preferences

-   Use TypeScript strict mode
-   Prefer async/await over promises
-   Add JSDoc comments for complex functions
-   Keep handlers focused and single-purpose

### Performance Targets

-   Target speed: _[e.g., 1000 products/hour]_
-   Memory limit: _[e.g., < 500MB]_
-   Success rate: _[e.g., > 95%]_

### Questions for AI Assistant

<!-- List any specific things you want help with -->

1.
2.
3.

---

## 🔗 Useful Resources

-   [Crawlee Documentation](https://crawlee.dev/)
-   [Playwright Documentation](https://playwright.dev/)
-   [TypeScript Handbook](https://www.typescriptlang.org/docs/)
-   Project-specific docs: _[add links]_
