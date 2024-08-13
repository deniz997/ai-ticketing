const { Client } = require("@notionhq/client")

const notion = new Client({
    auth: process.env.NOTION_API_KEY,
})

const NOTION_DB_ID = process.env.NOTION_DB_ID;

module.exports.publishTicket = async function(ticket) {
    try {
        const response = await notion.pages.create({
            parent: {database_id: NOTION_DB_ID},
            properties: {
                "Name": {
                    "title": [
                        {
                            "text": {
                                "content": "GPT Ticket"
                            }
                        }
                    ]
                }
            },
            children: [
                {
                    "object": "block",
                    "type": "paragraph",
                    "paragraph": {
                        "rich_text": [
                            {
                                "type": "text",
                                "text": {
                                    "content": ticket,
                                }
                            }
                        ]
                    }
                }
            ],
        });
        console.log("Ticket can be accessed at: ", response.url);
        return response.status; 
    } catch (error) {
        throw {source: "Ticketing", status: error.status, message: error.message} 
    }
}