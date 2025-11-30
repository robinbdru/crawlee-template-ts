import { createHttpRouter } from "crawlee";
import { dataset } from "./index.js";

const router = createHttpRouter();

router.addDefaultHandler(async ({ request, log }) => {
    log.info(`Processing request: ${request.url}`);

    // Exemple : sauvegarder des données dans le dataset
    await dataset.pushData({
        url: request.url,
        // Ajoutez vos données ici
    });
});

router.addHandler("SPECIAL", async ({ request, log }) => {
    log.info(`Processing SPECIAL request: ${request.url}`);

    await dataset.pushData({
        url: request.url,
        type: "special",
        // Ajoutez vos données ici
    });
});

export default router;
