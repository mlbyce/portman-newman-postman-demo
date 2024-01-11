import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import  { DynamoDBDocumentClient, QueryCommand, QueryCommandInput } from '@aws-sdk/lib-dynamodb';
import { APIGatewayEvent } from 'aws-lambda'

const getDdbDocClient = (clientIn?: DynamoDBDocumentClient ) : DynamoDBDocumentClient => {
if (clientIn) return clientIn;

const ddbClient = new DynamoDBClient({});
const marshallOptions = { removeUndefinedValues: true, convertClassInstanceToMap: true };
const translateConfig = { marshallOptions };
return DynamoDBDocumentClient.from(ddbClient, translateConfig);
};

module.exports.handler = async (event: APIGatewayEvent) => {
    try {
        console.log('Event: ', JSON.stringify(event));

        const ddbClient = getDdbDocClient();

        const userId = event.pathParameters?.userId;
        const params: QueryCommandInput = {
            KeyConditionExpression: 'userId = :userId',
            ExpressionAttributeValues: { ':userId': userId },
            TableName: process.env.DDB_TABLE,
            ScanIndexForward: false,
        }
        const resp = await ddbClient.send(new QueryCommand(params));
        const items = resp.Items ? resp.Items : [];
        const returnBody = JSON.stringify({ items: items });
        console.log('RETURNED RECORDS', returnBody);

        const response = {
            statusCode: 200,
            headers: {
                "Content-Type": "application/json"
            },
            body: returnBody
        };
        return response;
    } catch(e) {
        return {
            statusCode: 400,
            headers: { "Content-Type": "application/json" },
            body: `${e}`
        }
    }
};
