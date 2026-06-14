import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/universities/data/universities_seed.dart';
import 'package:admity/features/universities/domain/university.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Maximum number of clues revealed for a single university round.
const int kGuessUniMaxClues = 4;

/// Points awarded when the very first clue is enough to guess correctly. Each
/// extra clue used subtracts one point; a wrong answer scores zero.
const int kGuessUniMaxRoundScore = kGuessUniMaxClues;

/// A single progressively-revealed hint about the target university.
@immutable
class GuessUniClue {
  /// Creates a clue with a short [label] and its revealed [value].
  const GuessUniClue({required this.label, required this.value});

  /// Short Russian caption shown before the value (e.g. «Страна»).
  final String label;

  /// The revealed hint text.
  final String value;
}

/// Persisted lifetime statistics for the «Угадай вуз» game.
@immutable
class GuessUniStats {
  /// Creates a stats snapshot.
  const GuessUniStats({
    this.bestScore = 0,
    this.bestStreak = 0,
    this.roundsPlayed = 0,
  });

  /// Restores stats from a stored JSON map, tolerating missing keys.
  factory GuessUniStats.fromJson(Map<String, dynamic> json) => GuessUniStats(
        bestScore: (json['best_score'] as num?)?.toInt() ?? 0,
        bestStreak: (json['best_streak'] as num?)?.toInt() ?? 0,
        roundsPlayed: (json['rounds_played'] as num?)?.toInt() ?? 0,
      );

  /// Highest single-round score ever earned.
  final int bestScore;

  /// Longest run of consecutive correct answers ever earned.
  final int bestStreak;

  /// Total number of rounds finished (used to rotate the target).
  final int roundsPlayed;

  /// Serializes the stats for [LocalStore].
  Map<String, dynamic> toJson() => {
        'best_score': bestScore,
        'best_streak': bestStreak,
        'rounds_played': roundsPlayed,
      };

  /// Returns a copy with the given fields replaced.
  GuessUniStats copyWith({
    int? bestScore,
    int? bestStreak,
    int? roundsPlayed,
  }) =>
      GuessUniStats(
        bestScore: bestScore ?? this.bestScore,
        bestStreak: bestStreak ?? this.bestStreak,
        roundsPlayed: roundsPlayed ?? this.roundsPlayed,
      );
}

/// Immutable view of the current «Угадай вуз» round.
@immutable
class GuessUniState {
  /// Creates a round state.
  const GuessUniState({
    required this.target,
    required this.options,
    required this.clues,
    required this.revealedClues,
    required this.stats,
    required this.currentStreak,
    this.selectedIndex,
  });

  /// The university the player must identify.
  final University target;

  /// Four answer choices (one of which is [target]).
  final List<University> options;

  /// All clues available for [target], in reveal order.
  final List<GuessUniClue> clues;

  /// How many of [clues] are currently visible (1.. [clues] length).
  final int revealedClues;

  /// Persisted lifetime statistics.
  final GuessUniStats stats;

  /// Consecutive correct answers in the current session.
  final int currentStreak;

  /// Index into [options] the player tapped, or `null` if not answered yet.
  final int? selectedIndex;

  /// Whether the player has committed to an answer this round.
  bool get answered => selectedIndex != null;

  /// Whether the committed answer matches [target].
  bool get isCorrect => answered && options[selectedIndex!].slug == target.slug;

  /// Whether more clues remain to reveal.
  bool get canRevealMore => revealedClues < clues.length;

  /// The score this round would earn for a correct answer right now.
  int get potentialScore =>
      (kGuessUniMaxRoundScore - (revealedClues - 1)).clamp(1, kGuessUniMaxClues);

  /// The score actually earned (0 unless answered correctly).
  int get earnedScore => isCorrect ? potentialScore : 0;

  /// Returns a copy with the given fields replaced.
  GuessUniState copyWith({
    University? target,
    List<University>? options,
    List<GuessUniClue>? clues,
    int? revealedClues,
    GuessUniStats? stats,
    int? currentStreak,
    int? selectedIndex,
  }) =>
      GuessUniState(
        target: target ?? this.target,
        options: options ?? this.options,
        clues: clues ?? this.clues,
        revealedClues: revealedClues ?? this.revealedClues,
        stats: stats ?? this.stats,
        currentStreak: currentStreak ?? this.currentStreak,
        selectedIndex: selectedIndex ?? this.selectedIndex,
      );
}

/// Drives the «Угадай вуз» guessing game: rotates the target deterministically,
/// builds clues + distractors, scores answers and persists best stats.
class GuessUniController extends Notifier<GuessUniState> {
  /// [LocalStore] key holding the persisted [GuessUniStats].
  static const String storageKey = 'guess_uni_stats';

  /// Universities already used this session, by [University.slug].
  final Set<String> _usedSlugs = {};

  @override
  GuessUniState build() {
    final stats = _loadStats();
    return _newRound(stats: stats, currentStreak: 0);
  }

  GuessUniStats _loadStats() {
    final json = ref.read(localStoreProvider).readJson(storageKey);
    return json == null ? const GuessUniStats() : GuessUniStats.fromJson(json);
  }

  void _saveStats(GuessUniStats stats) =>
      ref.read(localStoreProvider).put(storageKey, stats.toJson());

  /// Reveals one additional clue (no-op once all clues are shown).
  void revealMore() {
    if (!state.canRevealMore || state.answered) return;
    state = state.copyWith(revealedClues: state.revealedClues + 1);
  }

  /// Commits the player's choice at [index], scoring the round and persisting
  /// any new personal bests.
  void answer(int index) {
    if (state.answered) return;
    final correct = state.options[index].slug == state.target.slug;
    final earned = correct ? state.potentialScore : 0;
    final newStreak = correct ? state.currentStreak + 1 : 0;
    final newStats = state.stats.copyWith(
      bestScore:
          earned > state.stats.bestScore ? earned : state.stats.bestScore,
      bestStreak: newStreak > state.stats.bestStreak
          ? newStreak
          : state.stats.bestStreak,
    );
    _saveStats(newStats);
    state = state.copyWith(
      selectedIndex: index,
      stats: newStats,
      currentStreak: newStreak,
    );
  }

  /// Advances to the next round, counting the finished one and rotating the
  /// target deterministically (no randomness).
  void nextRound() {
    final played = state.stats.roundsPlayed + 1;
    final newStats = state.stats.copyWith(roundsPlayed: played);
    _saveStats(newStats);
    state = _newRound(stats: newStats, currentStreak: state.currentStreak);
  }

  /// Builds a fresh round. The target index rotates by rounds played plus the
  /// current calendar day, and skips universities already seen this session.
  GuessUniState _newRound({
    required GuessUniStats stats,
    required int currentStreak,
  }) {
    const pool = kUniversitiesSeed;
    final dayOfYear = _dayOfYear(DateTime.now());
    var index = (stats.roundsPlayed + dayOfYear) % pool.length;

    // Avoid repeats within the session until the pool is exhausted, then reset.
    if (_usedSlugs.length >= pool.length) _usedSlugs.clear();
    var guard = 0;
    while (_usedSlugs.contains(pool[index].slug) && guard < pool.length) {
      index = (index + 1) % pool.length;
      guard++;
    }
    final target = pool[index];
    _usedSlugs.add(target.slug);

    return GuessUniState(
      target: target,
      options: _buildOptions(target, index, pool),
      clues: _buildClues(target),
      revealedClues: 1,
      stats: stats,
      currentStreak: currentStreak,
    );
  }

  /// Picks three deterministic distractors (preferring the same scope) and
  /// places the target into a stable, non-random slot.
  List<University> _buildOptions(
    University target,
    int targetIndex,
    List<University> pool,
  ) {
    final sameScope = <University>[];
    final otherScope = <University>[];
    for (final u in pool) {
      if (u.slug == target.slug) continue;
      (u.scope == target.scope ? sameScope : otherScope).add(u);
    }
    final ordered = [...sameScope, ...otherScope];

    final distractors = <University>[];
    var step = targetIndex % (ordered.isEmpty ? 1 : ordered.length);
    while (distractors.length < 3 && distractors.length < ordered.length) {
      final candidate = ordered[step % ordered.length];
      if (!distractors.any((d) => d.slug == candidate.slug)) {
        distractors.add(candidate);
      }
      step++;
    }

    final options = [target, ...distractors];
    // Deterministic slot for the correct answer based on the target index.
    final correctSlot = targetIndex % options.length;
    return [...options]
      ..removeAt(0)
      ..insert(correctSlot, target);
  }

  /// Builds the ordered clue list using only real [University] fields.
  List<GuessUniClue> _buildClues(University u) {
    final clues = <GuessUniClue>[
      GuessUniClue(
        label: 'Где находится',
        value: '${u.country} · '
            '${u.scope == UniScope.kz ? 'Казахстан' : 'за рубежом'}',
      ),
      GuessUniClue(
        label: 'Язык обучения',
        value: u.languages.isEmpty ? 'Не указан' : u.languages.join(', '),
      ),
    ];

    if (u.ranking != null) {
      clues.add(
        GuessUniClue(label: 'Рейтинг', value: 'примерно #${u.ranking}'),
      );
    } else {
      clues.add(
        GuessUniClue(
          label: 'Отбор',
          value: u.scope == UniScope.kz
              ? 'Поступление по ЕНТ / гранту'
              : 'Конкурсный отбор',
        ),
      );
    }

    if (u.tuition != null && u.tuition!.trim().isNotEmpty) {
      clues.add(GuessUniClue(label: 'Стоимость', value: u.tuition!));
    } else if (u.finAidNotes != null && u.finAidNotes!.trim().isNotEmpty) {
      clues.add(GuessUniClue(label: 'Финпомощь', value: u.finAidNotes!));
    } else {
      clues.add(
        GuessUniClue(
          label: 'Программы',
          value: u.programs.isEmpty ? 'Разные направления' : u.programs.first,
        ),
      );
    }

    return clues.take(kGuessUniMaxClues).toList();
  }

  int _dayOfYear(DateTime date) =>
      date.difference(DateTime(date.year)).inDays + 1;
}

/// The «Угадай вуз» game provider.
final guessUniProvider =
    NotifierProvider<GuessUniController, GuessUniState>(GuessUniController.new);
