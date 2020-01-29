exports.handler = function(event, context, callback) {
  var responseBody =
    "Welcome to the stamp department.Please proceed to authorisation.";

  var response = {
    statusCode: 200,
    headers: {
      my_header: "my_value"
    },
    body: JSON.stringify(responseBody),
    isBase64Encoded: false
  };

  callback(null, response);
};
