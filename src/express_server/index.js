const express = require("express");
const bodyParser = require("body-parser");
const { diag, DiagConsoleLogger, DiagLogLevel } = require("@opentelemetry/api");
const { NodeSDK } = require("@opentelemetry/sdk-node");
const { Client } = require("@notionhq/client")
const { createPage } = require("./packages/create-page");

const databaseId = "179f83708c30426d92afddaa157d3503"
const notionToken = 'secret_SVDk88Ij9CaG18YboWXMBl8SbDMhNhcwVs5dB6L7BsP'
const notion = new Client({
    auth: process.env.NOTION_TOKEN || notionToken,
})

diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.DEBUG);
const sdk = new NodeSDK({});

sdk.start();

const app = express();
const port = process.env.EXPRESS_SERVER_PORT || 3333;

app.use(bodyParser.raw({ type: "application/json", limit: "20mb" }));

app.post("/v1/traces", (req, res) => {
    try {
        const traceData = JSON.parse(req.body);
        // console.log("Trace data received:", JSON.stringify(traceData, null, 2));
        // const jsonString = JSON.stringify(traceData, null, 2)

        let minEndUnixTime = getErrorSpanEndTime(traceData);

        res.status(200).send('Trace received.')
    } catch (parseError) {
        console.error("Failed to parse JSON:", parseError);
        res.status(400).send("Invalid JSON format");
    }
});

const message = "**Support Ticket**\n\n**Affected Services:**\n- **frontend-proxy**\n- **CurrencyService**\n- **ProductCatalogService**\n\n**Summary of Logs for Services with Errors:**\n1. **frontend-proxy:**\n   - Operation Name: HTTP GET\n   - Duration: 21000 µs\n   - HTTP Status Code: 500 \n   - Error: Internal Server Error\n   - Logs indicate that a request was made to the endpoint for recommendations but encountered a 500 error indicating an issue on the server.\n\n2. **ProductCatalogService:**\n   - Operation Name: GetProduct\n   - Error: 13 INTERNAL - \"ProductCatalogService Fail Feature Flag Enabled\"\n   - The logs show repeated feature flag failures.\n   - Error message indicates an internal issue due to feature flag configuration.\n\n**Possible Cause of Error:**\n- The errors in the `frontend-proxy` and `ProductCatalogService` may be linked to misconfigured feature flags in the service `productCatalogFailure`. The `frontend-proxy` encountered an error while making requests to the `ProductCatalogService`, which failed due to the active feature flag.\n\n**Possible Solution Recommendation:**\n1. Verify the feature flag configuration for `productCatalogService` and ensure it is functioning as expected. The flag `productCatalogFailure` appears to be enabled and causing the service to reject requests.\n2. Review and disable any unnecessary feature flags if they are not required for current operations.\n3. Ensure that the `frontend-proxy` service can receive valid responses from the dependent services without encountering internal server errors.\n\n**Additional Notice:**\n- If the service was temporarily unavailable, this could be a transient issue. Monitor the services to see if the error persists. \n\n**Tags:**\n- `frontend-proxy`\n- `ProductCatalogService`\n- `CurrencyService`\n- `FeatureFlags`\n- `InternalServerError`"
app.post("/v1/create-page", async (req, res) => {
    await createPage(notion, databaseId, message);
    res.send("Page created.")
});

app.get("/", (req, res) => {
    res.send("Express Server is running with OTLP support");
});

app.listen(port, () => {
    console.log(`Express server listening on port ${port}`);
});
