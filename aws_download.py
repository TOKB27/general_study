import os, io, csv, json, boto3, tempfile, time
from datetime import datetime
import psycopg
from psycopg.rows import dict_row

s3 = boto3.client("s3")
secrets = boto3.client("secretsmanager")

BUCKET = os.environ["BUCKET"]
DB_HOST = os.environ["DB_HOST"]
DB_PORT = int(os.environ.get("DB_PORT", "5432"))
DB_NAME = os.environ["DB_NAME"]
SECRET_ARN = os.environ["SECRET_ARN"]
DEFAULT_QUERY = os.environ.get("QUERY", "SELECT id, name, age FROM users ORDER BY id;")
FILE_NAME = os.environ.get("FILE_NAME", "export.csv")

def get_db_credentials():
    secret = secrets.get_secret_value(SecretId=SECRET_ARN)["SecretString"]
    j = json.loads(secret)
    return j["username"], j["password"]

def csv_tmp_file():
    # Excel互換: UTF-8 BOM + CRLF
    f = tempfile.NamedTemporaryFile(mode="w", newline="\r\n", delete=False, dir="/tmp", encoding="utf-8-sig")
    return f

def upload_and_sign(tmp_path, filename):
    key = f"tmp/export_{datetime.utcnow().strftime('%Y%m%d%H%M%S')}.csv"
    s3.upload_file(tmp_path, BUCKET, key, ExtraArgs={"ContentType": "text/csv", "Tagging": "one-time=true"})
    try:
        os.remove(tmp_path)
    except Exception:
        pass
    url = s3.generate_presigned_url(
        ClientMethod="get_object",
        Params={
            "Bucket": BUCKET,
            "Key": key,
            "ResponseContentDisposition": f'attachment; filename="{filename}"'
        },
        ExpiresIn=180  # 3分
    )
    return url

def export_postgres(query: str):
    user, pwd = get_db_credentials()

    # read-only/timeoutなどは接続直後に設定
    # psycopg3では autocommit=False がデフォ。必要に応じて調整。
    with psycopg.connect(
        host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=user, password=pwd
    ) as conn:
        with conn.cursor(name="csv_cursor", row_factory=dict_row) as cur:
            # セッションパラメータを安全に調整
            # statement_timeout: 600000ms = 10分（必要に応じ変更）
            cur.execute("SET LOCAL statement_timeout = 600000;")
            cur.execute("SET LOCAL default_transaction_read_only = on;")

            # ★任意のバインドパラメータにしたい場合は cur.execute(query, (param1, ...)) を使用
            cur.itersize = 5000
            cur.execute(query)

            f = csv_tmp_file()
            writer = csv.writer(f)

            # ヘッダー
            headers = [c.name for c in cur.description]
            writer.writerow(headers)

            # ストリーミング書き出し
            while True:
                rows = cur.fetchmany(cur.itersize)
                if not rows:
                    break
                for r in rows:
                    # dict_row なので列順に合わせて取り出し
                    writer.writerow([r[h] for h in headers])

            f.close()
            return upload_and_sign(f.name, FILE_NAME)

def lambda_handler(event, context):
    try:
        # 追加のパラメータをクエリ文字列やJSONボディから受ける例（任意）
        query = DEFAULT_QUERY
        if event.get("queryStringParameters", {}) and "q" in event["queryStringParameters"]:
            # 注意: 直接埋め込まず、サーバ側でクエリを識別する等が安全
            # ここでは簡易的に固定パターンを切替える想定
            pass

        url = export_postgres(query)

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json", "Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"download_url": url})
        }
    except Exception as e:
        print("ERROR:", repr(e))
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json", "Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }