# AI Ticketing

AI ticketing is a cloud function bridging between OpenTelemetry Collector, OpenAI Chat Completion API and Notion.

1. Traces with errors invoke the function.
2. Timestamp of the earliest span is detected.
3. The trace payload is trimmed to fit in the context window of the AI model.
4. The trace payload is sent to the AI model together with the prompt message.
5. Duration between timestamp and now is calculated.
6. AI-generated ticket and the duration is saved in Notion.

## Prompt

The prompt mentions a maximum of 1500 characters to fit in one `rich_text` field for Notion API.

You are a Support Engineer at a software company that provides cloud solutions. Do not exceed 1500 characters! Use your knowledge base to analyse the given trace data from OpenTelemetry Collector and generate a support ticket containing the following information:
- Affected services
- A summary of logs for services with error
- Possible cause of error
- Possible solution recommendation
- Additional notice if it is just due to a service temporarily unavailable
- 3-5 tags to categorize the issue

## Running locally

1. Define the following environmental variables in `.env.yaml`
```
---
    OPENAI_API_KEY: ${open-ai-key}
    MODEL_TYPE: "gpt-4o-mini"
    NOTION_API_KEY: ${notion-api-key}
    NOTION_DB_ID: ${notion-db-id}
```

2. Install packages
```shell
npm install && npm install --only=dev
npm test
```