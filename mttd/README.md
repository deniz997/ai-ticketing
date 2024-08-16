# Calculating the meantime to detect

The ai-ticketing cloud function saves the duration of ticket generation on the Notion table under the property `Duration (sec)`. It is calculated by the difference between the timestamp of the earliest span with error and right before the generated ticket is published to the Notion. You can use `mttd.js` to retrieve the entries on the database those `Duration (sec)` property is not empty and calculate the average.

## Running the script

```shell
npm install @notionhq/client

NOTION_API_KEY=${NOTION_API_KEY} NOTION_DB_ID=${NOTION_DB_ID} node mttd.js
```

### Example output
```
Entry count: 5
MTTD: 22.7722 seconds
```