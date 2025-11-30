// Let's scrape something...
import firefoxCrawler from "#actors/my-custom-firefox/index.js";
(async () => {
    console.log("Starting the Firefox crawler...");
    await firefoxCrawler.run();
    console.log("Firefox crawler finished.");
})();
