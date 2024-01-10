const aws = require('@aws-sdk/client-cognito-identity-provider');
const jwt = require("jwt-decode");

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

        if (!event.headers.Authorization) {
            throw new Error("Authorization header is required")
        }
        const auth = event.headers.Authorization;
        const jwtUserData = jwt.jwtDecode(auth.startsWith('Bearer') ?  auth.split(' ')[1] : auth);
        const userId = jwtUserData.sub

        const getUsers = async (poolId, userId ) => {
            const client = new aws.CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
            return client.send(new aws.ListUsersCommand({
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
