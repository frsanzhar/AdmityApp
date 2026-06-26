#!/usr/bin/env python3
"""Load assets/data/universities.json into Supabase via PostgREST (upsert).

Apply the schema first (supabase/migrations/0001_universities_catalog.sql),
e.g. `supabase db push` or paste it into the dashboard SQL editor.

Then run this with the SERVICE-ROLE key (never the anon key — and never commit
it). The service role bypasses RLS, which is required for writes:

    export SUPABASE_URL=https://xxxx.supabase.co
    export SUPABASE_SERVICE_ROLE_KEY=eyJ... # Settings -> API -> service_role
    python3 import_supabase.py

Idempotent: uses on_conflict upsert, so re-running just refreshes rows.
Deps: requests.
"""
from __future__ import annotations

import json
import os
import sys

import requests

# Only real table columns are sent; any extra JSON keys (e.g. subjects_source_url)
# are dropped so PostgREST doesn't reject the row.
TABLES = {
    "universities": {
        "cols": ["id", "name_ru", "name_kz", "name_en", "city", "type",
                 "website", "has_dormitory", "description", "source_url"],
        "on_conflict": "id",
    },
    "education_programs": {
        "cols": ["code", "name_ru", "name_kz", "field",
                 "ent_profile_subject_1", "ent_profile_subject_2", "source_url"],
        "on_conflict": "code",
    },
    "university_programs": {
        "cols": ["university_id", "program_code", "tuition_per_year_kzt",
                 "languages", "grant_places", "source_url"],
        "on_conflict": "university_id,program_code",
    },
    "grant_thresholds": {
        "cols": ["program_code", "university_id", "year", "quota_type",
                 "metric", "min_score", "max_score", "is_verified",
                 "source_url", "note"],
        "on_conflict": "program_code,university_id,year,quota_type,metric",
    },
}
BATCH = 500


def main() -> int:
    url = os.environ.get("SUPABASE_URL", "").rstrip("/")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
    if not url or not key:
        print("Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY", file=sys.stderr)
        return 2

    here = os.path.dirname(os.path.abspath(__file__))
    data_path = os.path.join(here, "..", "..", "assets", "data", "universities.json")
    data = json.load(open(data_path, encoding="utf-8"))

    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates,return=minimal",
    }

    # Insert order respects FK dependencies.
    order = ["universities", "education_programs",
             "university_programs", "grant_thresholds"]
    for table in order:
        spec = TABLES[table]
        cols = set(spec["cols"])
        rows = [
            {k: v for k, v in row.items() if k in cols}
            for row in data.get(table, [])
        ]
        endpoint = f"{url}/rest/v1/{table}?on_conflict={spec['on_conflict']}"
        sent = 0
        for i in range(0, len(rows), BATCH):
            chunk = rows[i:i + BATCH]
            resp = requests.post(endpoint, headers=headers,
                                 data=json.dumps(chunk), timeout=60)
            if resp.status_code >= 300:
                print(f"[{table}] HTTP {resp.status_code}: {resp.text[:400]}",
                      file=sys.stderr)
                return 1
            sent += len(chunk)
        print(f"  {table}: upserted {sent}", file=sys.stderr)

    print("Done.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
