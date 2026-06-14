import 'package:admity/features/chancing_kz/domain/ent_models.dart';

/// Reference ЕНТ cut-off data (2024 competition results).
///
/// Real cut-offs are published only AFTER the yearly competition and shift each
/// year — always carry the year and a "verify at source" note in the UI.
/// Sources: KazNMU «Полупроходные баллы», testcenter.kz, el.kz, nur.kz.
const List<EntCutoff> kEntCutoffsSeed = [
  EntCutoff(
    university: 'КазНМУ им. Асфендиярова',
    specialty: 'Общая медицина',
    year: 2024,
    govThreshold: 70,
    realCutoff: 124,
  ),
  EntCutoff(
    university: 'КазНМУ им. Асфендиярова',
    specialty: 'Стоматология',
    year: 2024,
    govThreshold: 70,
    realCutoff: 136,
  ),
  EntCutoff(
    university: 'КазНМУ им. Асфендиярова',
    specialty: 'Педиатрия',
    year: 2024,
    govThreshold: 70,
    realCutoff: 111,
  ),
  EntCutoff(
    university: 'КазНМУ им. Асфендиярова',
    specialty: 'Общественное здоровье',
    year: 2024,
    govThreshold: 70,
    realCutoff: 125,
  ),
  EntCutoff(
    university: 'Медицинский университет Астаны',
    specialty: 'Медицина',
    year: 2024,
    govThreshold: 70,
    realCutoff: 120,
  ),
  EntCutoff(
    university: 'Медицинский университет Семей',
    specialty: 'Медицина',
    year: 2024,
    govThreshold: 70,
    realCutoff: 111,
  ),
  EntCutoff(
    university: 'КБТУ',
    specialty: 'Вычислительная техника и ПО (IT)',
    year: 2024,
    govThreshold: 50,
    realCutoff: 110,
  ),
  EntCutoff(
    university: 'КазНПУ им. Абая',
    specialty: 'Педагогика (физика/биология)',
    year: 2024,
    govThreshold: 75,
    realCutoff: 88,
  ),
  EntCutoff(
    university: 'Назарбаев Университет (через NUFYP)',
    specialty: 'Foundation / бакалавриат',
    year: 2024,
    govThreshold: 65,
  ),
];
