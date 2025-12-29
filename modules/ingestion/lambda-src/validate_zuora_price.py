import json
import os
import boto3

EVENT_BUS_NAME = os.environ.get("EVENT_BUS_NAME")
EVENT_SOURCE = "zuora.validation"
EVENT_DETAIL_TYPE = "ZuoraPriceValidated"
REQUIRED_FIELDS = ["price_id", "sku", "amount", "currency"]


def handler(event, context):
    if not EVENT_BUS_NAME:
        raise RuntimeError("EVENT_BUS_NAME not configured")

    detail = event.get("detail") or {}
    payload = detail.get("payload") if isinstance(detail, dict) else None
    if not isinstance(payload, dict):
        raise ValueError("Invalid payload shape")

    missing = []
    for field in REQUIRED_FIELDS:
        if field not in payload or payload.get(field) in (None, ""):
            missing.append(field)
    if missing:
        raise ValueError(f"Missing required fields: {','.join(missing)}")

    validated_detail = {
        "payload": payload,
        "received_at": detail.get("received_at"),
        "request_id": detail.get("request_id"),
    }

    client = boto3.client("events")
    response = client.put_events(
        Entries=[
            {
                "EventBusName": EVENT_BUS_NAME,
                "Source": EVENT_SOURCE,
                "DetailType": EVENT_DETAIL_TYPE,
                "Detail": json.dumps(validated_detail),
            }
        ]
    )

    if response.get("FailedEntryCount", 0):
        raise RuntimeError("Failed to publish validated event")

    return {"status": "ok"}
