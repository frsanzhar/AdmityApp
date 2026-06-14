import 'package:admity/features/career_test/domain/career_models.dart';

/// Additional RIASEC interest items, designed to be appended to
/// `kRiasecItems`. Keeping them in a separate const list lets the test grow
/// without touching the base bank, while the activity ("how interesting is
/// it to…") format is preserved to reduce social-desirability bias.
///
/// Combine with the base bank via:
/// `const [...kRiasecItems, ...kCareerItemsExtra]`.
const List<RiasecItem> kCareerItemsExtra = [
  // Realistic — hands, tools, physical / outdoor work.
  RiasecItem('Выращивать растения или ухаживать за животными', RiasecType.realistic),
  RiasecItem('Настраивать оборудование или паять схему', RiasecType.realistic),
  RiasecItem('Заниматься спортом или работать на природе', RiasecType.realistic),
  RiasecItem('Собирать и запускать дрон или 3D-принтер', RiasecType.realistic),

  // Investigative — analysis, science, problem solving.
  RiasecItem('Решать сложные головоломки и логические задачи', RiasecType.investigative),
  RiasecItem('Читать о новых научных открытиях', RiasecType.investigative),
  RiasecItem('Строить гипотезу и проверять её на данных', RiasecType.investigative),
  RiasecItem('Разбираться, как устроены болезни и лекарства', RiasecType.investigative),

  // Artistic — creativity, self-expression, aesthetics.
  RiasecItem('Снимать видео или монтировать ролик', RiasecType.artistic),
  RiasecItem('Фотографировать и обрабатывать снимки', RiasecType.artistic),
  RiasecItem('Играть на инструменте или петь', RiasecType.artistic),
  RiasecItem('Придумывать сюжет игры или комикса', RiasecType.artistic),

  // Social — people, teaching, helping, care.
  RiasecItem('Быть наставником для младших ребят', RiasecType.social),
  RiasecItem('Волонтёрить и поддерживать тех, кому трудно', RiasecType.social),
  RiasecItem('Разрешать конфликты и мирить друзей', RiasecType.social),
  RiasecItem('Проводить тренинг или мастер-класс', RiasecType.social),

  // Enterprising — influence, business, persuasion.
  RiasecItem('Запускать свой небольшой бизнес или стартап', RiasecType.enterprising),
  RiasecItem('Выступать с речью и убеждать аудиторию', RiasecType.enterprising),
  RiasecItem('Договариваться о сделке и вести переговоры', RiasecType.enterprising),
  RiasecItem('Придумывать рекламу и продвигать продукт', RiasecType.enterprising),

  // Conventional — order, data, structure, rules.
  RiasecItem('Наводить порядок в файлах и документах', RiasecType.conventional),
  RiasecItem('Считать бюджет и сводить финансы без ошибок', RiasecType.conventional),
  RiasecItem('Работать с таблицами и формулами в Excel', RiasecType.conventional),
  RiasecItem('Проверять текст на ошибки и оформлять по правилам', RiasecType.conventional),
];

/// Additional Big Five agreement items, designed to be appended to
/// `kBigFiveItems`. Two items per trait keep each scale balanced; some use
/// [BigFiveItem.reverse] so the scale is not all keyed in one direction.
///
/// Combine with the base bank via:
/// `const [...kBigFiveItems, ...kBigFiveItemsExtra]`.
const List<BigFiveItem> kBigFiveItemsExtra = [
  BigFiveItem('Меня привлекают искусство и необычные идеи', BigFiveTrait.openness),
  BigFiveItem('Мне нравится рутина больше, чем перемены', BigFiveTrait.openness, reverse: true),
  BigFiveItem('Я аккуратен и редко опаздываю', BigFiveTrait.conscientiousness),
  BigFiveItem('Я часто откладываю дела на потом', BigFiveTrait.conscientiousness, reverse: true),
  BigFiveItem('Я люблю быть в центре внимания', BigFiveTrait.extraversion),
  BigFiveItem('Мне комфортнее наедине с собой', BigFiveTrait.extraversion, reverse: true),
  BigFiveItem('Я доверяю людям и верю в их хорошие намерения', BigFiveTrait.agreeableness),
  BigFiveItem('Я готов уступить, чтобы сохранить мир', BigFiveTrait.agreeableness),
  BigFiveItem('Меня легко вывести из равновесия', BigFiveTrait.neuroticism),
  BigFiveItem('Я редко чувствую тревогу без причины', BigFiveTrait.neuroticism, reverse: true),
];
