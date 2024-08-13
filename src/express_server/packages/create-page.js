const createPage = async (notion, databaseId, message) => {
    await notion.pages.create({
        parent: {database_id: databaseId},
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
                                "content": message,
                            }
                        }
                    ]
                }
            }
        ],
    });
}
