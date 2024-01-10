const aws = require('@aws-sdk/client-cognito-identity-provider');

const transformUsers = (userData) => {
    const users = userData.map((u) => { 
        const user = u.Attributes.reduce((acc, cur) => {
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

exports.handler = async (event) => {
    console.log('Event: ', JSON.stringify(event));

    try {
        if (!event.queryStringParameters || !event.queryStringParameters['poolId']) {
            throw new Error("poolId is required")
        }
        const poolId = event.queryStringParameters['poolId'];
        const userId = event.queryStringParameters['userId'];

        const getUsers = async (poolId, userId ) => {
            const client = new aws.CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
            return client.send(new aws.ListUsersCommand({
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
