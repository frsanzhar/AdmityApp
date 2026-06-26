# Universities catalog — data pipeline

Honest admissions reference for Kazakhstan: universities, education programs
(ГОП), what each university offers, and **grant cutoffs (проходные баллы)**.

## Source of truth & flow

```
  open sources (testirovanie.kz, Минобрнауки приказы, вуз-сайты)
        │   tools/scrape_universities/   (Python: fetch → normalise → cite)
        ▼
  assets/data/universities.json   ← offline source of truth the app ships
        │   (optional) import to Supabase via 0001 schema + service role
        ▼
  Supabase (public.* tables, RLS read-only)  ← server master / sync
```

- **App reads the JSON asset** (`UniversityCatalogLoader`) → works fully offline /
  guest mode. Provider: `universityCatalogProvider`.
- **Supabase** (`supabase/migrations/0001_universities_catalog.sql`) is the
  server master copy. Clients read only; writes go through the service role
  (the import script), never the anon key.

## The honesty rule (non‑negotiable)

This product promises real ЕНТ thresholds (see `CLAUDE.md`). Therefore:

1. **Never invent a grant cutoff.** A `grant_thresholds` row must have a real
   `source_url` and is shown as fact in the UI **only** when `is_verified =
   true`.
2. University name / city / type / website are stable facts and may be entered
   directly. Tuition, programs, and cutoffs must be sourced.
3. In KZ the grant competition is largely **national per‑ГОП**, so a threshold's
   `university_id` is usually `null` (national cutoff). Use a non‑null
   `university_id` only when a per‑university admitted range is actually
   published.

## JSON asset format

```jsonc
{
  "meta": { "schema_version": 1, "generated_at": "2026-…", "note": "…" },
  "universities":        [ { "id","name_ru","city","type", … } ],
  "education_programs":  [ { "code":"B057","name_ru", "ent_profile_subject_1", … } ],
  "university_programs": [ { "university_id","program_code","tuition_per_year_kzt", … } ],
  "grant_thresholds":    [ { "program_code","year","quota_type",
                             "min_score","is_verified","source_url" } ]
}
```

`type` ∈ `national | state | autonomous | private | international`.
`quota_type` ∈ `general | rural | lyceum | orphan | disability | oralman | other`.
Field meanings mirror the SQL columns in the 0001 migration one‑to‑one.

### Example `grant_thresholds` row (shape only — fill with a real source)

```json
{
  "program_code": "B057",
  "university_id": null,
  "year": 2024,
  "quota_type": "general",
  "min_score": 0,
  "is_verified": false,
  "source_url": "https://…",
  "note": "проходной балл на грант, общий конкурс"
}
```

## Adding / updating data

1. Put new rows into the JSON asset (or run the scraper, which writes it).
2. Keep `is_verified=false` until a human has confirmed the cited source.
3. `flutter test test/features/universities/` must stay green (validates the
   asset parses and every threshold carries a source_url).
4. To push to Supabase: apply `0001_…sql`, then import the JSON with the service
   role key.

## Scraping

See `tools/scrape_universities/` — `sources.md` lists the confirmed primary
source URLs and formats; `scrape.py` fetches and emits the JSON asset.
Run order and what must be entered by hand are documented there.
