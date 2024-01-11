import { jwtDecode } from 'jwt-decode';
import { APIGatewayEvent } from 'aws-lambda'

export const handler = async (event: APIGatewayEvent) => {
    console.log('Event: ', JSON.stringify(event));

    const userData = jwtDecode<any>((event.headers.Authorization!).split(' ')[1]);

    const response = {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            firstName: userData.given_name,
            lastName: userData.family_name,
            email: userData.email,
            userId: userData.sub
        })
    };

    return response;
};
