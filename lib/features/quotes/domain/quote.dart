import 'package:flutter/foundation.dart';

/// A short, immutable motivational quote shown as the "Цитата дня".
///
/// Quotes are either honestly attributed to a real public figure or are
/// original lines written for the app and attributed to "Admity". No quote is
/// ever falsely attributed to a real person.
@immutable
class Quote {
  /// Creates a quote with its [text], [author] and an optional [source].
  const Quote({
    required this.text,
    required this.author,
    this.source,
  });

  /// Restores a [Quote] from a stored JSON map.
  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        text: json['text'] as String? ?? '',
        author: json['author'] as String? ?? '',
        source: json['source'] as String?,
      );

  /// The quote body, in Russian.
  final String text;

  /// Who said or wrote the quote (a real figure, or "Admity").
  final String author;

  /// Optional context for the quote (work, speech, occasion).
  final String? source;

  /// Serializes this quote to a JSON-safe map.
  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
        if (source != null) 'source': source,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          other.text == text &&
          other.author == author &&
          other.source == source;

  @override
  int get hashCode => Object.hash(text, author, source);
}
