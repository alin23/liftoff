import formatAirtableRowData from "./src/utils/formatAirtableRowData";

require("dotenv").config();
const React = require("react");
const fs = require("fs");
const Airtable = require("airtable");

const App = require("./src/components/App").default;
const Row = require("./src/components/Row").default;

const renderAsHTMLPage = require(`./src/utils/renderAsHTMLPage`).default;

const {
  AIRTABLE_API_KEY,
  BASE_ID,
  TABLE_NAME,
  VIEW,
  FIELD_ORDER
} = process.env;

const base = new Airtable({ apiKey: AIRTABLE_API_KEY }).base(BASE_ID);

const allRows = [];

base(TABLE_NAME)
  .select({
    maxRecords: 100,
    view: VIEW
  })
  .eachPage(
    function page(records, fetchNextPage) {
      records.forEach(row => {
        const formattedRow = formatAirtableRowData(row);

        const slugField = formattedRow.fields.find(
          field => field.name === "_Slug"
        );
        const slug = (slugField && slugField.value) || formattedRow.id;
        const filepath = `dist/${slug}.html`;

        allRows.push(formattedRow);
        fs.writeFile(
          filepath,
          renderAsHTMLPage(<Row rowData={formattedRow} />),
          () => {
            console.log(`${filepath} written`);
          }
        );
      });

      // calls page function again while there are still pages left
      fetchNextPage();
    },
    function done(err) {
      fs.writeFile(
        "dist/index.html",
        renderAsHTMLPage(<App rows={allRows} />),
        () => {
          console.log(`${"dist/index.html"} written`);
        }
      );
      if (err) {
        console.error(err);
      }
    }
  );

fs.copyFile("custom/main.css", "dist/main.css", () =>
  console.log("CSS has been copied")
);
