const { Client } = require("@notionhq/client")

const notion = new Client({
    auth: process.env.NOTION_API_KEY,
})

module.exports.publishTicket = async function(ticket) {

}