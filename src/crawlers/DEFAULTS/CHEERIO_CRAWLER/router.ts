import { createCheerioRouter } from "crawlee";
import { dataset } from "./index.js";

const router = createCheerioRouter();

router.addDefaultHandler(async ({ request, $, log }) => {
    log.info(`Processing request: ${request.url}`);

    // Example: Extract page title
    const pageTitle = $("title").text();

    // Example: Save data to dataset
    await dataset.pushData({
        url: request.loadedUrl,
        title: pageTitle,
        // Add your data extraction here
    });
});

router.addHandler("DETAIL", async ({ request, $, log }) => {
    log.info(`Processing DETAIL request: ${request.url}`);

    const pageTitle = $("title").text();

    // Example: Extract more detailed data using Cheerio selectors
    const heading = $("h1").text();
    const description = $(".description").text();

    await dataset.pushData({
        url: request.loadedUrl,
        title: pageTitle,
        heading,
        description,
        type: "detail",
        // Add your detailed data extraction here
    });
});

export default router;
