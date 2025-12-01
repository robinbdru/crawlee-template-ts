import { createPlaywrightRouter } from "crawlee";
import { dataset } from "./index.js";

const router = createPlaywrightRouter();

router.addDefaultHandler(async ({ request, page, log }) => {
    log.info(`Processing request: ${request.url}`);

    // Wait for page to load
    await page.waitForLoadState("networkidle");

    // Get page title
    const pageTitle = await page.title();

    // Example: Save data to dataset
    await dataset.pushData({
        url: request.loadedUrl,
        title: pageTitle,
        // Add your data here
    });
});

router.addHandler("DETAIL", async ({ request, page, log }) => {
    log.info(`Processing DETAIL request: ${request.url}`);

    await page.waitForLoadState("networkidle");

    const pageTitle = await page.title();

    // Example: Extract more detailed data
    await dataset.pushData({
        url: request.loadedUrl,
        title: pageTitle,
        type: "detail",
        // Add your detailed data extraction here
    });
});

export default router;
