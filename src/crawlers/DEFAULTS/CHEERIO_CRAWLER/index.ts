import {
    CheerioCrawler,
    CheerioCrawlerOptions,
    Dataset,
    ProxyConfiguration,
    RequestQueue,
} from "crawlee";
import router from "./router.js";
import { loadProxies } from "#utils/index.js";

const MAX_CONCURRENCY = 30;
const MAX_REQUESTS_PER_CRAWL = 1000;
const REQUEST_HANDLER_TIMEOUT_SECS = 30;
const MAX_REQUEST_RETRIES = 3;
const QUEUE_NAME = undefined;
const DATASET_NAME = undefined;

const [datacenterProxies, residentialProxies] = loadProxies();
const hasProxies =
    datacenterProxies.length > 0 || residentialProxies.length > 0;

const proxyConfiguration = hasProxies
    ? new ProxyConfiguration({
          tieredProxyUrls: [datacenterProxies, residentialProxies],
      })
    : undefined;

const crawlerOptions = <CheerioCrawlerOptions>{
    proxyConfiguration,
    maxConcurrency: MAX_CONCURRENCY,
    maxRequestsPerCrawl: MAX_REQUESTS_PER_CRAWL,
    requestHandlerTimeoutSecs: REQUEST_HANDLER_TIMEOUT_SECS,
    maxRequestRetries: MAX_REQUEST_RETRIES,
};

const queue = await RequestQueue.open(QUEUE_NAME);
const dataset = await Dataset.open(DATASET_NAME);

const initialUrls = [
    "https://example.com",
    "https://example.org",
    "https://example.net",
];

await queue.addRequestsBatched(initialUrls.map((url) => ({ url })));

const cheerioCrawler = new CheerioCrawler({
    ...crawlerOptions,
    requestHandler: router,
    requestQueue: queue,
});

export default cheerioCrawler;
export { dataset };
