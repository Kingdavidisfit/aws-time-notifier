#!/usr/bin/env python3

import json
import urllib.request
from datetime import datetime

API_URL = "https://worldtimeapi.org/api/timezone/America/Phoenix"


def fetch_worldtime() -> dict:
    """Return parsed JSON from the API or raise on error."""
    req = urllib.request.Request(API_URL, headers={"User-Agent": "aws-time-notifier/1.0"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        if resp.status != 200:
            raise RuntimeError(f"HTTP {resp.status} from worldtimeapi")
        body = resp.read().decode("utf-8")
    data = json.loads(body)
    return data


def get_datetime_from_payload(payload: dict) -> str:
    """Extract the ISO8601 datetime string; raise if missing."""
    dt = payload.get("datetime")
    if not dt:
        raise KeyError("Response did not include 'datetime'")
    return dt


def main():
    try:
        payload = fetch_worldtime()

        # Log full payload (pretty)
        print("=== Full response ===")
        print(json.dumps(payload, indent=2))

        # Extract `datetime`
        dt_iso = get_datetime_from_payload(payload)
        print("\n=== Parsed datetime ===")
        print(dt_iso)

        #Parse to Python datetime to prove it’s valid ISO8601
        # (timezone-aware)
        parsed = datetime.fromisoformat(dt_iso.replace("Z", "+00:00"))
        print("\nParsed to Python datetime OK:", parsed)

    except Exception as exc:
        # In case of errors
        print("ERROR:", exc)
        raise


if __name__ == "__main__":
    main()
