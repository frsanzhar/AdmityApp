import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/quotes/data/quotes_seed.dart';
import 'package:admity/features/quotes/domain/quote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Computes the 1-based day-of-year (1..366) for the given [date].
int _dayOfYear(DateTime date) {
  final startOfYear = DateTime(date.year);
  final today = DateTime(date.year, date.month, date.day);
  return today.difference(startOfYear).inDays + 1;
}

/// The single [Quote] of the current calendar day.
///
/// Selection is deterministic: the day-of-year index (modulo the pool length)
/// chooses the quote, so the value is stable within a day and rotates daily.
final quoteOfDayProvider = Provider<Quote>((ref) {
  final now = DateTime.now();
  final index = (_dayOfYear(now) - 1) % kQuotesSeed.length;
  return kQuotesSeed[index];
});

/// Stores the student's favorited quotes (persisted under `fav_quotes`).
///
/// A quote is identified by its [Quote.text]; the full quote is kept so the
/// favorites list survives changes to the seed pool.
class FavoriteQuotesController extends Notifier<List<Quote>> {
  static const _key = 'fav_quotes';

  @override
  List<Quote> build() {
    final list = ref.read(localStoreProvider).readList(_key);
    if (list == null) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Quote.fromJson)
        .toList(growable: false);
  }

  /// Whether [quote] is currently favorited.
  bool isFavorite(Quote quote) =>
      state.any((q) => q.text == quote.text);

  /// Adds or removes [quote] from favorites and returns the new state.
  void toggle(Quote quote) {
    if (isFavorite(quote)) {
      state = state
          .where((q) => q.text != quote.text)
          .toList(growable: false);
    } else {
      state = [...state, quote];
    }
    _persist();
  }

  void _persist() => ref
      .read(localStoreProvider)
      .put(_key, state.map((q) => q.toJson()).toList(growable: false));
}

/// Provides the student's favorite quotes.
final favoriteQuotesProvider =
    NotifierProvider<FavoriteQuotesController, List<Quote>>(
  FavoriteQuotesController.new,
);
