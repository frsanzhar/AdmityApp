import 'package:admity/features/essay_review/domain/essay_models.dart';

/// A deterministic, offline heuristic scorer for the computable rubric
/// criteria (word economy, cliché avoidance, concreteness, show-don't-tell,
/// structure). Deep, context-aware feedback (voice, reflection, prompt fit) is
/// produced online by the Eraly editor — this never rewrites the essay.
abstract final class LocalRubricScorer {
  static const List<String> _cliches = [
    'с самого детства',
    'с детства я мечтал',
    'всегда мечтал',
    'изменить мир',
    'изменить весь мир',
    'страсть к',
    'тяжёлый труд',
    'вне зоны комфорта',
    'лидерские качества',
    'passion for',
    'since i was a child',
    'always dreamed',
    'change the world',
    'outside my comfort zone',
    'hard work pays off',
  ];

  static const List<String> _tellingWords = [
    'очень важно',
    'я понял что',
    'это было удивительно',
    'мне было интересно',
    'amazing',
    'incredible',
    'interesting',
    'very important',
    'i realized that',
  ];

  static EssayFeedback score(String text, EssayKind kind) {
    final lower = text.toLowerCase();
    final words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
    final wordCount = words.length;
    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .length;

    final foundCliches =
        _cliches.where(lower.contains).toList(growable: false);
    final tellingHits = _tellingWords.where(lower.contains).length;
    final digitCount = RegExp(r'\d').allMatches(text).length;
    final quoteCount = RegExp('[«»"“”]').allMatches(text).length;
    final per100 = wordCount == 0 ? 0.0 : (digitCount + quoteCount) / wordCount * 100;

    final scores = <RubricScore>[
      _wordEconomy(wordCount, kind),
      _clicheAvoidance(foundCliches),
      _concreteness(per100),
      _showDontTell(tellingHits, wordCount),
      _structure(paragraphs, wordCount),
    ];

    final strengths = <String>[];
    final suggestions = <String>[];

    if (foundCliches.isEmpty) {
      strengths.add('Нет очевидных клише — хорошо.');
    } else {
      suggestions.add(
        'Замени клише на конкретику: ${foundCliches.join(', ')}.',
      );
    }
    if (per100 >= 1) {
      strengths.add('Есть конкретные детали (цифры/прямая речь).');
    } else {
      suggestions.add(
        'Добавь одну живую сцену: имя, место, момент, прямую речь.',
      );
    }
    if (tellingHits > 0) {
      suggestions.add(
        'Меньше «рассказывания» чувств — покажи их через действие.',
      );
    }
    if (paragraphs < 3) {
      suggestions.add(
        'Раздели на абзацы: зацепка → сцена → рефлексия → финал.',
      );
    }
    final overLimit = wordCount > kind.wordLimit;
    if (overLimit) {
      suggestions.add(
        'Сократи примерно на ${wordCount - kind.wordLimit} слов '
        '(лимит ${kind.wordLimit}).',
      );
    }

    return EssayFeedback(
      scores: scores,
      wordCount: wordCount,
      strengths: strengths,
      suggestions: suggestions,
      overall: 'Это локальная проверка по измеримым критериям. '
          'Глубокий разбор голоса, рефлексии и соответствия промпту даст '
          'Ералы онлайн — и он не перепишет эссе за тебя.',
    );
  }

  static RubricScore _wordEconomy(int wordCount, EssayKind kind) {
    if (wordCount == 0) {
      return const RubricScore(
        criterion: RubricCriterion.wordEconomy,
        score: 2,
        comment: 'Начни писать, чтобы оценить объём.',
      );
    }
    final ratio = wordCount / kind.wordLimit;
    final int s;
    final String c;
    if (ratio > 1.15) {
      s = 1;
      c = 'Сильный перебор по объёму — нужно резать.';
    } else if (ratio > 1.0) {
      s = 2;
      c = 'Лимит превышен — подсократи.';
    } else if (ratio >= 0.8) {
      s = 4;
      c = 'Объём в самый раз.';
    } else if (ratio >= 0.5) {
      s = 3;
      c = 'Можно раскрыть тему чуть полнее.';
    } else {
      s = 2;
      c = 'Слишком коротко — добавь сцену и рефлексию.';
    }
    return RubricScore(
      criterion: RubricCriterion.wordEconomy,
      score: s,
      comment: c,
    );
  }

  static RubricScore _clicheAvoidance(List<String> found) {
    final s = (4 - found.length).clamp(0, 4);
    return RubricScore(
      criterion: RubricCriterion.clicheAvoidance,
      score: s,
      comment: found.isEmpty
          ? 'Клише не найдены.'
          : 'Найдено клише: ${found.length}.',
    );
  }

  static RubricScore _concreteness(double per100) {
    final int s;
    if (per100 >= 2) {
      s = 4;
    } else if (per100 >= 1) {
      s = 3;
    } else if (per100 > 0) {
      s = 2;
    } else {
      s = 1;
    }
    return RubricScore(
      criterion: RubricCriterion.concreteness,
      score: s,
      comment: s >= 3
          ? 'Хорошая плотность конкретики.'
          : 'Мало конкретных деталей — добавь сцену.',
    );
  }

  static RubricScore _showDontTell(int tellingHits, int wordCount) {
    final s = (4 - tellingHits).clamp(0, 4);
    return RubricScore(
      criterion: RubricCriterion.showDontTell,
      score: s,
      comment: tellingHits == 0
          ? 'Похоже, ты показываешь, а не рассказываешь.'
          : 'Есть «рассказывание» чувств: $tellingHits.',
    );
  }

  static RubricScore _structure(int paragraphs, int wordCount) {
    if (wordCount == 0) {
      return const RubricScore(
        criterion: RubricCriterion.structure,
        score: 2,
        comment: 'Начни писать, чтобы оценить структуру.',
      );
    }
    final int s;
    if (paragraphs >= 3) {
      s = 4;
    } else if (paragraphs == 2) {
      s = 3;
    } else {
      s = 2;
    }
    return RubricScore(
      criterion: RubricCriterion.structure,
      score: s,
      comment: paragraphs >= 3
          ? 'Структура разбита на абзацы.'
          : 'Раздели текст на абзацы для ясной структуры.',
    );
  }
}
