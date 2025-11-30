// This file contains the config object for crawlers settings
import * as dotenv from "dotenv";
import { readFileSync } from "fs";
import { resolve } from "path";

// Load environment variables from .env file
dotenv.config();

// Load proxy URLs from files
/**
 * Loads datacenter and residential proxies from specified files.
 * @param proxiesDir - Directory where proxy files are located.
 * @param datacenterFile - Filename for datacenter proxies.
 * @param residentialFile - Filename for residential proxies.
 * @returns A tuple containing two arrays: datacenter proxies and residential proxies.
 */
const loadProxies = ({
    proxiesDir = process.env.PROXIES_PATH || "proxies",
    datacenterFile = process.env.DATACENTER_PROXIES_FILE ||
        "proxy-datacenter.txt",
    residentialFile = process.env.RESIDENTIAL_PROXIES_FILE ||
        "proxy-residential.txt",
} = {}): [string[], string[]] => {
    const dir = process.env.PROXIES_PATH || proxiesDir;
    try {
        const datacenterPath = resolve(process.cwd(), dir, datacenterFile);
        const residentialPath = resolve(process.cwd(), dir, residentialFile);

        const datacenterContent = readFileSync(datacenterPath, "utf-8");
        const residentialContent = readFileSync(residentialPath, "utf-8");

        const datacenterProxies = datacenterContent
            .split("\n")
            .map((line) => line.trim())
            .filter((line) => line.length > 0 && line.startsWith("http"));

        const residentialProxies = residentialContent
            .split("\n")
            .map((line) => line.trim())
            .filter((line) => line.length > 0 && line.startsWith("http"));

        if (datacenterProxies.length > 0) {
            console.log(
                `Loaded ${datacenterProxies.length} datacenter proxies.`,
            );
        } else {
            console.log("No datacenter proxies loaded. File may be empty.");
        }
        if (residentialProxies.length > 0) {
            console.log(
                `Loaded ${residentialProxies.length} residential proxies.`,
            );
        } else {
            console.log("No residential proxies loaded. File may be empty.");
        }

        return [datacenterProxies, residentialProxies];
    } catch (error) {
        console.warn(`Warning: Could not load proxies: ${error}`);
        return [[], []];
    }
};

// A pre hook navigation to block unwanted resources when using Playwright crawlers
/**
 * Blocks unwanted resources and domains during page navigation to optimize crawling.
 * @param page - The Playwright page object.
 * @param log - The logger object for logging information and errors.
 */
export const blockResources = async ({
    page,
    log,
}: {
    page: any;
    log: any;
}) => {
    try {
        await page.route("**/*", (route: any) => {
            log.debug(`Blocking resources for: ${route.request().url()}`);
            const resourceType = route.request().resourceType();
            const blockedResources = ["image", "stylesheet", "font", "media"];
            const blockedDomains = [
                "googlesyndication.com",
                "adservice.google.com",
                "doubleclick.net",
                "ad.doubleclick.net",
            ];

            const url = route.request().url();
            if (blockedDomains.some((domain) => url.includes(domain))) {
                route.abort();
                return;
            }
            if (blockedResources.includes(resourceType)) {
                route.abort();
            } else {
                route.continue();
            }
        });
    } catch (error) {
        log.error(`Error in blockResources preNavigationHook: ${error}`);
    }
};

export { loadProxies };
