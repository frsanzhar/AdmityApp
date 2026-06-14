import 'package:admity/features/career_test/domain/career_items_extra.dart';
import 'package:admity/features/career_test/domain/career_models.dart';

/// The RIASEC item bank (activity format reduces social-desirability bias).
/// The base set plus [kCareerItemsExtra] gives a fuller, more reliable read
/// (6 items per Holland type).
const List<RiasecItem> kRiasecItems = [
  RiasecItem('Чинить велосипед или собирать мебель', RiasecType.realistic),
  RiasecItem('Разбираться, как устроен двигатель или робот', RiasecType.realistic),
  RiasecItem('Разбираться, почему работает алгоритм', RiasecType.investigative),
  RiasecItem('Проводить эксперимент и анализировать данные', RiasecType.investigative),
  RiasecItem('Сочинять музыку, рисовать постер или писать рассказ', RiasecType.artistic),
  RiasecItem('Придумывать дизайн или необычную идею', RiasecType.artistic),
  RiasecItem('Объяснять однокласснику сложную тему', RiasecType.social),
  RiasecItem('Помогать людям решать их проблемы', RiasecType.social),
  RiasecItem('Организовать и продать школьный проект', RiasecType.enterprising),
  RiasecItem('Вести команду и убеждать других', RiasecType.enterprising),
  RiasecItem('Привести данные в таблице в идеальный порядок', RiasecType.conventional),
  RiasecItem('Вести учёт, расписание или бюджет по правилам', RiasecType.conventional),
  ...kCareerItemsExtra,
];

/// The Big Five item bank (agreement format). Base set plus
/// [kBigFiveItemsExtra] keeps each trait balanced across direct/reverse items.
const List<BigFiveItem> kBigFiveItems = [
  BigFiveItem('Я люблю пробовать новые, непривычные идеи', BigFiveTrait.openness),
  BigFiveItem('Мне нравится размышлять об абстрактных вещах', BigFiveTrait.openness),
  BigFiveItem('Я довожу начатое до конца, даже когда скучно', BigFiveTrait.conscientiousness),
  BigFiveItem('Я заранее планирую и держу всё в порядке', BigFiveTrait.conscientiousness),
  BigFiveItem('После шумной вечеринки я заряжаюсь энергией', BigFiveTrait.extraversion),
  BigFiveItem('Мне легко знакомиться и заговаривать с людьми', BigFiveTrait.extraversion),
  BigFiveItem('Мне легко поставить себя на место другого', BigFiveTrait.agreeableness),
  BigFiveItem('Я стараюсь помогать и не конфликтовать', BigFiveTrait.agreeableness),
  BigFiveItem('Я часто переживаю из-за мелочей', BigFiveTrait.neuroticism),
  BigFiveItem('Я спокоен даже под давлением', BigFiveTrait.neuroticism, reverse: true),
  ...kBigFiveItemsExtra,
];

/// Major clusters mapped to RIASEC letters.
const List<MajorCluster> kMajorClusters = [
  MajorCluster(
    name: 'Технологии и данные',
    description: 'Разработка, анализ данных, инженерия систем.',
    majors: ['Computer Science', 'Data Science', 'Software Engineering'],
    codes: ['I', 'R', 'C'],
  ),
  MajorCluster(
    name: 'Инженерия',
    description: 'Проектирование, механика, электроника, строительство.',
    majors: ['Mechanical Eng.', 'Electrical Eng.', 'Civil Eng.'],
    codes: ['R', 'I', 'E'],
  ),
  MajorCluster(
    name: 'Естественные науки и медицина',
    description: 'Биология, химия, исследования, здравоохранение.',
    majors: ['Биология', 'Общая медицина', 'Химия'],
    codes: ['I', 'S', 'R'],
  ),
  MajorCluster(
    name: 'Дизайн и творчество',
    description: 'Визуальное искусство, медиа, продуктовый дизайн.',
    majors: ['Graphic Design', 'Architecture', 'Media & Film'],
    codes: ['A', 'I', 'E'],
  ),
  MajorCluster(
    name: 'Образование и помощь людям',
    description: 'Педагогика, психология, социальная работа.',
    majors: ['Педагогика', 'Психология', 'Social Work'],
    codes: ['S', 'A', 'C'],
  ),
  MajorCluster(
    name: 'Бизнес и лидерство',
    description: 'Менеджмент, экономика, предпринимательство, маркетинг.',
    majors: ['Business', 'Economics', 'Marketing'],
    codes: ['E', 'C', 'S'],
  ),
];
