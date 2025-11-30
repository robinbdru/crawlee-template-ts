import {
    Dataset,
    PlaywrightCrawler,
    PlaywrightCrawlerOptions,
    ProxyConfiguration,
    RequestQueue,
} from "crawlee";
import { firefox } from "playwright";
import router from "./router.js";
import { blockResources, loadProxies } from "#utils/index.js";

const MAX_CONCURRENCY = 10;
const MAX_REQUESTS_PER_CRAWL = 1000;
const REQUEST_HANDLER_TIMEOUT_SECS = 60;
const MAX_REQUEST_RETRIES = 3;
const QUEUE_NAME = undefined;
const DATASET_NAME = undefined;
const HEADLESS = true;

const [datacenterProxies, residentialProxies] = loadProxies();
const hasProxies =
    datacenterProxies.length > 0 || residentialProxies.length > 0;

const proxyConfiguration = hasProxies
    ? new ProxyConfiguration({
          tieredProxyUrls: [datacenterProxies, residentialProxies],
      })
    : undefined;

const crawlerOptions = <PlaywrightCrawlerOptions>{
    launchContext: {
        launcher: firefox,
        launchOptions: {
            headless: HEADLESS,
        },
    },
    proxyConfiguration,
    maxConcurrency: MAX_CONCURRENCY,
    maxRequestsPerCrawl: MAX_REQUESTS_PER_CRAWL,
    requestHandlerTimeoutSecs: REQUEST_HANDLER_TIMEOUT_SECS,
    maxRequestRetries: MAX_REQUEST_RETRIES,
    preNavigationHooks: [
        async ({ request, page, log }) => {
            // Block unwanted resources before navigation
            await blockResources({ page, log });
            log.info(`Navigating to ${request.url}`);
        },
    ],
};

const queue = await RequestQueue.open(QUEUE_NAME);
const dataset = await Dataset.open(DATASET_NAME);

const initialUrls = [
    "https://example.com",
    "https://example.org",
    "https://example.net",
];

await queue.addRequestsBatched(initialUrls.map((url) => ({ url })));

const firefoxCrawler = new PlaywrightCrawler({
    ...crawlerOptions,
    requestHandler: router,
    requestQueue: queue,
});

export default firefoxCrawler;
export { dataset };
