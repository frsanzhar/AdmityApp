import 'dart:async';

import 'package:admity/core/theme/app_durations.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/games/wordle/domain/wordle_models.dart';
import 'package:admity/features/games/wordle/presentation/wordle_providers.dart';
import 'package:admity/shared/widgets/gamification_badges.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Russian on-screen keyboard rows (йцукен layout).
const List<String> _kbRows = <String>[
  'йцукенгшщзхъ',
  'фывапролджэ',
  'ячсмитьбю',
];

/// "Слово дня" — the daily Russian Wordle puzzle screen.
class WordleScreen extends ConsumerStatefulWidget {
  /// Creates the Wordle screen.
  const WordleScreen({super.key});

  @override
  ConsumerState<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends ConsumerState<WordleScreen> {
  WordlePhase? _lastPhase;

  void _maybeShowResult(WordleState state) {
    if (_lastPhase == WordlePhase.playing &&
        state.phase != WordlePhase.playing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_showResultDialog(context, ref));
      });
    }
    _lastPhase = state.phase;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordleProvider);
    _lastPhase ??= state.phase;
    _maybeShowResult(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Слово дня'),
        actions: [
          if (!state.isPlaying)
            IconButton(
              tooltip: 'Статистика',
              icon: const Icon(Icons.bar_chart_rounded),
              onPressed: () => unawaited(_showResultDialog(context, ref)),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  child: _WordleGrid(state: state),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                0,
                AppSpacing.xs,
                AppSpacing.sm,
              ),
              child: _Keyboard(
                states: state.keyboardStates,
                enabled: state.isPlaying,
                onKey: (k) {
                  unawaited(HapticFeedback.selectionClick());
                  ref.read(wordleProvider.notifier).addLetter(k);
                },
                onBackspace: () {
                  unawaited(HapticFeedback.selectionClick());
                  ref.read(wordleProvider.notifier).removeLetter();
                },
                onEnter: () {
                  unawaited(HapticFeedback.lightImpact());
                  ref.read(wordleProvider.notifier).submit();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Per-column delay used to stagger the tile flip reveal on submit.
const Duration _kFlipStagger = Duration(milliseconds: 90);

/// The 6x5 grid of letter tiles.
class _WordleGrid extends StatelessWidget {
  const _WordleGrid({required this.state});

  final WordleState state;

  @override
  Widget build(BuildContext context) {
    final lastRow = state.guesses.length - 1;
    final rows = <Widget>[];
    for (var r = 0; r < kWordleMaxGuesses; r++) {
      if (r < state.guesses.length) {
        // Only the most recently submitted row plays the flip reveal, so
        // re-builds of already-revealed rows stay still and performant.
        rows.add(
          _GuessRow(
            result: state.guesses[r],
            reveal: r == lastRow,
            win: r == lastRow && state.phase == WordlePhase.won,
          ),
        );
      } else if (r == state.activeRow) {
        rows.add(
          _InputRow(input: state.input, shakeKey: state.invalidShake),
        );
      } else {
        rows.add(const _EmptyRow());
      }
      if (r < kWordleMaxGuesses - 1) {
        rows.add(const SizedBox(height: AppSpacing.xs));
      }
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

/// An evaluated (submitted) row with colored, revealing tiles. When [reveal]
/// is set the tiles flip in column by column; a [win] row then pops with a
/// staggered bounce once the flips finish.
class _GuessRow extends StatelessWidget {
  const _GuessRow({
    required this.result,
    this.reveal = false,
    this.win = false,
  });

  final GuessResult result;

  /// Whether to play the staggered flip-in reveal for this row.
  final bool reveal;

  /// Whether this is the winning row (adds a celebratory bounce pop).
  final bool win;

  @override
  Widget build(BuildContext context) {
    final count = result.letters.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.only(
              right: i == count - 1 ? 0 : AppSpacing.xs,
            ),
            child: _buildTile(i, count),
          ),
      ],
    );
  }

  Widget _buildTile(int i, int count) {
    final tile = _Tile(
      letter: result.letters[i].letter,
      state: result.letters[i].state,
    );
    if (!reveal) return tile;

    final flipDelay = _kFlipStagger * i;
    var anim = tile.animate().flipV(
          begin: -0.5,
          end: 0,
          duration: AppDurations.medium,
          delay: flipDelay,
          curve: Curves.easeOut,
        );

    if (win) {
      // Bounce each tile after every flip has finished, left-to-right.
      final bounceDelay =
          _kFlipStagger * count + AppDurations.medium + _kFlipStagger * i;
      anim = anim
          .then(delay: bounceDelay)
          .scaleXY(
            begin: 1,
            end: 1.18,
            duration: AppDurations.fast,
            curve: Curves.easeOut,
          )
          .then()
          .scaleXY(
            end: 1,
            duration: AppDurations.fast,
            curve: Curves.easeIn,
          );
    }
    return anim;
  }
}

/// The currently-typed row (with shake on invalid submit).
class _InputRow extends StatelessWidget {
  const _InputRow({required this.input, required this.shakeKey});

  final String input;
  final int shakeKey;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < kWordleLength; i++)
          Padding(
            padding: EdgeInsets.only(
              right: i == kWordleLength - 1 ? 0 : AppSpacing.xs,
            ),
            child: _Tile(
              letter: i < input.length ? input[i] : '',
              state: LetterState.empty,
              filled: i < input.length,
            ),
          ),
      ],
    );
    // Re-key on each invalid submit so the shake animation replays.
    return Animate(
      key: ValueKey<int>(shakeKey),
      effects: shakeKey == 0
          ? const []
          : const [ShakeEffect(duration: AppDurations.medium, hz: 6)],
      child: row,
    );
  }
}

/// A blank, not-yet-reached row.
class _EmptyRow extends StatelessWidget {
  const _EmptyRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < kWordleLength; i++)
          Padding(
            padding: EdgeInsets.only(
              right: i == kWordleLength - 1 ? 0 : AppSpacing.xs,
            ),
            child: const _Tile(letter: '', state: LetterState.empty),
          ),
      ],
    );
  }
}

/// A single letter tile.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.letter,
    required this.state,
    this.filled = false,
  });

  final String letter;
  final LetterState state;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (Color bg, Color fg, Color border) = switch (state) {
      LetterState.correct => (tokens.success, Colors.white, tokens.success),
      LetterState.present => (tokens.warning, Colors.white, tokens.warning),
      LetterState.absent => (
          tokens.surfaceSunken,
          tokens.textMuted,
          tokens.surfaceSunken,
        ),
      LetterState.empty => (
          Colors.transparent,
          context.colors.onSurface,
          filled ? context.colors.outline : tokens.textMuted.withValues(
            alpha: 0.4,
          ),
        ),
    };

    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.brSm,
        border: Border.all(color: border, width: 2),
      ),
      child: Text(
        letter.toUpperCase(),
        style: context.text.headlineSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// The on-screen Russian keyboard with per-key coloring.
class _Keyboard extends StatelessWidget {
  const _Keyboard({
    required this.states,
    required this.enabled,
    required this.onKey,
    required this.onBackspace,
    required this.onEnter,
  });

  final Map<String, LetterState> states;
  final bool enabled;
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < _kbRows.length; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (r == _kbRows.length - 1)
                  _ActionKey(
                    label: 'ВВОД',
                    onTap: enabled ? onEnter : null,
                  ),
                for (final ch in _kbRows[r].split(''))
                  _LetterKey(
                    letter: ch,
                    state: states[ch] ?? LetterState.empty,
                    onTap: enabled ? () => onKey(ch) : null,
                  ),
                if (r == _kbRows.length - 1)
                  _ActionKey(
                    icon: Icons.backspace_outlined,
                    onTap: enabled ? onBackspace : null,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A single letter key, colored by its best-known [state].
class _LetterKey extends StatelessWidget {
  const _LetterKey({
    required this.letter,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final LetterState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (Color bg, Color fg) = switch (state) {
      LetterState.correct => (tokens.success, Colors.white),
      LetterState.present => (tokens.warning, Colors.white),
      LetterState.absent => (tokens.surfaceSunken, tokens.textMuted),
      LetterState.empty => (
          tokens.surfaceRaised,
          context.colors.onSurface,
        ),
    };
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: _KeyButton(
          onTap: onTap,
          color: bg,
          child: AnimatedDefaultTextStyle(
            duration: AppDurations.medium,
            curve: Curves.easeOut,
            style: context.text.titleMedium!.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
            child: Text(letter.toUpperCase()),
          ),
        ),
      ),
    );
  }
}

/// A wider action key (Enter / Backspace).
class _ActionKey extends StatelessWidget {
  const _ActionKey({this.label, this.icon, this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: _KeyButton(
          onTap: onTap,
          color: context.tokens.surfaceSunken,
          child: icon != null
              ? Icon(icon, size: 20, color: context.colors.onSurface)
              : Text(
                  label ?? '',
                  style: context.text.labelLarge?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

/// The tappable surface shared by all keyboard keys. The fill color tweens
/// smoothly (via [AnimatedContainer]) so a key easing into its solved state
/// fades rather than snaps.
class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.child,
    required this.color,
    required this.onTap,
  });

  final Widget child;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: AppRadii.brSm,
      child: InkWell(
        borderRadius: AppRadii.brSm,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: Curves.easeOut,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadii.brSm,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Shows the win/lose dialog with stats, streak and an emoji-grid share.
Future<void> _showResultDialog(BuildContext context, WidgetRef ref) {
  final state = ref.read(wordleProvider);
  final stats = state.stats;
  final won = state.phase == WordlePhase.won;

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: context.tokens.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brLg),
        title: _ResultTitle(won: won),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!won)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Загаданное слово: ${state.target.toUpperCase()}',
                  style: context.text.bodyMedium,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(value: '${stats.played}', label: 'Игр'),
                _Stat(value: '${stats.winRate}%', label: 'Побед'),
                _Stat(value: '${stats.bestStreak}', label: 'Рекорд'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: won
                  ? StreakBadge(days: stats.currentStreak)
                      .animate()
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1, 1),
                        duration: AppDurations.medium,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: AppDurations.fast)
                  : StreakBadge(days: stats.currentStreak),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Поделиться',
              icon: Icons.ios_share_rounded,
              onPressed: () {
                unawaited(
                  Clipboard.setData(
                    ClipboardData(
                      text: ref.read(wordleProvider.notifier).shareText(),
                    ),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Результат скопирован'),
                    duration: AppDurations.slow,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      );
    },
  );
}

/// The result-dialog title row: an icon plus the verdict. On a win the trophy
/// pops with an elastic scale and a shimmer flourish sweeps across the text.
class _ResultTitle extends StatelessWidget {
  const _ResultTitle({required this.won});

  final bool won;

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(
      won ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied,
      color: won ? context.tokens.success : context.tokens.textMuted,
    );
    Widget title = Text(won ? 'Отгадано!' : 'Не вышло');

    if (won) {
      icon = icon
          .animate()
          .scale(
            begin: const Offset(0.4, 0.4),
            end: const Offset(1, 1),
            duration: AppDurations.celebrate,
            curve: Curves.elasticOut,
          )
          .shimmer(
            duration: AppDurations.celebrate,
            color: context.tokens.xp,
          );
      title = title.animate().fadeIn(duration: AppDurations.medium).shimmer(
            delay: AppDurations.fast,
            duration: AppDurations.celebrate,
            color: context.tokens.success,
          );
    }

    return Row(
      children: [
        icon,
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: title),
      ],
    );
  }
}

/// A small labeled stat cell used inside the result dialog.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: context.tokens.textMuted,
          ),
        ),
      ],
    );
  }
}
