#!/usr/bin/env python3
"""
PashuRakhshak — Python Health Check & Deployment Verification Script
Verifies all critical backend services are reachable before production deployment.
Run: python scripts/healthcheck.py
"""

import urllib.request
import urllib.error
import json
import sys
import os
from datetime import datetime

# ── Config ──────────────────────────────────────────────────────────────────
SERVICES = [
    {
        "name": "Overpass API (OSM Vets Query)",
        "url": "https://overpass-api.de/api/status",
        "method": "GET",
        "expected_status": 200,
        "critical": True,
    },
    {
        "name": "OpenStreetMap Nominatim Geocoding",
        "url": "https://nominatim.openstreetmap.org/status.php?format=json",
        "method": "GET",
        "expected_status": 200,
        "critical": True,
    },
    {
        "name": "Overpass Mirror 2 (Kumi Systems)",
        "url": "https://overpass.kumi.systems/api/status",
        "method": "GET",
        "expected_status": 200,
        "critical": False,
    },
    {
        "name": "Font Awesome CDN",
        "url": "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css",
        "method": "GET",
        "expected_status": 200,
        "critical": False,
    },
    {
        "name": "Google Fonts CDN",
        "url": "https://fonts.googleapis.com/css2?family=Outfit:wght@400;700",
        "method": "GET",
        "expected_status": 200,
        "critical": False,
    },
]

TIMEOUT_SECONDS = 8

# ── Helpers ──────────────────────────────────────────────────────────────────
def check_service(service: dict) -> dict:
    name = service["name"]
    url = service["url"]
    try:
        req = urllib.request.Request(
            url,
            headers={"User-Agent": "PashuRakhshak-Healthcheck/1.0"},
        )
        with urllib.request.urlopen(req, timeout=TIMEOUT_SECONDS) as response:
            status = response.status
            ok = status == service.get("expected_status", 200)
            return {"name": name, "url": url, "status": status, "ok": ok, "error": None}
    except urllib.error.HTTPError as e:
        return {"name": name, "url": url, "status": e.code, "ok": False, "error": str(e)}
    except Exception as e:
        return {"name": name, "url": url, "status": None, "ok": False, "error": str(e)}


def print_result(result: dict, is_critical: bool) -> None:
    icon = "✅" if result["ok"] else ("❌" if is_critical else "⚠️ ")
    status_str = str(result["status"]) if result["status"] else "TIMEOUT/ERROR"
    err = f" — {result['error']}" if result["error"] and not result["ok"] else ""
    print(f"  {icon}  [{status_str}] {result['name']}{err}")


# ── Main ─────────────────────────────────────────────────────────────────────
def main() -> None:
    print("\n" + "=" * 60)
    print("  PashuRakhshak Backend Services Health Check")
    print(f"  {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60 + "\n")

    results = []
    critical_failures = 0

    for service in SERVICES:
        result = check_service(service)
        results.append(result)
        print_result(result, service["critical"])
        if not result["ok"] and service["critical"]:
            critical_failures += 1

    # Summary
    passed = sum(1 for r in results if r["ok"])
    total = len(results)
    print(f"\n{'=' * 60}")
    print(f"  Results: {passed}/{total} services healthy")

    if critical_failures > 0:
        print(f"  ❌ {critical_failures} CRITICAL service(s) failed — deployment blocked!")
        print("=" * 60 + "\n")
        sys.exit(1)
    else:
        print("  ✅ All critical services healthy — safe to deploy.")
        print("=" * 60 + "\n")
        sys.exit(0)


if __name__ == "__main__":
    main()
