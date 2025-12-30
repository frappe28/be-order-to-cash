import os
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation

import boto3

DYNAMO_TABLE_NAME = os.environ.get("DYNAMO_TABLE_NAME")


def _normalize_amount(value):
    if value is None or value == "":
        raise ValueError("amount is required")
    try:
        return Decimal(str(value))
    except (InvalidOperation, ValueError) as exc:
        raise ValueError("amount must be a number") from exc


def _normalize_sku(value):
    if value is None:
        return ""
    return str(value).strip().upper()


def _normalize_currency(value):
    if value is None:
        return ""
    return str(value).strip().upper()


def _derive_market(payload):
    raw_key = payload.get("market_key") or payload.get("price_list") or payload.get("region")
    if not raw_key:
        return "GLOBAL"
    key = str(raw_key).strip().upper()
    if "EU" in key or "IT" in key:
        return "EU"
    if "US" in key:
        return "US"
    if "UK" in key:
        return "UK"
    return "GLOBAL"


def handler(event, context):
    if not DYNAMO_TABLE_NAME:
        raise RuntimeError("DYNAMO_TABLE_NAME not configured")

    detail = event.get("detail") or {}
    payload = detail.get("payload") if isinstance(detail, dict) else None
    if not isinstance(payload, dict):
        raise ValueError("Invalid payload shape")

    price_id = payload.get("price_id")
    if not price_id:
        raise ValueError("price_id is required")

    item = {
        "price_id": str(price_id).strip(),
        "sku": _normalize_sku(payload.get("sku")),
        "amount": _normalize_amount(payload.get("amount")),
        "currency": _normalize_currency(payload.get("currency")),
        "market": _derive_market(payload),
        "updated_at": datetime.now(timezone.utc).isoformat(),
    }

    client = boto3.client("dynamodb")
    client.put_item(
        TableName=DYNAMO_TABLE_NAME,
        Item={
            "price_id": {"S": item["price_id"]},
            "sku": {"S": item["sku"]},
            "amount": {"N": str(item["amount"])},
            "currency": {"S": item["currency"]},
            "market": {"S": item["market"]},
            "updated_at": {"S": item["updated_at"]},
        },
    )

    return {"status": "ok"}
