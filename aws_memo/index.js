"use strict";
const querystring = require("querystring");
const axios = require("axios");

exports.handler = async (event, context, callback) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;
  const queryString = request.querystring;

  // クッキーにCognitoのIDトークンがない場合
  if (
    !headers.cookie ||
    !headers.cookie.some((cookie) => cookie.value.includes("CognitoIdToken"))
  ) {
    // URLからクエリパラメータを取得
    const params = querystring.parse(queryString);

    if (params.code) {
      // 認証コードがURLに含まれている場合はトークンを取得する
      const authorizationCode = params.code;
      console.log("Authorization Code:", authorizationCode);

      // トークン取得用のデータを準備
      const data = {
        grant_type: "authorization_code",
        client_id: "",
        redirect_uri: "",
        code: authorizationCode,
      };

      try {
        // Cognitoからトークンを取得
        const response = await axios.post(
          "https://xxx.auth.ap-northeast-1.amazoncognito.com/oauth2/token",
          querystring.stringify(data),
          {
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
            },
          }
        );

        const tokens = response.data;
        console.log("Tokens received:", tokens);

        // トークンをクッキーに設定
        const idTokenCookie = `CognitoIdToken=${tokens.id_token}; Path=/; Secure; HttpOnly`;
        const accessTokenCookie = `CognitoAccessToken=${tokens.access_token}; Path=/; Secure; HttpOnly`;

        const responseHeaders = {
          "set-cookie": [
            { key: "Set-Cookie", value: idTokenCookie },
            { key: "Set-Cookie", value: accessTokenCookie },
          ],
          location: [
            {
              key: "Location",
              value: "https://yyy.cloudfront.net/test.html",
            },
          ],
        };

        const responseToReturn = {
          status: "302",
          statusDescription: "Found",
          headers: responseHeaders,
        };

        // トークンを保存し、リダイレクト
        callback(null, responseToReturn);
      } catch (error) {
        console.error("Error fetching tokens:", error);
        const errorResponse = {
          status: "500",
          statusDescription: "Internal Server Error",
          body: "Failed to retrieve tokens.",
        };
        callback(null, errorResponse);
      }
    } else {
      // 認証コードがない場合は、通常のリクエスト処理を続行
      // 認証コードがない場合はCognitoのログインページにリダイレクト
      const loginUrl =
        "https://xxx.auth.ap-northeast-1.amazoncognito.com/login?" +
        querystring.stringify({
          client_id: "",
          response_type: "code",
          scope: "openid",
          redirect_uri: "https://yyy.cloudfront.net/test.html",
        });

      const responseToReturn = {
        status: "302",
        statusDescription: "Found",
        headers: {
          location: [
            {
              key: "Location",
              value: loginUrl,
            },
          ],
        },
      };

      console.log("Redirecting to login:", loginUrl);
      callback(null, responseToReturn);
    }
  } else {
    // トークンがある場合、リクエストをそのまま続行
    callback(null, request);
  }
};
