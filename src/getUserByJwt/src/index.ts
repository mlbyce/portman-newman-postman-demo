import { jwtDecode } from 'jwt-decode';
import { APIGatewayEvent } from 'aws-lambda'
import { CognitoIdentityProviderClient,
    ListUsersCommand,
    UserType }  from '@aws-sdk/client-cognito-identity-provider';

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

exports.handler = async (event: APIGatewayEvent) => {
    console.log('Event: ', JSON.stringify(event));

    try {
        if (!event.queryStringParameters || !event.queryStringParameters['poolId']) {
            throw new Error("poolId is required")
        }
        const poolId = event.queryStringParameters['poolId'];

        if (!event.headers.Authorization) {
            throw new Error("Authorization header is required")
        }
        const auth = event.headers.Authorization;
        const jwtUserData = jwtDecode(auth.startsWith('Bearer') ?  auth.split(' ')[1] : auth);
        const userId = jwtUserData.sub

        const getUsers = async (poolId: string, userId: string | undefined ) => {
            const client = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
            return client.send(new ListUsersCommand({
            UserPoolId: poolId,
            Filter: userId ? `sub^="${userId}"` : undefined,
            }));
        }

        const idpUserData = await (getUsers(poolId, userId))
        const users = transformUsers(idpUserData.Users);

        return {
            statusCode: 200,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(users)
        };
    } catch(e) {
        return {
            statusCode: 400,
            headers: { "Content-Type": "application/json" },
            body: `${e}`
        }
    }
};
