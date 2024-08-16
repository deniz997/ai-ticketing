const { Client } = require('@notionhq/client');

const notion = new Client({ auth: process.env.NOTION_API_KEY });
const NOTION_DB_ID = process.env.NOTION_DB_ID;
(async () => {
  const databaseId = NOTION_DB_ID;
  const response = await notion.databases.query({
    database_id: databaseId,
    filter: {
      property: 'Duration (sec)',
      number: {
        is_not_empty: true,
      }
    }
  });
  const entries = response.results;
  let sum = 0;
  let count = 0;
  entries.forEach((entry) => {
    duration = entry.properties['Duration (sec)'].number;
    if(typeof duration == "number"){
      sum = sum + entry.properties['Duration (sec)'].number;
      count += 1;
    }
  })
  if(count == 0) {
    console.log("No valid entries could be found!");
    return;
  }
  const average = sum/count;
  console.log("Entry count: %s", count.toString());
  console.log("MTTD: %s seconds", average.toString());
})();