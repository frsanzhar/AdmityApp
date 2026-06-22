import 'package:admity/features/opportunities/domain/opportunity_models.dart';

/// Compile-time seed data.
/// Replace with async repository calls (Supabase / local DB) when ready.

const seedScholarships = <Scholarship>[
  Scholarship(
    id: 'bolashak',
    name: 'Болашак',
    city: 'Астана',
    field: AcademicField.engineering,
    coverageLabel: '100 % оплата зарубежного обучения',
    priceLabel: 'До 2 500 000 ₸/год',
    accessibility: Accessibility.hard,
    requiredDocuments: [
      'Удостоверение личности',
      'Аттестат / диплом',
      'Мотивационное письмо',
      'Рекомендательные письма (2 шт.)',
      'Результаты языкового теста (IELTS/TOEFL)',
    ],
    whatItCovers:
        'Полное покрытие стоимости обучения, проживания, транспортных расходов '
        'и ежемесячной стипендии на весь период учёбы за рубежом.',
    howToGet:
        'Подай заявку через портал bolashak.gov.kz. Пройди конкурсный отбор: '
        'тестирование + собеседование на знание казахского языка и профессиональных '
        'компетенций. Лауреаты обязаны отработать 2 года в Казахстане по возвращении.',
    requiredStats: 'ЕНТ ≥ 110 баллов · GPA ≥ 4.0 · IELTS ≥ 6.5 или TOEFL ≥ 90',
    howToBoostStats:
        'Для ЕНТ: проходи пробные ЕНТ ежемесячно, разбирай ошибки с Ералы. '
        'Для GPA: фиксируй текущие оценки в Профиле, Ералы составит план повышения. '
        'Для IELTS: задай план «Подготовка к IELTS» в Ералы — получишь поурочный '
        'расчёт с учётом твоих ресурсов.',
  ),
  Scholarship(
    id: 'rukhani',
    name: 'Стипендия «Рухани Жаңғыру»',
    city: 'Алматы',
    field: AcademicField.arts,
    coverageLabel: '50 % оплата обучения',
    priceLabel: '150 000 ₸/мес',
    accessibility: Accessibility.medium,
    requiredDocuments: [
      'Удостоверение личности',
      'Аттестат',
      'Портфолио творческих работ',
      'Характеристика от учителя',
    ],
    whatItCovers:
        'Покрывает 50 % стоимости обучения в аккредитованном вузе Казахстана '
        'по направлениям культуры и искусства. Дополнительно выплачивается '
        'ежемесячная стипендия 150 000 ₸.',
    howToGet:
        'Регистрация на enic.kz. Загрузи документы и портфолио. '
        'Комиссия рассматривает заявки в феврале и августе каждого года.',
    requiredStats: 'ЕНТ ≥ 80 баллов · Портфолио: не менее 5 творческих работ',
    howToBoostStats:
        'Для ЕНТ: раздел «Курсы» → профиль «Гуманитарный». '
        'Для портфолио: используй раздел «Идеи проектов» — там есть конкретные '
        'идеи для творческого направления.',
  ),
  Scholarship(
    id: 'nazarbayev_uni',
    name: 'Стипендия Назарбаев Университета',
    city: 'Астана',
    field: AcademicField.informatics,
    coverageLabel: '100 % оплата обучения + общежитие',
    priceLabel: '200 000 ₸/мес',
    accessibility: Accessibility.hard,
    requiredDocuments: [
      'Удостоверение личности',
      'Аттестат с отличием',
      'SAT / ACT результаты',
      'Рекомендательные письма (2 шт.)',
      'Эссе',
    ],
    whatItCovers:
        'Полная оплата обучения в Назарбаев Университете, проживание в общежитии '
        'и ежемесячная стипендия. Обучение ведётся на английском языке.',
    howToGet:
        'Подай заявку на nu.edu.kz в период с октября по январь. '
        'Конкурсный отбор включает онлайн-тест, эссе и видео-интервью.',
    requiredStats: 'SAT ≥ 1200 · GPA ≥ 4.5 · IELTS ≥ 7.0',
    howToBoostStats:
        'Для SAT: задай в Ералы план «Подготовка к SAT» с указанием стартового '
        'уровня — получишь пошаговый план. '
        'Для IELTS: аналогично — создай план «IELTS за 3 месяца». '
        'Для GPA: в разделе Профиль зафиксируй оценки, Ералы выделит слабые места.',
  ),
  Scholarship(
    id: 'med_grant',
    name: 'Образовательный грант — Медицина',
    city: 'Шымкент',
    field: AcademicField.medicine,
    coverageLabel: '100 % оплата по гос. гранту',
    accessibility: Accessibility.medium,
    requiredDocuments: [
      'Удостоверение личности',
      'Аттестат',
      'Результаты ЕНТ',
      'Медицинская справка 086-У',
    ],
    whatItCovers:
        'Государственный образовательный грант покрывает полную стоимость '
        'обучения в медицинском вузе Казахстана. Студент оплачивает '
        'только проживание и питание.',
    howToGet:
        'Зарегистрируйся на платформе grantee.kz после получения результатов ЕНТ. '
        'Выбери вуз и специальность в рамках выделенных квот.',
    requiredStats: 'ЕНТ ≥ 95 баллов · Биология + Химия ≥ 20 каждый',
    howToBoostStats:
        'В разделе «Курсы» выбери профиль «Естественные науки». '
        'Ералы составит дополнительный план по биологии и химии с упором '
        'на разделы, которые чаще всего встречаются в ЕНТ.',
  ),
  Scholarship(
    id: 'economy_grant',
    name: 'Стипендия «Экономика и бизнес»',
    city: 'Алматы',
    field: AcademicField.economics,
    coverageLabel: '75 % оплата обучения',
    priceLabel: '120 000 ₸/мес',
    accessibility: Accessibility.easy,
    requiredDocuments: [
      'Удостоверение личности',
      'Аттестат',
      'Результаты ЕНТ',
      'Мотивационное письмо',
    ],
    whatItCovers:
        'Покрывает 75 % стоимости обучения в аккредитованном вузе по экономическим '
        'специальностям. Стипендия 120 000 ₸/мес выплачивается при GPA ≥ 3.5.',
    howToGet:
        'Подача заявок через портал вуза с марта по июнь. '
        'Отбор по баллам ЕНТ и собеседованию.',
    requiredStats: 'ЕНТ ≥ 85 баллов · Математика ≥ 18 баллов',
    howToBoostStats:
        'В разделе «Курсы» работай над темой «Математика». '
        'Отслеживай прогресс в Профиле — видно, какие разделы отстают.',
  ),
];

const seedUniversities = <University>[
  University(
    id: 'nu',
    name: 'Назарбаев Университет',
    city: 'Астана',
    field: AcademicField.engineering,
    tuitionLabel: '1 400 000 ₸/год',
    accessibility: Accessibility.hard,
    description:
        'Исследовательский университет мирового уровня. Обучение на английском. '
        'Партнёры: Cambridge, UCL, Duke, Wisconsin.',
    entThreshold: 110,
  ),
  University(
    id: 'kaznu',
    name: 'КазНУ им. аль-Фараби',
    city: 'Алматы',
    field: AcademicField.natural,
    tuitionLabel: '650 000 ₸/год',
    accessibility: Accessibility.medium,
    description:
        'Крупнейший классический университет Казахстана. Широкий выбор '
        'специальностей. Государственные гранты доступны.',
    entThreshold: 85,
  ),
  University(
    id: 'kbtu',
    name: 'КБТУ',
    city: 'Алматы',
    field: AcademicField.informatics,
    tuitionLabel: '1 100 000 ₸/год',
    accessibility: Accessibility.medium,
    description:
        'IT-ориентированный университет с сильными программами по CS, Data Science '
        'и Cybersecurity. Совместные программы с Chevron и Schlumberger.',
    entThreshold: 95,
  ),
  University(
    id: 'aupet',
    name: 'АУЭС',
    city: 'Алматы',
    field: AcademicField.engineering,
    tuitionLabel: '700 000 ₸/год',
    accessibility: Accessibility.easy,
    description:
        'Алматинский университет энергетики и связи. Сильные программы по '
        'электроэнергетике, телекоммуникациям и автоматике.',
    entThreshold: 75,
  ),
  University(
    id: 'sdu',
    name: 'SDU University',
    city: 'Кентау',
    field: AcademicField.economics,
    tuitionLabel: '800 000 ₸/год',
    accessibility: Accessibility.medium,
    description:
        'Частный университет с международной аккредитацией. Программы МВА, '
        'экономики и права. Обучение на казахском, русском и английском.',
    entThreshold: 80,
  ),
];

const seedEvents = <OpportunityEvent>[
  OpportunityEvent(
    id: 'stem_fair',
    title: 'STEM-ярмарка Казахстана',
    dateLabel: '15 июля 2026',
    city: 'Астана',
    description:
        'Национальная выставка студенческих научных проектов. '
        'Победители получают гранты до 500 000 ₸ и рекомендательные письма от МОН РК.',
  ),
  OpportunityEvent(
    id: 'olympiad_math',
    title: 'Республиканская олимпиада по математике',
    dateLabel: '20 августа 2026',
    city: 'Алматы',
    description:
        'Ежегодная олимпиада для учащихся 9–11 классов. '
        'Призёры получают льготы при поступлении в ведущие вузы Казахстана.',
  ),
  OpportunityEvent(
    id: 'hackathon_kz',
    title: 'HackAlmaty 2026',
    dateLabel: '3 сентября 2026',
    city: 'Алматы',
    description:
        'Хакатон для школьников и студентов по направлениям AI, fintech и '
        'edtech. Призовой фонд 3 000 000 ₸. Регистрация открыта.',
  ),
  OpportunityEvent(
    id: 'arts_contest',
    title: 'Конкурс молодых художников «Дала»',
    dateLabel: '10 октября 2026',
    city: 'Шымкент',
    description:
        'Открытый конкурс живописи, графики и цифрового искусства для '
        'участников до 19 лет. Лучшие работы войдут в национальную экспозицию.',
  ),
];

const seedProjectIdeas = <ProjectIdea>[
  ProjectIdea(
    id: 'ml_ent',
    title: 'Предиктор ЕНТ-баллов',
    field: AcademicField.informatics,
    description:
        'Создай модель ML, которая по истории оценок и пробных тестов '
        'предсказывает ожидаемый балл ЕНТ. Стек: Python, scikit-learn, Streamlit.',
    difficulty: 'Средне',
  ),
  ProjectIdea(
    id: 'eco_monitor',
    title: 'Мониторинг качества воздуха в городе',
    field: AcademicField.natural,
    description:
        'Собери данные с открытых API (aqicn.org) и построй интерактивный дашборд '
        'качества воздуха для своего города. Визуализация — Python + Plotly.',
    difficulty: 'Легко',
  ),
  ProjectIdea(
    id: 'math_viz',
    title: 'Интерактивный учебник по теории вероятностей',
    field: AcademicField.mathematics,
    description:
        'Разработай веб-приложение с визуализацией вероятностных экспериментов '
        '(монеты, кубики, карты). Стек: Flutter Web или React + D3.js.',
    difficulty: 'Средне',
  ),
  ProjectIdea(
    id: 'med_tracker',
    title: 'Приложение для учёта вакцинации',
    field: AcademicField.medicine,
    description:
        'Создай мобильное приложение для хранения карты прививок и напоминаний '
        'о ревакцинации. Интеграция с ГБД МЗ РК (открытое API).',
    difficulty: 'Сложно',
  ),
  ProjectIdea(
    id: 'startup_pitch',
    title: 'Pitch-дека стартапа в сфере edtech',
    field: AcademicField.economics,
    description:
        'Проанализируй рынок EdTech в Казахстане, выяви проблему, предложи решение '
        'и создай профессиональную pitch-деку (10 слайдов). Покажи unit-экономику.',
    difficulty: 'Средне',
  ),
  ProjectIdea(
    id: 'legal_bot',
    title: 'Чат-бот по правам потребителя',
    field: AcademicField.law,
    description:
        'Создай телеграм-бота, который отвечает на типичные вопросы по ЗПП '
        'Казахстана (возврат товара, гарантии). База знаний — нормативные акты РК.',
    difficulty: 'Средне',
  ),
  ProjectIdea(
    id: 'bridge_eng',
    title: 'Симулятор нагрузки на мост',
    field: AcademicField.engineering,
    description:
        'Смоделируй нагрузки на балочный мост в Python (numpy/matplotlib). '
        'Определи точку максимального прогиба и визуализируй распределение сил.',
    difficulty: 'Сложно',
  ),
  ProjectIdea(
    id: 'digital_art',
    title: 'Цифровой арт-альбом «Моя Степь»',
    field: AcademicField.arts,
    description:
        'Создай серию (10+) цифровых иллюстраций на тему казахской степи '
        'с описанием концепции. Оформи в PDF-портфолио для стипендии Рухани Жаңғыру.',
    difficulty: 'Легко',
  ),
];
