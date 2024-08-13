const functions = require('@google-cloud/functions-framework');
const { sendMessage } = require('./local-modules/ai-connector');
const { preprocess } = require('./local-modules/preprocessing');

const { Client } = require("@notionhq/client")

const notion = new Client({
    auth: process.env.NOTION_TOKEN || 'secret_SVDk88Ij9CaG18YboWXMBl8SbDMhNhcwVs5dB6L7BsP',
})

functions.http('ticketing', async (req, res) => {
    switch (req.method) {
        case 'POST':
            const trace = handlePost(req, res);
            if(trace == null){
                res.status(400).send("Trace data could not be found!");
            }
            const preprocessedTrace = preprocess(trace);
            const gptResponse = await sendMessage(preprocessedTrace);

            res.status(200).send(gptResponse)
        default:
            res.status(405).send("Unsupported method!");
    }
});

function handlePost(req, res) {
    if(req.body.constructor === Object && Object.keys(req.body).length === 0 && req.headers['Content-Type'] != 'application/json') {
        return null;
      }

    const trace = req.body;
    return trace;
}



