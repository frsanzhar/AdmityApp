import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/games/wordle/data/wordle_words.dart';
import 'package:admity/features/games/wordle/domain/wordle_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Maximum number of guesses allowed per daily puzzle.
const int kWordleMaxGuesses = 6;

/// Number of letters in every target word.
const int kWordleLength = 5;

/// Whether the current game is still in progress, won, or lost.
enum WordlePhase {
  /// The player can still enter guesses.
  playing,

  /// The player guessed the word.
  won,

  /// The player used all attempts without solving.
  lost,
}

/// Persisted aggregate statistics for "Слово дня".
class WordleStats {
  /// Creates a stats record.
  const WordleStats({
    this.played = 0,
    this.wins = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPlayedDay = -1,
    this.lastWonDay = -2,
  });

  /// Restores stats from a persisted JSON map.
  factory WordleStats.fromJson(Map<String, dynamic> json) => WordleStats(
        played: (json['played'] as num?)?.toInt() ?? 0,
        wins: (json['wins'] as num?)?.toInt() ?? 0,
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
        lastPlayedDay: (json['lastPlayedDay'] as num?)?.toInt() ?? -1,
        lastWonDay: (json['lastWonDay'] as num?)?.toInt() ?? -2,
      );

  /// Total number of daily puzzles completed (won or lost).
  final int played;

  /// Total number of puzzles solved.
  final int wins;

  /// Current consecutive-day win streak.
  final int currentStreak;

  /// Best win streak ever reached.
  final int bestStreak;

  /// Absolute day index of the most recently finished puzzle.
  final int lastPlayedDay;

  /// Absolute day index of the most recently won puzzle.
  final int lastWonDay;

  /// Win percentage in the range 0..100 (0 when nothing has been played).
  int get winRate => played == 0 ? 0 : ((wins / played) * 100).round();

  /// Serializes the stats to a JSON map for persistence.
  Map<String, dynamic> toJson() => {
        'played': played,
        'wins': wins,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastPlayedDay': lastPlayedDay,
        'lastWonDay': lastWonDay,
      };

  /// Returns a copy with the provided fields replaced.
  WordleStats copyWith({
    int? played,
    int? wins,
    int? currentStreak,
    int? bestStreak,
    int? lastPlayedDay,
    int? lastWonDay,
  }) =>
      WordleStats(
        played: played ?? this.played,
        wins: wins ?? this.wins,
        currentStreak: currentStreak ?? this.currentStreak,
        bestStreak: bestStreak ?? this.bestStreak,
        lastPlayedDay: lastPlayedDay ?? this.lastPlayedDay,
        lastWonDay: lastWonDay ?? this.lastWonDay,
      );
}

/// The full immutable state of the daily Wordle game.
class WordleState {
  /// Creates a Wordle game state.
  const WordleState({
    required this.target,
    required this.guesses,
    required this.input,
    required this.phase,
    required this.stats,
    this.invalidShake = 0,
  });

  /// The hidden target word for today (lowercase, `ё`-normalized).
  final String target;

  /// The submitted, evaluated guesses (oldest first).
  final List<GuessResult> guesses;

  /// The letters currently being typed for the active row.
  final String input;

  /// The current game phase.
  final WordlePhase phase;

  /// Persisted aggregate statistics.
  final WordleStats stats;

  /// Increments whenever an invalid submit happens, to trigger a shake.
  final int invalidShake;

  /// Whether the player can still type/submit.
  bool get isPlaying => phase == WordlePhase.playing;

  /// Index of the row currently being typed (equal to guess count).
  int get activeRow => guesses.length;

  /// Aggregated per-letter keyboard states (best state wins).
  Map<String, LetterState> get keyboardStates {
    final result = <String, LetterState>{};
    for (final guess in guesses) {
      for (final l in guess.letters) {
        final existing = result[l.letter];
        if (_rank(l.state) > _rank(existing)) {
          result[l.letter] = l.state;
        }
      }
    }
    return result;
  }

  static int _rank(LetterState? s) => switch (s) {
        LetterState.correct => 3,
        LetterState.present => 2,
        LetterState.absent => 1,
        _ => 0,
      };

  /// Returns a copy with the provided fields replaced.
  WordleState copyWith({
    String? target,
    List<GuessResult>? guesses,
    String? input,
    WordlePhase? phase,
    WordleStats? stats,
    int? invalidShake,
  }) =>
      WordleState(
        target: target ?? this.target,
        guesses: guesses ?? this.guesses,
        input: input ?? this.input,
        phase: phase ?? this.phase,
        stats: stats ?? this.stats,
        invalidShake: invalidShake ?? this.invalidShake,
      );
}

/// Returns the absolute day index (days since the Unix epoch, local time) for
/// the given [date]. Used both for the daily reset and the target selection.
int wordleDayIndex(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return local.difference(DateTime(1970)).inDays;
}

/// Picks today's deterministic target word from [kWordleWords] using the
/// calendar day-of-year so the word is stable for the whole day.
String wordleTargetFor(DateTime date) {
  final dayOfYear =
      date.difference(DateTime(date.year)).inDays + date.year * 366;
  final index = dayOfYear % kWordleWords.length;
  return normalizeWord(kWordleWords[index]);
}

/// The Wordle game controller. Holds today's puzzle, applies pure evaluation
/// logic and persists stats + streak via the local store, resetting the board
/// each new calendar day.
class WordleController extends Notifier<WordleState> {
  /// Storage key for the persisted [WordleStats].
  static const String statsKey = 'wordle_stats';

  @override
  WordleState build() {
    final now = DateTime.now();
    final stats = _loadStats();
    final today = wordleDayIndex(now);
    final alreadyDone = stats.lastPlayedDay == today;

    final phase = alreadyDone
        ? (stats.lastWonDay == today ? WordlePhase.won : WordlePhase.lost)
        : WordlePhase.playing;

    return WordleState(
      target: wordleTargetFor(now),
      guesses: const [],
      input: '',
      phase: phase,
      stats: stats,
    );
  }

  WordleStats _loadStats() {
    final json = ref.read(localStoreProvider).readJson(WordleController.statsKey);
    return json == null ? const WordleStats() : WordleStats.fromJson(json);
  }

  /// Appends [letter] to the current input if there is room.
  void addLetter(String letter) {
    if (!state.isPlaying) return;
    if (state.input.length >= kWordleLength) return;
    state = state.copyWith(input: state.input + normalizeWord(letter));
  }

  /// Removes the last typed letter from the current input.
  void removeLetter() {
    if (!state.isPlaying) return;
    if (state.input.isEmpty) return;
    state = state.copyWith(
      input: state.input.substring(0, state.input.length - 1),
    );
  }

  /// Submits the current input as a guess. No-op unless it is a valid, full
  /// five-letter word; otherwise triggers a shake.
  void submit() {
    if (!state.isPlaying) return;
    final guess = state.input;
    if (guess.length != kWordleLength || !kWordleWords.contains(guess)) {
      state = state.copyWith(invalidShake: state.invalidShake + 1);
      return;
    }

    final result = evaluateGuess(guess, state.target);
    final guesses = [...state.guesses, result];

    if (result.isWin) {
      _finish(guesses, won: true);
    } else if (guesses.length >= kWordleMaxGuesses) {
      _finish(guesses, won: false);
    } else {
      state = state.copyWith(guesses: guesses, input: '');
    }
  }

  void _finish(List<GuessResult> guesses, {required bool won}) {
    final today = wordleDayIndex(DateTime.now());
    final prev = state.stats;

    // Continue the streak only when yesterday's puzzle was also won.
    final continued = won && prev.lastWonDay == today - 1;
    final newStreak = won ? (continued ? prev.currentStreak + 1 : 1) : 0;

    final stats = prev.copyWith(
      played: prev.played + 1,
      wins: prev.wins + (won ? 1 : 0),
      currentStreak: newStreak,
      bestStreak: newStreak > prev.bestStreak ? newStreak : prev.bestStreak,
      lastPlayedDay: today,
      lastWonDay: won ? today : prev.lastWonDay,
    );

    ref.read(localStoreProvider).put(WordleController.statsKey, stats.toJson());

    state = state.copyWith(
      guesses: guesses,
      input: '',
      phase: won ? WordlePhase.won : WordlePhase.lost,
      stats: stats,
    );
  }

  /// Builds the shareable emoji grid for today's finished game.
  String shareText() {
    final tries = state.phase == WordlePhase.won
        ? '${state.guesses.length}/$kWordleMaxGuesses'
        : 'X/$kWordleMaxGuesses';
    final rows = state.guesses
        .map(
          (g) => g.letters
              .map(
                (l) => switch (l.state) {
                  LetterState.correct => '🟩',
                  LetterState.present => '🟨',
                  _ => '⬛',
                },
              )
              .join(),
        )
        .join('\n');
    return 'Слово дня $tries\n\n$rows';
  }
}

/// Provides the daily Wordle game controller.
final wordleProvider = NotifierProvider<WordleController, WordleState>(
  WordleController.new,
);
