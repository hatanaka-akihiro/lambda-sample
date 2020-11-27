exports.handler = async (event) => {
  return formatResponse('<test></test>');
};

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