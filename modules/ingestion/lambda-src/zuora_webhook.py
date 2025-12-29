import base64
import json
import os
from datetime import datetime, timezone

import boto3

EVENT_BUS_NAME = os.environ.get("EVENT_BUS_NAME")
EVENT_SOURCE = "zuora.webhook"
EVENT_DETAIL_TYPE = "ZuoraPriceWebhookReceived"


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def handler(event, context):
    if not EVENT_BUS_NAME:
        return _response(500, {"message": "EVENT_BUS_NAME not configured"})

    body = event.get("body") or ""
    if event.get("isBase64Encoded"):
        try:
            body = base64.b64decode(body).decode("utf-8")
        except Exception:
            return _response(400, {"message": "Invalid base64 body"})

    try:
        payload = json.loads(body) if body else {}
    except json.JSONDecodeError:
        return _response(400, {"message": "Invalid JSON"})

    detail = {
        "payload": payload,
        "headers": event.get("headers") or {},
        "request_id": context.aws_request_id,
        "received_at": datetime.now(timezone.utc).isoformat(),
    }

    client = boto3.client("events")
    response = client.put_events(
        Entries=[
            {
                "EventBusName": EVENT_BUS_NAME,
                "Source": EVENT_SOURCE,
                "DetailType": EVENT_DETAIL_TYPE,
                "Detail": json.dumps(detail),
            }
        ]
    )

    failed_count = response.get("FailedEntryCount", 0)
    if failed_count:
        return _response(500, {"message": "Failed to enqueue event"})

    return _response(202, {"message": "Event accepted"})
