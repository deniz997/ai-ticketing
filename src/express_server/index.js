const express = require("express");
const bodyParser = require("body-parser");
const { diag, DiagConsoleLogger, DiagLogLevel } = require("@opentelemetry/api");
const { NodeSDK } = require("@opentelemetry/sdk-node");
const { OTLPTraceExporter } = require("@opentelemetry/exporter-trace-otlp-http");
const { OTLPMetricExporter } = require("@opentelemetry/exporter-metrics-otlp-http");
const { PeriodicExportingMetricReader } = require("@opentelemetry/sdk-metrics");

// Initialize OpenTelemetry
diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.DEBUG);

// Activate the following lines to instrument express-server service
// Set up the OTLP trace exporter
// const traceExporter = new OTLPTraceExporter({
//     url: "http://localhost:3333/v1/traces",
// });

// Set up the OTLP metric exporter
// const metricExporter = new OTLPMetricExporter({
//     url: "http://localhost:3333/v1/metrics",
// });

// Initialize the OpenTelemetry Node SDK
const sdk = new NodeSDK({
    // traceExporter,
    // metricReader: new PeriodicExportingMetricReader({
    //     exporter: metricExporter,
    //     exportIntervalMillis: 1000,
    // }),
});

sdk.start();

const app = express();
const port = process.env.EXPRESS_SERVER_PORT || 3333;

app.use(bodyParser.raw({ type: "application/json", limit: "20mb" }));

app.post("/v1/traces", (req, res) => {
    try {
        const traceData = JSON.parse(req.body);
        console.log("Trace data received:", JSON.stringify(traceData, null, 2));
        res.status(200).send("Trace data received");
    } catch (parseError) {
        console.error("Failed to parse JSON:", parseError);
        res.status(400).send("Invalid JSON format");
    }
});

// app.post("/v1/metrics", (req, res) => {
//     res.status(200).send("Metric data received");
// });

app.get("/", (req, res) => {
    res.send("Express Server is running with OTLP support");
});

app.listen(port, () => {
    console.log(`Express server listening on port ${port}`);
});
