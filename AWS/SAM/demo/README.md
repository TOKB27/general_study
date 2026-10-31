# SAM最小デモ

このサンプルは、Lambda + API Gateway を最小構成で動かすためのSAMテンプレートです。

## 構成

- Lambda: `hello_world/app.py`
- API Gateway: `/hello` の `GET` エンドポイント
- SAM template: `template.yaml`

## 実行手順

### 1. ビルド

```bash
cd AWS/SAM/demo
sam validate
sam build
```

### 2. ローカル関数の実行確認

```bash
sam local invoke HelloApiFunction --event events/event.json
```

### 3. ローカルAPI起動

Dockerが必要です。

```bash
sam local start-api
```

別ターミナルでアクセス:

```bash
curl "http://127.0.0.1:3000/hello?name=SAM"
```

### 4. AWSへデプロイ

```bash
sam deploy --guided
```

## 返却例

```json
{
  "message": "Hello SAM from SAM!",
  "path": "/hello",
  "method": "GET"
}
```

> 補足: `sam local` は Docker を前提に動くため、Docker未インストール環境では `sam build` と `sam validate` までは確認できます。
