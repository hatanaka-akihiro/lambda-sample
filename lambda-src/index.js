const { KintoneRestAPIClient } = require('@kintone/rest-api-client');
const builder = require('xmlbuilder');

const DOMAIN = process.env['domain'];
const TOKEN = process.env['token'];
const APP_ID = process.env['appId'];
const VALUE_FIELD = process.env['value'];
const DISPLAY_FIELD = process.env['display'];
const FIELDS = [VALUE_FIELD, DISPLAY_FIELD];

const client = new KintoneRestAPIClient({
    baseUrl: `https://${DOMAIN}`,
    auth: {
      apiToken: TOKEN
    }
});
 
exports.handler = async (event) => {
  const query = buildQuery(event);
  console.log(`query: ${query}`);
  const params = {
    app: APP_ID,
    fields: FIELDS,
    condition: query
  };
  console.log("Starting query ...");
  try {
    const res = await client.record.getAllRecords(params);
    const xml = buildXml(res);
    return formatResponse(xml);
  } catch (e) {
    console.log(e);
    return formatError(e);
  }
};
 
function buildQuery (event) {
  let conditions = new Array();
  if (event.queryStringParameters && event.queryStringParameters.query) {
    const query = event.queryStringParameters.query;
    conditions.push(`${DISPLAY_FIELD} like ${JSON.stringify(query)}`);
  }
  if (event.queryStringParameters && event.queryStringParameters.parent) {
    const parentItemId = event.queryStringParameters.parent;
    conditions.push(`${VALUE_FIELD} like ${JSON.stringify(parentItemId)}`); // kintone の仕様で前方一致検索不可
  }
  let stmt = '';
  if ( conditions.length > 0) {
    stmt += conditions.join(" and ");
  } else if (event.multiValueQueryStringParameters && event.multiValueQueryStringParameters.values) {
    const values = event.multiValueQueryStringParameters.values;
    const valuesStr = values.map(v => JSON.stringify(v)).join(', ');
    stmt += `${VALUE_FIELD} in (${valuesStr})`;
  }
  return stmt;
}
 
function buildXml (res) {
  let root = builder.create('items');
  for (let i = 0; i < res.length; i++) {
    let item = root.ele('item');
    item.att('value', res[i][VALUE_FIELD].value);
    item.att('display', res[i][DISPLAY_FIELD].value);
  }
  const xml = root.end({ pretty: true});
  return xml;
}
 
function formatResponse (body) {
  const response = {
    "statusCode": 200,
    "headers": {
      "Content-Type": "application/xml; charset=utf-8"
    },
    "isBase64Encoded": false,
    "body": body,
  };
  return response;
}
 
function formatError (error) {
  const response = {
    "statusCode": error.statusCode,
    "headers": {
      "Content-Type": "text/plain; charset=utf-8",
      "x-amzn-ErrorType": error.code
    },
    "isBase64Encoded": false,
    "body": error.code + ": " + error.message
  };
  return response;
}
