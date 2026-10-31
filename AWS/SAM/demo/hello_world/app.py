import json
from typing import Any, Dict


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    query_params = event.get("queryStringParameters") or {}
    name = query_params.get("name", "World")

    payload = {
        "message": f"Hello {name} from SAM!",
        "path": event.get("path", "/hello"),
        "method": event.get("httpMethod", "GET"),
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(payload, ensure_ascii=False),
    }
