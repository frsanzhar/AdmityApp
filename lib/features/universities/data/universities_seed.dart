import 'package:admity/features/universities/domain/university.dart';

/// Reference university catalogue (KZ + world). Tuition/fin-aid figures are
/// indicative and must be verified at the source each year. Acceptance rates
/// are fractions (0..1); world figures track each school's Common Data Set,
/// KZ figures are estimates («оценка») where no official rate is published.
const List<University> kUniversitiesSeed = [
  // ── Kazakhstan ──────────────────────────────────────────────────────────
  University(
    slug: 'nu',
    name: 'Nazarbayev University',
    country: 'Казахстан',
    scope: UniScope.kz,
    languages: ['English'],
    programs: ['Engineering', 'CS', 'Medicine', 'Sciences'],
    ranking: 1,
    tuition: 'Грант / NUFYP (бесплатно по гранту)',
    finAidNotes: 'Граждане РК — через NUFYP (NUET + IELTS 6.0).',
    acceptanceRate: 0.67,
    acceptanceRateYear: 2024,
    isAcceptanceRateEstimate: true,
    website: 'https://nu.edu.kz',
    mission: 'Исследовательский университет мирового уровня: качественное '
        'образование, влиятельные исследования и инновации на благо страны '
        'и общества.',
    values: [
      'Академическое превосходство',
      'Исследования и инновации',
      'Служение стране и обществу',
      'Глобальные стандарты',
    ],
    notableFacts: [
      'Всё обучение на английском по западной модели',
      'Поступление через год подготовки NUFYP',
      'Партнёрства с ведущими мировыми университетами',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'ЕНТ 132/140, английский IELTS 7.0, '
            'призёр республиканской олимпиады по физике',
        whatWorked: 'Сильный профиль по STEM и высокий балл NUET; '
            'мотивационное эссе про конкретный инженерный проект.',
        outcome: 'Поступил(а) на инженерное направление по гранту через NUFYP',
      ),
      AdmittedCase(
        profileSummary: 'GPA 4.9, IELTS 6.5, школьный исследовательский '
            'проект по биологии, волонтёрство',
        whatWorked: 'Последовательный интерес к наукам о жизни плюс '
            'лидерская роль во внеучебной деятельности.',
        outcome: 'Зачислен(а) на направление Sciences после NUFYP',
      ),
    ],
  ),
  University(
    slug: 'kbtu',
    name: 'КБТУ (KBTU)',
    country: 'Казахстан',
    scope: UniScope.kz,
    languages: ['English', 'Русский'],
    programs: ['IT', 'Petroleum', 'Business', 'Math'],
    ranking: 3,
    tuition: 'Грант ЕНТ + платное / скидки',
    finAidNotes: 'Поступление по сертификату ЕНТ, есть гранты вуза.',
    website: 'https://kbtu.edu.kz',
    mission: 'Готовить будущих лидеров бизнеса и индустрии, продвигать '
        'инновационные технологии и исследования на благо региона и страны.',
    values: [
      'Международные стандарты образования',
      'Инновации и исследования',
      'Связь с индустрией',
      'Инженерное и предпринимательское мышление',
    ],
    notableFacts: [
      'Создан в 2001 году по меморандуму с British Council',
      'Сильные программы по IT и нефтегазовому делу',
      'Цель — ведущий технический вуз Центральной Азии',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'ЕНТ 125/140 (математика + физика), '
            'участие в хакатонах',
        whatWorked: 'Высокий балл по профильным предметам ЕНТ и '
            'портфолио учебных проектов по программированию.',
        outcome: 'Поступил(а) на IT-направление, часть гранта вуза',
      ),
      AdmittedCase(
        profileSummary: 'ЕНТ 118/140, английский Upper-Intermediate, '
            'опыт в школьном бизнес-клубе',
        whatWorked: 'Достаточный балл ЕНТ для платного с хорошей '
            'скидкой; внеучебная активность по бизнесу.',
        outcome: 'Зачислен(а) на Business со скидкой по результатам ЕНТ',
      ),
    ],
  ),
  University(
    slug: 'sdu',
    name: 'SDU University',
    country: 'Казахстан',
    scope: UniScope.kz,
    languages: ['English', 'Қазақша'],
    programs: ['CS', 'Engineering', 'Education'],
    tuition: 'Грант ЕНТ + платное',
    website: 'https://sdu.edu.kz',
    mission: 'Готовить высококвалифицированных специалистов с инновационным '
        'мышлением, способных работать в условиях глобального сотрудничества.',
    values: [
      'Интернационализация образования',
      'Трёхъязычная среда',
      'Инновационное мышление',
      'Современные компетенции',
    ],
    notableFacts: [
      'Один из первых частных вузов РК (основан в 1996)',
      'Около 81% программ преподаются на английском',
      'Кампус в Каскелене недалеко от Алматы',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'ЕНТ 110/140, английский Intermediate, '
            'школьные проекты по программированию',
        whatWorked: 'Балл ЕНТ выше порога направления CS; '
            'демонстрация интереса к разработке.',
        outcome: 'Поступил(а) на Computer Science (платное со скидкой)',
      ),
      AdmittedCase(
        profileSummary: 'ЕНТ 122/140, грантовый порог по педагогике, '
            'опыт репетиторства',
        whatWorked: 'Высокий балл для образовательного направления и '
            'мотивация заниматься преподаванием.',
        outcome: 'Зачислен(а) на Education по гранту',
      ),
    ],
  ),
  University(
    slug: 'kimep',
    name: 'KIMEP University',
    country: 'Казахстан',
    scope: UniScope.kz,
    languages: ['English'],
    programs: ['Business', 'Law', 'Social Sciences'],
    tuition: 'Платное + стипендии',
    finAidNotes: 'Американская модель образования на английском.',
    website: 'https://www.kimep.kz',
    mission: 'Развивать образованных граждан и повышать качество жизни в '
        'Казахстане и Центральной Азии через обучение, исследования и '
        'служение обществу в сфере бизнеса и социальных наук.',
    values: [
      'Североамериканская модель образования',
      'Обучение на английском языке',
      'Мультикультурная среда',
      'Связь знаний с обществом региона',
    ],
    notableFacts: [
      'Старейший вуз США-модели в Центральной Азии (с 1992)',
      'Преподаватели из 18+ стран мира',
      'Кредитно-модульная система обучения',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'IELTS 6.5, средний балл аттестата высокий, '
            'участие в дебатном клубе',
        whatWorked: 'Хороший английский и активность в дебатах — '
            'важны для бизнес- и юридических программ.',
        outcome: 'Поступил(а) на Business с частичной стипендией',
      ),
      AdmittedCase(
        profileSummary: 'IELTS 7.0, эссе про права человека, '
            'волонтёрство в НКО',
        whatWorked: 'Сильное эссе и социальная вовлечённость '
            'для направления социальных наук.',
        outcome: 'Зачислен(а) на Social Sciences со стипендией',
      ),
    ],
  ),
  University(
    slug: 'aitu',
    name: 'Astana IT University',
    country: 'Казахстан',
    scope: UniScope.kz,
    languages: ['English', 'Русский'],
    programs: ['IT', 'Data Science', 'Cybersecurity'],
    tuition: 'Грант ЕНТ + платное',
    website: 'https://astanait.edu.kz',
    mission: 'Стать ведущим центром компетенций цифровой трансформации в '
        'Центральной Азии и готовить специалистов для цифровой экономики через '
        'обучение, исследования и инновации.',
    values: [
      'Человекоцентричность',
      'Доступность, справедливость, толерантность',
      'Академическая свобода и честность',
      'Обучение через всю жизнь',
    ],
    notableFacts: [
      'Специализация — цифровая трансформация и IT',
      'Тесные связи с IT-индустрией',
      'Междисциплинарный подход к подготовке',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'ЕНТ 120/140 (математика + информатика), '
            'pet-проекты на GitHub',
        whatWorked: 'Профильный балл ЕНТ и реальное портфолио кода '
            'по веб- и мобильной разработке.',
        outcome: 'Поступил(а) на IT-направление по гранту',
      ),
      AdmittedCase(
        profileSummary: 'ЕНТ 108/140, курсы по Python онлайн, '
            'интерес к анализу данных',
        whatWorked: 'Достаточный балл для платного и понятная '
            'мотивация по Data Science.',
        outcome: 'Зачислен(а) на Data Science (платное)',
      ),
    ],
  ),
  // ── World ───────────────────────────────────────────────────────────────
  University(
    slug: 'harvard',
    name: 'Harvard University',
    country: 'США',
    scope: UniScope.world,
    languages: ['English'],
    programs: ['Liberal Arts', 'CS', 'Sciences', 'Economics'],
    ranking: 3,
    tuition: r'~$57k (но need-blind + full-need)',
    finAidNotes: 'Need-blind + full-need для иностранцев. '
        r'Доход <$200k — обучение часто $0.',
    isNeedBlindFullNeed: true,
    cdsUniversityKey: 'Harvard University',
    acceptanceRate: 0.036,
    acceptanceRateYear: 2025,
    website: 'https://college.harvard.edu',
    mission: 'Готовить граждан и лидеров: помогать студентам понять, как '
        'применить свои таланты и ценности, чтобы лучше служить миру.',
    values: [
      'Академическое превосходство',
      'Характер и честность',
      'Разнообразие и доступность',
      'Служение обществу',
    ],
    notableFacts: [
      'Крайне высокая селективность (приём ~3–4%)',
      'Need-blind для иностранцев + покрытие полной нужды',
      'Старейший университет США (основан в 1636)',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'SAT ~1550, GPA ~4.0 (rigor очень высокий), '
            'международная олимпиада по математике',
        whatWorked: 'Сочетание высочайших баллов, исследовательского '
            'проекта и эссе с ярким личным голосом.',
        outcome: 'Зачислен(а), финпомощь покрыла почти всю стоимость',
      ),
      AdmittedCase(
        profileSummary: 'SAT ~1520, GPA ~3.95, основатель социального '
            'стартапа в своём городе',
        whatWorked: 'Реальное влияние внеучебного проекта и сильные '
            'рекомендации, подтверждающие характер.',
        outcome: 'Поступил(а) на Liberal Arts с полным покрытием нужды',
      ),
      AdmittedCase(
        profileSummary: 'SAT ~1560, призёр по биологии, '
            'публикация в школьном научном журнале',
        whatWorked: 'Глубокая специализация в науке плюс лидерство '
            'в школьном научном сообществе.',
        outcome: 'Зачислен(а) на Sciences',
      ),
    ],
  ),
  University(
    slug: 'mit',
    name: 'MIT',
    country: 'США',
    scope: UniScope.world,
    languages: ['English'],
    programs: ['Engineering', 'CS', 'Sciences'],
    ranking: 1,
    tuition: r'~$60k (need-blind + full-need)',
    finAidNotes: 'Need-blind + full-need для всех, включая иностранцев.',
    isNeedBlindFullNeed: true,
    cdsUniversityKey: 'MIT',
    acceptanceRate: 0.046,
    acceptanceRateYear: 2025,
    website: 'https://www.mit.edu',
    mission: 'Развивать знания и готовить студентов в науке, технологиях и '
        'других областях, чтобы они служили нации и миру.',
    values: [
      'Наука и технологии на благо мира',
      'Сила характера',
      'Равный доступ к образованию',
      'Решение реальных задач',
    ],
    notableFacts: [
      'Приём ~4–5%, очень высокая селективность',
      'Need-blind + full-need для всех, включая иностранцев',
      '>70% зачисленных — выпускники гос. школ',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'SAT ~1560, GPA ~4.0, призёр олимпиады '
            'по информатике, робототехнический проект',
        whatWorked: 'Реальные инженерные проекты и доказанная страсть '
            'к математике и науке, а не только баллы.',
        outcome: 'Зачислен(а) на Engineering, full-need покрытие',
      ),
      AdmittedCase(
        profileSummary: 'SAT ~1540, GPA ~3.98, исследование с '
            'университетской лабораторией, публикация',
        whatWorked: 'Реальный научный вклад и способность решать '
            'нетривиальные задачи, подтверждённая рекомендациями.',
        outcome: 'Поступил(а) на CS',
      ),
    ],
  ),
  University(
    slug: 'umich',
    name: 'University of Michigan',
    country: 'США',
    scope: UniScope.world,
    languages: ['English'],
    programs: ['Engineering', 'Business', 'CS'],
    ranking: 21,
    tuition: r'~$60k для иностранцев',
    finAidNotes: 'Need-aware для иностранцев; помощь ограничена.',
    cdsUniversityKey: 'University of Michigan',
    acceptanceRate: 0.156,
    acceptanceRateYear: 2024,
    website: 'https://umich.edu',
    mission: 'Служить народу через развитие знаний и воспитание лидеров и '
        'граждан, которые бросают вызов настоящему и обогащают будущее.',
    values: [
      'Лидерство и гражданственность',
      'Превосходство в исследованиях',
      'Разнообразие и инклюзивность',
      'Служение обществу',
    ],
    notableFacts: [
      'Приём ~16% (класс 2028), растущая селективность',
      'Сильные программы инженерии и бизнеса',
      'Крупный исследовательский публичный университет',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'SAT ~1480, GPA ~3.9, лидер школьного '
            'инженерного клуба',
        whatWorked: 'Высокий академический rigor и лидерская роль во '
            'внеучебной инженерной деятельности.',
        outcome: 'Поступил(а) на Engineering (need-aware, помощь ограничена)',
      ),
      AdmittedCase(
        profileSummary: 'SAT ~1450, GPA ~3.85, стажировка в '
            'местной компании',
        whatWorked: 'Реальный опыт работы и сильное эссе про '
            'карьерные цели в бизнесе.',
        outcome: 'Зачислен(а) на Business',
      ),
    ],
  ),
  University(
    slug: 'asu',
    name: 'Arizona State University',
    country: 'США',
    scope: UniScope.world,
    languages: ['English'],
    programs: ['Engineering', 'Business', 'Design'],
    tuition: r'~$33k + merit-стипендии',
    finAidNotes: 'Высокий процент приёма; merit-скидки для сильных '
        'абитуриентов.',
    cdsUniversityKey: 'Arizona State University',
    acceptanceRate: 0.898,
    acceptanceRateYear: 2024,
    website: 'https://www.asu.edu',
    mission: 'Измерять успех не по тому, кого мы исключаем, а по тому, кого '
        'мы включаем и как они преуспевают — доступность и влияние на '
        'общество (Charter ASU).',
    values: [
      'Доступность образования',
      'Инновации (1-е место в США по версии рейтингов)',
      'Социальная польза и инклюзия',
      'Предпринимательство и устойчивость',
    ],
    notableFacts: [
      'Очень высокий приём (~90%), но сильные merit-скидки',
      'Многократно признан №1 в США по инновациям',
      'Один из крупнейших и самых доступных вузов США',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'SAT ~1280, GPA ~3.7, участие в '
            'школьном дизайн-проекте',
        whatWorked: 'Уверенный балл выше среднего по приёму и '
            'портфолио — основа для merit-скидки.',
        outcome: 'Поступил(а) на Design с merit-стипендией',
      ),
      AdmittedCase(
        profileSummary: 'SAT ~1200, GPA ~3.5, лидер школьного клуба',
        whatWorked: 'Соответствие профилю приёма и внеучебная '
            'активность для частичной стипендии.',
        outcome: 'Зачислен(а) на Business с частичной merit-скидкой',
      ),
    ],
  ),
  University(
    slug: 'uva-nl',
    name: 'University of Amsterdam',
    country: 'Нидерланды',
    scope: UniScope.world,
    languages: ['English'],
    programs: ['Business', 'AI', 'Social Sciences'],
    tuition: '€9–15k/год (не-ЕС)',
    finAidNotes: 'Studielink, мотивационное письмо; numerus fixus на части '
        'программ.',
    cdsUniversityKey: 'University of Amsterdam (orientation)',
    acceptanceRate: 0.5,
    acceptanceRateYear: 2024,
    isAcceptanceRateEstimate: true,
    website: 'https://www.uva.nl/en',
    mission: 'Государственный исследовательский университет в центре '
        'Нидерландов с акцентом на академическое качество и международную '
        'открытость.',
    values: [
      'Академическая свобода',
      'Интернациональность',
      'Исследовательское превосходство',
      'Открытость и разнообразие',
    ],
    notableFacts: [
      'Общий приём ~50%, но на программах с numerus fixus — выше отбор',
      'Обучение на английском по ряду программ',
      'Поступление через Studielink + мотивационное письмо',
    ],
    admittedCases: [
      AdmittedCase(
        profileSummary: 'Аттестат с сильной математикой, IELTS 6.5, '
            'мотивационное письмо про AI',
        whatWorked: 'Соответствие предметным требованиям программы и '
            'чёткое мотивационное письмо.',
        outcome: 'Зачислен(а) на AI (программа с numerus fixus)',
      ),
      AdmittedCase(
        profileSummary: 'Хороший аттестат, IELTS 7.0, '
            'опыт волонтёрства за рубежом',
        whatWorked: 'Международный опыт и сильное эссе для '
            'социального направления.',
        outcome: 'Поступил(а) на Social Sciences',
      ),
    ],
  ),
];
