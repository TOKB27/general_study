import axios from "axios";

export const handler = async (event) => {
  const body = JSON.parse(event.body);
  const authorizationCode = body.code;

  if (!authorizationCode) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "Authorization code is missing" }),
    };
  }

  const data = {
    grant_type: "authorization_code",
    client_id: "6a90qv247godebol8bdbqkdib",
    redirect_uri: "https://d233iutzclt85j.cloudfront.net/test.html",
    code: authorizationCode,
  };

  try {
    const response = await axios.post(
      "https://test20241020.auth.ap-northeast-1.amazoncognito.com/oauth2/token",
      data
    );
    const tokens = response.data;

    return {
      statusCode: 200,
      body: JSON.stringify(tokens),
    };
  } catch (error) {
    console.error("Error retrieving tokens:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Failed to retrieve tokens" }),
    };
  }
};
