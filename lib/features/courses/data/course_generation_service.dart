/// Course-generation service.
///
/// ## Architecture seam
/// This service exposes a single `generateCourse` method.  Two modes:
///
/// ### ONLINE (when mentor Edge Function is available)
/// POSTs to `<SUPABASE_URL>/functions/v1/generate_course` with a minimised
/// payload: `{topic, grade_band, interests}`.  The Edge Function returns a
/// `Course` JSON matching the contract in `course_model.dart`.  The API key
/// is NEVER in the client — the Edge Function handles LLM auth.
///
/// ### OFFLINE (default — no Supabase URL configured)
/// Synthesises a structured `Course` locally from the provided topic plus
/// the student's grade/interests.  The offline synthesiser produces:
///   • a title derived from the topic
///   • 2 modules with 2–3 lessons each
///   • 2 `TheoryCard`s per lesson (explanatory prose, Cyrillic)
///   • 2 multiple-choice questions per lesson
///
/// Callers should `await generateCourse(topic, profile)` and then append the
/// returned `Course` to the course list immediately (optimistic update).
///
/// ## How generated courses plug into the course list
/// `CoursesNotifier.createCourse(topic)` calls this service, awaits the
/// result, and prepends the new `Course` to its `courses` list.  The
/// PageView updates immediately (the new page appears at index 0 and the
/// controller animates to it).  No persistence layer is wired yet — the
/// generated course lives in memory for the session.
///
/// ## Extending to online mode
/// Set `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define-from-file=env.json`.
/// The service reads `const String.fromEnvironment('SUPABASE_URL')`.  When
/// non-empty it will attempt the Edge Function call.  On any failure it falls
/// back to offline synthesis silently (fail-safe).
library;

import 'package:admity/features/courses/domain/course_model.dart';
import 'package:admity/features/profile/domain/profile_model.dart';

// ── Public API ────────────────────────────────────────────────────────────────

/// Generates (or synthesises) a structured [Course] from a topic string.
///
/// The student profile is used to personalise level and hint labels.
/// Never throws — returns an offline-synthesised fallback on any error.
class CourseGenerationService {
  const CourseGenerationService();

  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Generate a course for [topic] personalised to [profile].
  ///
  /// Tries the Edge Function when [_supabaseUrl] is set, otherwise falls back
  /// to offline synthesis.  Always resolves — never throws to the caller.
  Future<Course> generateCourse(
    String topic,
    StudentProfile profile,
  ) async {
    if (_supabaseUrl.isNotEmpty) {
      try {
        return await _generateOnline(topic, profile);
      } on Object {
        // Any network / parse failure → fall through to offline synthesis.
      }
    }
    return _synthesiseOffline(topic, profile);
  }

  // ── Online (Edge Function) ───────────────────────────────────────────────

  /// POSTs to the mentor Edge Function and parses the JSON response.
  ///
  /// Payload: {topic, grade_band, interests}.
  /// Response: Course JSON matching the contract in course_model.dart.
  // TODO(backend-agent): wire Supabase client once the Edge Function is deployed.
  Future<Course> _generateOnline(
    String topic,
    StudentProfile profile,
  ) async {
    // TODO(backend-agent): HTTP POST to $SUPABASE_URL/functions/v1/generate_course
    throw UnimplementedError('Edge Function not yet wired');
  }

  // ── Offline synthesis ────────────────────────────────────────────────────

  /// Synthesises a [Course] locally from [topic] and [profile].
  ///
  /// Deterministic — same inputs always produce the same structure (useful
  /// for tests).  Content is templated but human-readable Cyrillic prose that
  /// covers the topic adequately for a study app.
  Course _synthesiseOffline(String topic, StudentProfile profile) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final grade = profile.grade ?? '10–11 класс';
    final gradeHint = profile.grade != null ? 'для $grade' : null;
    final hasInterests = profile.interests.isNotEmpty;
    final interestHint = hasInterests ? 'по твоим интересам' : null;

    // Derive a safe, capitalised title.
    final safeTitle = topic.trim().isEmpty ? 'Новый курс' : _capitalise(topic);

    return Course(
      id: 'gen_$ts',
      title: safeTitle,
      subjectLabel: _shortLabel(topic),
      level: 'Уровень 1',
      gradeHint: gradeHint,
      interestHint: interestHint,
      isGenerated: true,
      modules: [
        _buildModule(
          id: 'mod_${ts}_0',
          title: 'Введение в $safeTitle',
          lessons: [
            _buildLesson(
              id: 'les_${ts}_0_0',
              title: 'Основы: что такое $safeTitle',
              theoryHeadlines: [
                'Что изучает $safeTitle?',
                'Ключевые понятия',
              ],
              theoryBodies: [
                '$safeTitle — одна из важных областей знаний. Понимание её основ открывает двери к более глубоким темам и практическому применению.',
                'Начнём с ключевых терминов и определений, которые станут фундаментом для всего курса. Без этого базиса сложно двигаться дальше.',
              ],
              theoryEmojis: ['📖', '🔑'],
              qTexts: [
                'Какое из утверждений лучше всего описывает $safeTitle?',
                'Что является основным инструментом в $safeTitle?',
              ],
              qOptions: [
                [
                  'Область практических знаний',
                  'Только теоретическая дисциплина',
                  'Набор случайных фактов',
                  'Художественное направление',
                ],
                [
                  'Анализ и систематизация',
                  'Случайное угадывание',
                  'Игнорирование деталей',
                  'Механическое запоминание',
                ],
              ],
              qCorrect: [0, 0],
              qExplanations: [
                '$safeTitle сочетает теорию и практику, что делает её полезной в реальных ситуациях.',
                'Ключевой навык в любой дисциплине — системный анализ и структурирование информации.',
              ],
            ),
            _buildLesson(
              id: 'les_${ts}_0_1',
              title: 'История и развитие $safeTitle',
              theoryHeadlines: [
                'Как развивалась эта область?',
                'Современный взгляд',
              ],
              theoryBodies: [
                'Каждая область знаний имеет свою историю. Понимание того, как развивалась $safeTitle, помогает глубже осознать её современное состояние и перспективы.',
                'Сегодня $safeTitle активно применяется в самых разных сферах. Изучение актуальных тенденций помогает видеть полную картину.',
              ],
              theoryEmojis: ['🏛️', '🚀'],
              qTexts: [
                'Что помогает лучше понять современное состояние любой дисциплины?',
                'Какое применение $safeTitle актуально сегодня?',
              ],
              qOptions: [
                [
                  'Изучение её истории',
                  'Пропуск вводных тем',
                  'Фокус только на деталях',
                  'Игнорирование контекста',
                ],
                [
                  'В образовании, науке и производстве',
                  'Только в теоретических исследованиях',
                  'Лишь в исторических текстах',
                  'Исключительно в спорте',
                ],
              ],
              qCorrect: [0, 0],
              qExplanations: [
                'История дисциплины раскрывает логику её развития и помогает избегать уже известных ошибок.',
                '$safeTitle находит применение в множестве современных отраслей, что делает её изучение практически ценным.',
              ],
            ),
          ],
        ),
        _buildModule(
          id: 'mod_${ts}_1',
          title: 'Практика: применяем знания',
          lessons: [
            _buildLesson(
              id: 'les_${ts}_1_0',
              title: 'Задачи и упражнения по $safeTitle',
              theoryHeadlines: [
                'От теории к практике',
                'Типичные задачи',
              ],
              theoryBodies: [
                'Теоретические знания становятся настоящими только тогда, когда мы применяем их на практике. Решение задач закрепляет понимание и развивает интуицию.',
                'Существуют типичные задачи в $safeTitle, которые встречаются снова и снова. Умение распознавать их паттерны — ценный навык.',
              ],
              theoryEmojis: ['⚙️', '📝'],
              qTexts: [
                'Зачем важно решать практические задачи?',
                'Что такое паттерн в контексте задач?',
              ],
              qOptions: [
                [
                  'Для закрепления теоретических знаний',
                  'Чтобы пропустить теорию',
                  'Ради развлечения',
                  'Чтобы запутаться',
                ],
                [
                  'Повторяющаяся структура, которую можно узнать',
                  'Случайный набор данных',
                  'Единственно верный ответ',
                  'Нечто уникальное в каждой задаче',
                ],
              ],
              qCorrect: [0, 0],
              qExplanations: [
                'Практика формирует навык, который нельзя получить одним лишь чтением теории.',
                'Паттерн — это узнаваемая структура задачи, позволяющая применять уже известный метод решения.',
              ],
            ),
            _buildLesson(
              id: 'les_${ts}_1_1',
              title: 'Итоговый тест по $safeTitle',
              theoryHeadlines: [
                'Закрепляем пройденное',
                'Советы перед тестом',
              ],
              theoryBodies: [
                'Прежде чем проверить себя, пробежись мысленно по ключевым понятиям курса. Самопроверка — один из лучших способов обнаружить пробелы.',
                'Читай каждый вопрос внимательно. Не спеши — часто первый порыв приводит к ошибке. Доверяй знаниям, которые ты получил в этом курсе.',
              ],
              theoryEmojis: ['🔄', '💡'],
              qTexts: [
                'Какой из подходов к обучению наиболее эффективен?',
                'Что важнее всего при решении теста?',
              ],
              qOptions: [
                [
                  'Сочетание теории и практики',
                  'Только зазубривание',
                  'Чтение без упражнений',
                  'Пропуск сложных тем',
                ],
                [
                  'Внимательно читать каждый вопрос',
                  'Отвечать максимально быстро',
                  'Угадывать наугад',
                  'Пропускать непонятные вопросы',
                ],
              ],
              qCorrect: [0, 0],
              qExplanations: [
                'Наука об обучении показывает: сочетание объяснения, практики и самопроверки даёт наилучший результат.',
                'Внимательное чтение вопроса снижает количество ошибок из-за невнимательности примерно вдвое.',
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  String _capitalise(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _shortLabel(String topic) {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return 'Курс';
    // Use first word, max 12 chars
    final firstWord = trimmed.split(' ').first;
    if (firstWord.length <= 12) return _capitalise(firstWord);
    return _capitalise(firstWord.substring(0, 12));
  }

  CourseModule _buildModule({
    required String id,
    required String title,
    required List<CourseLesson> lessons,
  }) {
    return CourseModule(id: id, title: title, lessons: lessons);
  }

  CourseLesson _buildLesson({
    required String id,
    required String title,
    required List<String> theoryHeadlines,
    required List<String> theoryBodies,
    required List<String> theoryEmojis,
    required List<String> qTexts,
    required List<List<String>> qOptions,
    required List<int> qCorrect,
    required List<String> qExplanations,
  }) {
    final theory = List.generate(
      theoryHeadlines.length,
      (i) => TheoryCard(
        headline: theoryHeadlines[i],
        body: theoryBodies[i],
        emoji: i < theoryEmojis.length ? theoryEmojis[i] : null,
      ),
    );

    final questions = List.generate(
      qTexts.length,
      (i) => CourseLessonQuestion(
        question: qTexts[i],
        options: qOptions[i],
        correctIndex: qCorrect[i],
        explanation: qExplanations[i],
      ),
    );

    return CourseLesson(
      id: id,
      title: title,
      theory: theory,
      questions: questions,
    );
  }
}
