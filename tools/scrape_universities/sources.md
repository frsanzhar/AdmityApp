# Confirmed primary sources (verified — fetched & parsed)

All URLs below were downloaded and parsed successfully. Re-check the НЦТ landing
pages each admissions cycle — the upload-date prefix in the file URL changes.

## Used by the scraper (scrape.py)

| What | URL | Format | Year |
|---|---|---|---|
| **University registry** (name, city, email→site) | `https://egov.kz/cms/ru/articles/2Fvusi_rk` | HTML, leaf tables per region | 2024 |
| **University type** (national/state/private/…) | `https://ru.wikipedia.org/wiki/Список_высших_учебных_заведений_Казахстана` | HTML `table.sortable` per type section | 2025 |
| **Min grant-competition scores** per university × ГОП | `https://testcenter.kz/wp-content/uploads/2025/01/1-Минимальные-баллы-ЕНТ-на-Конкурс-2024-16.07.2024-1.xlsx` | XLSX, sheet «Общая», 2733 rows | 2024 |
| **ГОП → profile ЕНТ subjects** | `https://testcenter.kz/wp-content/uploads/2026/05/Список-специальностей-полной-формы-обучения-с-профильными-предметами.pdf` | PDF, 5 p. | 2025–26 |

Universities come from **egov** (full registry, incl. non-grant private unis).
Grant data from the XLSX is joined onto egov unis by **normalised-name match**
(Jaccard ≥ 0.6). XLSX unis that don't match (truncated/divergent legal names,
~17) keep an `ovpo-*` id with their official name + oblast — never force-matched,
to avoid wrong merges (e.g. «Баишев» vs «Назарбаев»). Type is set only on a
confident Wikipedia name match (≈66/119); others stay null rather than guess.

XLSX columns (0-indexed, header at row 3, data from row 4):
`0 region_code · 1 oblast · 2 ОВПО_code · 3 university_name_ru · 4 study_form ·
5 area_code(6B01) · 6 area_name · 7 ГОП_code(B001) · 8 ГОП_name · 9 min_score`

> **Honesty note.** The XLSX score is the **минимальный балл для допуска к
> конкурсу на грант** (`metric = competition_min`), NOT the проходной балл
> (final cutoff). Final cutoffs are a post-competition outcome НЦТ does not
> publish as a clean file — they must be entered manually (`metric = cutoff`).

## Known but NOT machine-friendly (manual / later passes)

| What | URL | Why deferred |
|---|---|---|
| Final проходные баллы (outcomes) | `https://testcenter.kz/ru/postupayushchim-v-vuz/itogi-konkursa-obrazovatelnykh-grantov/...` | JS/portal-rendered, no clean file |
| КазНУ internal thresholds (paid/grant floor) | `https://welcome.kaznu.kz/content/files/pages/folder17969/Пороговые баллы КазНУ ... 2024.pdf` | per-university PDF |
| Tuition per program | per-university PDFs; `https://www.inform.kz/ru/...95cb30` aggregates top unis | scattered, no central source |
| Grant places + quota seats per ГОП | `https://adilet.zan.kz/rus/docs/G24HN000193` (state ed. order) | SSL issues; per-uni extraction |

## Caveats baked into the v1 output

- `city` is derived from the XLSX **oblast** column (region-level), refined later
  by the egov.kz pass. «ГОРОД АЛМАТЫ»/«ГОРОД АСТАНА» become real cities; oblasts
  stay region-level.
- Only **Очная полная форма обучения** rows are kept (one score per uni × ГОП).
- Profile subjects are best-effort from the PDF; left null when not confidently
  matched to two known ЕНТ subjects.
