exports.handler = async (event) => {
    console.log('Event: ', event);
    let responseMessage = 'Hello, NoName Person!';
  
    if (event.queryStringParameters && event.queryStringParameters['name']) {
      responseMessage = 'Hello, ' + event.queryStringParameters['name'] + '!';
    }
  
    const response = {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            message: responseMessage
        })
    };

    return response;
};
