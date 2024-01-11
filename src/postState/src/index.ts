import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import  { DynamoDBDocumentClient, PutCommand, PutCommandInput } from '@aws-sdk/lib-dynamodb';
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

        const body = JSON.parse(event.body!);
        if (!body.stateName) {
            throw new Error("Body must contain stateName");
        }
        const userId = event.pathParameters?.userId;
        const params: PutCommandInput = {
            Item: { userId, ...body },
            TableName: process.env.DDB_TABLE,
            ReturnValues: 'ALL_OLD'
        }
        const resp = await ddbClient.send(new PutCommand(params));
        const returnBody = JSON.stringify({ Overwritten: { ...resp.Attributes } });

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
