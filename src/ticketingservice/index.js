const functions = require('@google-cloud/functions-framework');
const { sendMessage } = require('./local-modules/ai-connector');
const { preprocess } = require('./local-modules/preprocessing');
const { publishTicket } = require('./local-modules/ticketing');

functions.http('ticketing', async (req, res) => {
    switch (req.method) {
        case 'POST':
            const trace = handlePost(req, res);
            if(trace == null){
                res.status(400).send("Trace data could not be found!");
                return;
            }
        
            const preprocessedTrace = preprocess(trace);
            try{
                const gptResponse = await sendMessage(preprocessedTrace);
                await publishTicket(gptResponse);
            } catch (error) {
                const errString = "Error: " + error.source + " - " + error.status + " - " + error.message; 
                console.log(errString)
                res.status(500).send();
                return;
            }
            
            res.status(200).send();
            return;
        default:
            res.status(405).send();
            return;
    }
});

function handlePost(req, res) {
    if(req.body.constructor === Object && Object.keys(req.body).length === 0) {
        return null;
      }
    req.header("Content-Type", "application/json");
    const trace = req.body;
    return trace;
}



