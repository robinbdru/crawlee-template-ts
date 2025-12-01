// Let's scrape something...
import firefoxCrawler from "#crawlers/my-custom-firefox/index.js";
(async () => {
    console.log("Starting the Firefox crawler...");
    await firefoxCrawler.run();
    console.log("Firefox crawler finished.");
})();
