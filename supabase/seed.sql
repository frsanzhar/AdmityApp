-- Reference data seed (mirrors the bundled Dart seed used offline).
-- Numbers carry a year and must be re-verified at the source each season.

insert into public.ent_cutoffs (university, specialty, year, gov_threshold, real_cutoff) values
  ('КазНМУ им. Асфендиярова', 'Общая медицина', 2024, 70, 124),
  ('КазНМУ им. Асфендиярова', 'Стоматология', 2024, 70, 136),
  ('КазНМУ им. Асфендиярова', 'Педиатрия', 2024, 70, 111),
  ('Медицинский университет Астаны', 'Медицина', 2024, 70, 120),
  ('КБТУ', 'Вычислительная техника и ПО (IT)', 2024, 50, 110),
  ('КазНПУ им. Абая', 'Педагогика (физика/биология)', 2024, 75, 88)
on conflict do nothing;

insert into public.cds_snapshots (university, year, acceptance_rate, sat_25, sat_75, act_25, act_75, gpa_avg, factors) values
  ('Harvard University', 2024, 0.04, 1500, 1580, 34, 36, 4.18,
    '{"rigor":"veryImportant","gpa":"veryImportant","essay":"veryImportant","recommendations":"veryImportant","character":"veryImportant","talent":"veryImportant","interest":"notConsidered"}'),
  ('MIT', 2024, 0.04, 1520, 1580, 35, 36, null,
    '{"rigor":"veryImportant","gpa":"veryImportant","essay":"veryImportant","character":"veryImportant","talent":"veryImportant"}'),
  ('University of Michigan', 2024, 0.18, 1370, 1530, 32, 35, null,
    '{"rigor":"veryImportant","gpa":"veryImportant","essay":"important"}'),
  ('Arizona State University', 2024, 0.88, 1110, 1350, 21, 28, null,
    '{"gpa":"veryImportant","rigor":"important"}')
on conflict do nothing;

insert into public.universities (slug, name, country, scope, ranking, tuition, languages, programs, fin_aid_notes, is_need_blind_full_need, cds_university_key) values
  ('nu', 'Nazarbayev University', 'Казахстан', 'kz', 1, 'Грант / NUFYP', '{English}', '{Engineering,CS,Medicine}', 'Граждане РК — через NUFYP (NUET + IELTS 6.0).', false, null),
  ('kbtu', 'КБТУ (KBTU)', 'Казахстан', 'kz', 3, 'Грант ЕНТ + платное', '{English,Русский}', '{IT,Business}', 'Поступление по сертификату ЕНТ.', false, null),
  ('harvard', 'Harvard University', 'США', 'world', 3, '~$57k (need-blind)', '{English}', '{CS,Economics,Sciences}', 'Need-blind + full-need для иностранцев.', true, 'Harvard University'),
  ('mit', 'MIT', 'США', 'world', 1, '~$60k (need-blind)', '{English}', '{Engineering,CS}', 'Need-blind + full-need для всех.', true, 'MIT'),
  ('asu', 'Arizona State University', 'США', 'world', null, '~$33k + merit', '{English}', '{Engineering,Business}', 'Высокий процент приёма; merit-скидки.', false, 'Arizona State University')
on conflict do nothing;

insert into public.scholarships (slug, name, country, levels, covers, deadline, eligibility, source_url, year, requires_work_years, age_max, requires_kz_citizen, note) values
  ('gov-grant-kz', 'Государственный грант РК', 'Казахстан', '{bachelor,master,phd}', '{обучение,стипендия}', 'после основного ЕНТ', 'Конкурс по баллам ЕНТ.', 'https://egov.kz', 2025, 0, null, true, null),
  ('bolashak', 'Болашак', 'Казахстан', '{master,phd,exchange}', '{обучение,перелёт,стипендия}', '3 марта – 17 октября 2025', 'Приглашение из списка, KAZTEST ≥ B1.', 'https://bolashak.gov.kz', 2025, 0, null, true, 'Бакалавриат пока не возвращён в программу.'),
  ('chevening', 'Chevening', 'Великобритания', '{master}', '{обучение,перелёт,стипендия}', 'авг–ноя; оффер до 9 июля', '~2 года опыта, 3 вуза UK.', 'https://chevening.org', null, 2, null, false, null),
  ('stipendium-hungaricum', 'Stipendium Hungaricum', 'Венгрия', '{bachelor,master,phd}', '{обучение,общежитие,стипендия}', '15 января 2026', 'Номинация sending partner.', 'https://stipendiumhungaricum.hu', 2026, 0, null, false, null),
  ('gks', 'Global Korea Scholarship', 'Южная Корея', '{bachelor}', '{обучение,стипендия,год языка}', 'embassy track ~сен–окт', 'Возраст <25, GPA ≥ 80%.', 'https://studyinkorea.go.kr', 2026, 0, 25, false, null)
on conflict do nothing;
