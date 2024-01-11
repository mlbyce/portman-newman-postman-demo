import {CognitoIdentityProviderClient, ListUsersCommand, UserType}  from '@aws-sdk/client-cognito-identity-provider';
import { APIGatewayEvent } from 'aws-lambda'

const transformUsers = (userData: UserType[] | undefined) => {
    const users = userData!.map((u:any) => { 
        const user = u.Attributes.reduce((acc: any, cur: any) => {
            switch (cur.Name) {
                case 'sub': return {...acc, userId: cur.Value};
                case 'given_name': return {...acc, firstName: cur.Value};
                case 'family_name': return {...acc, lastName: cur.Value};
                case 'email': return {...acc, email: cur.Value};
                default: return acc
            }
        }, {})
        return user;
    });
    return users;
}

export const handler = async (event: APIGatewayEvent) => {
    console.log('Event: ', JSON.stringify(event));

    try {
        if (!event.queryStringParameters || !event.queryStringParameters['poolId']) {
            throw new Error("poolId is required")
        }
        const poolId = event.queryStringParameters['poolId'];
        const userId = event.queryStringParameters['userId'];

        const getUsers = async (poolId: string, userId: string | undefined) => {
            const client = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
            return client.send(new ListUsersCommand({
            UserPoolId: poolId,
            Filter: userId ? `sub^="${userId}"` : undefined,
            }));
        }

        const userData = await (getUsers(poolId, userId))
        const users = transformUsers(userData.Users);

        return {
            statusCode: 200,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify((userId && users.length)
                ? users[0]
                : {items: users}
            )
        };
    } catch(e) {
        return {
            statusCode: 400,
            headers: { "Content-Type": "application/json" },
            body: `${e}`
        }
    }
};
