import json
import os

import boto3

PRICING_TABLE_NAME = os.environ.get("PRICING_TABLE_NAME")


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def _extract_price_id(event):
    path_params = event.get("pathParameters") or {}
    return path_params.get("priceId")


def _from_ddb(item):
    return {key: list(value.values())[0] for key, value in item.items()}


def handler(event, context):
    if not PRICING_TABLE_NAME:
        return _response(500, {"message": "PRICING_TABLE_NAME not configured"})

    price_id = _extract_price_id(event)
    if not price_id:
        return _response(400, {"message": "priceId is required"})

    client = boto3.client("dynamodb")
    result = client.get_item(
        TableName=PRICING_TABLE_NAME,
        Key={"price_id": {"S": price_id}},
    )

    item = result.get("Item")
    if not item:
        return _response(404, {"message": "Price not found"})

    return _response(200, {"price": _from_ddb(item)})
