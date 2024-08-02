const express = require("express");
const bodyParser = require("body-parser");
const { diag, DiagConsoleLogger, DiagLogLevel } = require("@opentelemetry/api");
const { NodeSDK } = require("@opentelemetry/sdk-node");
const { OTLPTraceExporter } = require("@opentelemetry/exporter-trace-otlp-http");
const { OTLPMetricExporter } = require("@opentelemetry/exporter-metrics-otlp-http");
const { PeriodicExportingMetricReader } = require("@opentelemetry/sdk-metrics");
const protobuf = require("protobufjs");

// Initialize OpenTelemetry
diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.DEBUG);

// Set up the OTLP trace exporter
const traceExporter = new OTLPTraceExporter({
    url: "http://localhost:3333/v1/traces",
});

// Set up the OTLP metric exporter
const metricExporter = new OTLPMetricExporter({
    url: "http://localhost:3333/v1/metrics",
});

// Initialize the OpenTelemetry Node SDK
const sdk = new NodeSDK({
    traceExporter,
    metricReader: new PeriodicExportingMetricReader({
        exporter: metricExporter,
        exportIntervalMillis: 1000,
    }),
});

sdk.start();

const app = express();
const port = process.env.EXPRESS_SERVER_PORT || 3333;

const protoRoot = protobuf.loadSync("trace.proto");
const ResourceSpans = protoRoot.lookupType("opentelemetry.proto.trace.v1.ResourceSpans");

// Middleware to parse OTLP requests
app.use(bodyParser.raw({ type: "application/x-protobuf", limit: "20mb" }));

// Endpoint to receive OTLP traces
app.post("/v1/traces", (req, res) => {
    console.log("[RECEIVED TRACE DATA] - wow 2");
    try {
        console.log('req')
        console.log(req)
        console.log(req.body)

        const decodedMessage = ResourceSpans.decode(req.body);
        let json = JSON.stringify(decodedMessage, null, 2)

        console.log('decodedMessage')
        console.log(decodedMessage)
        console.log('json')
        console.log(json)

        // if (json && json.length > 0) {
        //     console.log(json);
        // } else {
        //     console.log(decodedMessage);
        // }


        res.status(200).send("Trace data received");
    } catch (err) {
        console.error("Error decoding trace data:", err);
        res.status(400).send("Failed to decode trace data");
    }
});

// Endpoint to receive OTLP metrics
app.post("/v1/metrics", (req, res) => {
    // console.log("[RECEIVED METRIC DATA]");
    // console.log(req.body); // Log raw protobuf data

    // You would parse and process the protobuf data here
    // For demonstration, we're just logging the raw data

    res.status(200).send("Metric data received");
});

// Basic endpoint to test server
app.get("/", (req, res) => {
    res.send("Express Server is running with OTLP support");
});

// Start the server
app.listen(port, () => {
    console.log(`Express server listening on port ${port}`);
});
