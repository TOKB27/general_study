# LambdaのCLI
## Lambda関数の一覧
aws lambda list-functions \
  --query 'Functions[].{Name: FunctionName, Runtime: Runtime, Memory: MemorySize}' \
  --output table

## 関数のコードをzipでデプロイ
zip -r function.zip .
aws lambda update-function-code \
  --function-name my-function \
  --zip-file fileb://function.zip
rm function.zip