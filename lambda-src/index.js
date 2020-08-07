const { KintoneRestAPIClient } = require('@kintone/rest-api-client');
const validator = require('validator');
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
  const params = {
    app: APP_ID,
    fields: FIELDS,
    condition: query
  };
  let response = {};
  console.log("Starting query ...");
  try {
    const res = await client.record.getAllRecords(params);
    const xml = buildXml(res);
    response = formatResponse(xml);
  } catch (e) {
    console.log(e);
    response = formatError(e);
  } finally {
    return response;
  }
 
};
 
function buildQuery (event) {
  let conditions = new Array();
  if (event.queryStringParameters && event.queryStringParameters.query) {
    const query = event.queryStringParameters.query;
    conditions.push(`${DISPLAY_FIELD} like "${validator.escape(query)}"`);
  }
  if (event.queryStringParameters && event.queryStringParameters.parent) {
    const parentItemId = event.queryStringParameters.parent;
    conditions.push(`${VALUE_FIELD} like "${validator.escape(parentItemId)}"`); // kintone の仕様で前方一致検索不可
  }
  let stmt = '';
  const condNum = conditions.length;
  if (condNum >= 1) {
    stmt += `${conditions[0]}`;
    if (condNum == 2) {
      stmt += ` and ${conditions[1]}`;
    }
  } else if (event.multiValueQueryStringParameters && event.multiValueQueryStringParameters.values) {
    const values = event.multiValueQueryStringParameters.values;
    const valuesStr = new Array(values.length).fill().map((_, i) => validator.escape(values[i])).join('", "');
    stmt += `${VALUE_FIELD} in ("${valuesStr}")`;
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
      "Content-Type": "text/plain; charset=utf-8"
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
