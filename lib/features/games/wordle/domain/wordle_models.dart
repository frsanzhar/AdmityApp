/// Pure domain models for the "Слово дня" (Word of the day) Wordle game.
///
/// Russian five-letter words are used throughout. The letter `ё` is always
/// normalized to `е`, both in the dictionary and in player input.
library;

/// The color/feedback state of a single guessed letter, mirroring Wordle.
enum LetterState {
  /// Correct letter in the correct position (green / olive).
  correct,

  /// Letter exists in the target word but in a different position (yellow).
  present,

  /// Letter does not appear in the target word (grey).
  absent,

  /// No letter entered yet for this cell (the default empty tile).
  empty,
}

/// One evaluated letter: the [letter] itself plus its [state].
class EvaluatedLetter {
  /// Creates an evaluated letter with its [letter] and feedback [state].
  const EvaluatedLetter(this.letter, this.state);

  /// The single lowercase Russian character (or empty for blank tiles).
  final String letter;

  /// The feedback state used to color the tile and keyboard key.
  final LetterState state;
}

/// The full evaluation of a five-letter guess against the target word.
class GuessResult {
  /// Creates a guess result from the raw [word] and its per-letter [letters].
  const GuessResult({required this.word, required this.letters});

  /// The guessed word, lowercase and `ё`-normalized.
  final String word;

  /// The five evaluated letters, in order.
  final List<EvaluatedLetter> letters;

  /// Whether every letter is [LetterState.correct] (the word was solved).
  bool get isWin => letters.every((l) => l.state == LetterState.correct);
}

/// Evaluates a five-letter [guess] against [target] using real Wordle rules,
/// correctly handling duplicate letters.
///
/// Both inputs must already be lowercase, `ё`-normalized and of equal length.
/// The algorithm first marks exact matches, then resolves present/absent
/// letters against the pool of remaining (unmatched) target letters.
GuessResult evaluateGuess(String guess, String target) {
  final guessChars = guess.split('');
  final targetChars = target.split('');
  final length = guessChars.length;

  final states = List<LetterState>.filled(length, LetterState.absent);

  // Count of each unmatched target letter still available for "present".
  final remaining = <String, int>{};
  for (final c in targetChars) {
    remaining[c] = (remaining[c] ?? 0) + 1;
  }

  // First pass: exact-position matches consume from the remaining pool.
  for (var i = 0; i < length; i++) {
    if (guessChars[i] == targetChars[i]) {
      states[i] = LetterState.correct;
      remaining[guessChars[i]] = (remaining[guessChars[i]] ?? 0) - 1;
    }
  }

  // Second pass: present letters consume any leftover occurrences.
  for (var i = 0; i < length; i++) {
    if (states[i] == LetterState.correct) continue;
    final c = guessChars[i];
    if ((remaining[c] ?? 0) > 0) {
      states[i] = LetterState.present;
      remaining[c] = remaining[c]! - 1;
    }
  }

  return GuessResult(
    word: guess,
    letters: [
      for (var i = 0; i < length; i++) EvaluatedLetter(guessChars[i], states[i]),
    ],
  );
}

/// Normalizes a Russian string for Wordle: lowercased and `ё` → `е`.
String normalizeWord(String word) =>
    word.toLowerCase().replaceAll('ё', 'е').trim();
