REGION="ap-northeast-1"
CLIENT_ID="<APP_CLIENT_ID>"
USERNAME="<USERNAME>"
PASSWORD="<PASSWORD>"
API_URL="https://<api-id>.execute-api.ap-northeast-1.amazonaws.com/prod/sample"

ID_TOKEN=$(aws cognito-idp initiate-auth \
  --region "$REGION" \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id "$CLIENT_ID" \
  --auth-parameters USERNAME="$USERNAME",PASSWORD="$PASSWORD" \
  | jq -r '.AuthenticationResult.IdToken')

curl "$API_URL" \
  -H "Authorization: Bearer $ID_TOKEN" \
  -H "Content-Type: application/json"