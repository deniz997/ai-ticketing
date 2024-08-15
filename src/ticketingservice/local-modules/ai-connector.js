const OpenAI = require("openai")

const API_KEY = process.env.OPENAI_API_KEY;
const MODEL_TYPE = process.env.MODEL_TYPE;

const openai = new OpenAI({
    apiKey: API_KEY
});

const systemPrompt = `You are a Support Engineer at a software company that provides cloud solutions. Do not exceed 1500 characters! Use your knowledge base to analyse the given trace data from OpenTelemetry Collector and generate a support ticket containing the following information:
- Affected services
- A summary of logs for services with error
- Possible cause of error
- Possible solution recommendation
- Additional notice if it is just due to a service temporarily unavailable
- 3-5 tags to categorize the issue`;

async function chat(msg) {
    try {
        const completion = await openai.chat.completions.create({
            messages: [
                {"role": "system", "content": systemPrompt},
                {"role": "user", "content": msg}
            ],
            model: MODEL_TYPE,
        });
        return completion.choices[0].message.content;
    } catch (error) {
        console.log(error)
        throw {source:"AI Connector", status: error.status, message: error.error.message};
    }
} 

module.exports.sendMessage = async function(msg) {
    return await chat(msg);
}