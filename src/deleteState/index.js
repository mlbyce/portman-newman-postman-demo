const { DynamoDBClient, BatchWriteItemCommand } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, QueryCommand } = require('@aws-sdk/lib-dynamodb');

const getDdbDocClient = (clientIn) => {
if (clientIn) return clientIn;

const ddbClient = new DynamoDBClient({});
const marshallOptions = { removeUndefinedValues: true, convertClassInstanceToMap: true };
const translateConfig = { marshallOptions };
return DynamoDBDocumentClient.from(ddbClient, translateConfig);
};

const formatResponse = (userId) => {
    return {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({ message: `All Records Deleted for userId = ${userId}` })
    };
}

module.exports.handler = async (event) => {
    try {
        console.log('Event: ', JSON.stringify(event));

        const ddbClient = getDdbDocClient();

        const userId = event.pathParameters.userId;
        const table = process.env.DDB_TABLE;
        const queryParams = {
            KeyConditionExpression: 'userId = :userId',
            ExpressionAttributeValues: { ':userId': userId },
            TableName: table,
            ScanIndexForward: false,
        }
        const queryResp = await ddbClient.send(new QueryCommand(queryParams));
        const items = queryResp.Items ? queryResp.Items : [];
        if (!items.length) return formatResponse(userId);

        const deleteParams =  {
            RequestItems: {
                [table]: items.map(item => ({
                    DeleteRequest: {
                        Key: {
                            userId: { S: item.userId },
                            stateName: { S:  item.stateName }
                        }
                    }
                }))
            }
        };
        await ddbClient.send(new BatchWriteItemCommand(deleteParams));

        return formatResponse(userId);
    } catch(e) {
        return {
            statusCode: 400,
            headers: { "Content-Type": "application/json" },
            body: `${e}`
        }
    }
};
