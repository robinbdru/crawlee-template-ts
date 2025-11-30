import {
    Dataset,
    HttpCrawler,
    HttpCrawlerOptions,
    ProxyConfiguration,
    RequestQueue,
} from "crawlee";
import router from "./router.js";
import { loadProxies } from "#utils/index.js";

const MAX_CONCURRENCY = 50;
const MAX_REQUESTS_PER_CRAWL = 1000;
const REQUEST_HANDLER_TIMEOUT_SECS = 30;
const MAX_REQUEST_RETRIES = 3;
const QUEUE_NAME = undefined;
const DATASET_NAME = undefined;

const proxyConfiguration = new ProxyConfiguration({
    tieredProxyUrls: loadProxies(),
});

const crawlerOptions = <HttpCrawlerOptions>{
    proxyConfiguration,
    maxConcurrency: MAX_CONCURRENCY,
    maxRequestsPerCrawl: MAX_REQUESTS_PER_CRAWL,
    requestHandlerTimeoutSecs: REQUEST_HANDLER_TIMEOUT_SECS,
    maxRequestRetries: MAX_REQUEST_RETRIES,
};

const queue = await RequestQueue.open(QUEUE_NAME);
const dataset = await Dataset.open(DATASET_NAME);

const initialUrls = [
    "http://example.com",
    "http://example.org",
    "http://example.net",
];

await queue.addRequestsBatched(initialUrls.map((url) => ({ url })));

const httpCrawler = new HttpCrawler({
    ...crawlerOptions,
    requestHandler: router,
    requestQueue: queue,
});

export default httpCrawler;
export { dataset };
