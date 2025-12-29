import json
import os
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation

import boto3

TABLE_NAME = os.environ.get("TABLE_NAME")


def handler(event, context):
    if not TABLE_NAME:
        raise RuntimeError("TABLE_NAME not configured")

    detail = event.get("detail") or {}
    payload = detail.get("payload") if isinstance(detail, dict) else None
    if not isinstance(payload, dict):
        raise ValueError("Invalid payload shape")

    price_id = payload.get("price_id") or payload.get("id")
    if not price_id:
        raise ValueError("Missing price_id")

    amount = payload.get("amount")
    normalized_amount = None
    if amount is not None:
        try:
            normalized_amount = Decimal(str(amount))
        except (InvalidOperation, ValueError):
            raise ValueError("Invalid amount")

    item = {
        "price_id": str(price_id),
        "sku": str(payload.get("sku", "")),
        "amount": normalized_amount,
        "currency": str(payload.get("currency", "")),
        "effective_at": payload.get("effective_at"),
        "ingested_at": datetime.now(timezone.utc).isoformat(),
        "raw_payload": json.dumps(payload),
    }

    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(TABLE_NAME)
    table.put_item(Item=item)

    return {"status": "stored", "price_id": price_id}
