const { sendMessage } = require('./local-modules/ai-connector');
const { preprocess } = require('./local-modules/preprocessing');
const { publishTicket } = require('./local-modules/ticketing');
const express = require('express');

const app = express();
app.post("/v1/traces", handleRequest);

async function handleRequest(req, res) {
    const trace = handlePost(req, res);
    if(trace == null){
        res.status(400).send("Trace data could not be found!");
        return;
    }
    const errorTime = getErrorSpanEndTime(trace)
    const preprocessedTrace = preprocess(trace);
    try{
        const gptResponse = await sendMessage(preprocessedTrace);
        await publishTicket(gptResponse, errorTime);
    } catch (error) {
        const errString = "Error: " + error.source + " - " + error.status + " - " + error.message; 
        console.log(errString)
        res.status(500).send();
        return;
    }
    
    res.status(200).send();
    return;
}

function handlePost(req, res) {
    if(req.body.constructor === Object && Object.keys(req.body).length === 0) {
        return null;
      }
    req.header("Content-Type", "application/json");
    const trace = req.body;
    return trace;
}

function getErrorSpanEndTime(traceData) {
    let minEndUnixTime = undefined;
    traceData.resourceSpans.forEach((resourceSpan) => {
        resourceSpan.scopeSpans.forEach((scopeSpan) => {
            scopeSpan.spans.forEach((span) => {
                if (minEndUnixTime === undefined || span.endTimeUnixNano < minEndUnixTime) {
                    minEndUnixTime = span.endTimeUnixNano
                }
            })
        });
    });
    return minEndUnixTime;
}

exports.ticketing = app;

