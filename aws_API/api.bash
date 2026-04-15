REGION="ap-northeast-1"
CLIENT_ID="<APP_CLIENT_ID>"
USERNAME="<USERNAME>"
PASSWORD="<PASSWORD>"
API_URL="https://<api-id>.execute-api.ap-northeast-1.amazonaws.com/prod/sample"

ID_TOKEN=$(curl -X POST https://cognito-idp.ap-northeast-1.amazonaws.com/ \
  -H "Content-Type: application/x-amz-json-1.1" \
  -H "X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth" \
  -d '{
    "AuthFlow": "USER_PASSWORD_AUTH",
    "ClientId": "xxx",
    "AuthParameters": {
      "USERNAME": "xxx",
      "PASSWORD": "xxx"
    }
  }')

curl "$API_URL" \
  -H "Authorization: Bearer $ID_TOKEN" \
  -H "Content-Type: application/json"