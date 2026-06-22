/// Detects ghostwriting requests in RU / KZ / EN.
///
/// Ералы is a coach — it NEVER writes or substantially drafts an essay.
/// This guard is a client-side pre-filter so we can deflect immediately
/// without an LLM round-trip.
class GhostwritingGuard {
  GhostwritingGuard._();

  // KZ: "жаз" = write; "жазып бер" = write for me
  // RU: "напиши", "пиши", "сделай за меня", "написать эссе"
  // EN: "write my essay", "write for me", "do my essay"
  static const _patterns = <_CaseInsensitiveContains>[
    // Kazakh — any form of "жаз" (write)
    _CaseInsensitiveContains('жаз'),
    // Russian
    _CaseInsensitiveContains('напиши'),
    _CaseInsensitiveContains('напишите'),
    _CaseInsensitiveContains('написать'),
    _CaseInsensitiveContains('пиши мне'),
    _CaseInsensitiveContains('пиши за'),
    _CaseInsensitiveContains('сделай за меня'),
    _CaseInsensitiveContains('составь эссе'),
    _CaseInsensitiveContains('составь текст'),
    _CaseInsensitiveContains('напиши эссе'),
    _CaseInsensitiveContains('напиши текст'),
    _CaseInsensitiveContains('напиши сочинение'),
    _CaseInsensitiveContains('написать эссе'),
    _CaseInsensitiveContains('написать сочинение'),
    // English
    _CaseInsensitiveContains('write my essay'),
    _CaseInsensitiveContains('write my personal'),
    _CaseInsensitiveContains('write for me'),
    _CaseInsensitiveContains('do my essay'),
    _CaseInsensitiveContains('write an essay'),
    _CaseInsensitiveContains('write a college'),
    _CaseInsensitiveContains('draft my'),
    _CaseInsensitiveContains('write me'),
  ];

  /// Returns true when [message] is a ghostwriting request.
  static bool isGhostwritingRequest(String message) {
    final lower = message.toLowerCase();
    for (final pattern in _patterns) {
      if (lower.contains(pattern.needle)) return true;
    }
    return false;
  }

  /// Returns the canned deflection message (in Russian, as the default UI
  /// language).
  static String get deflectionMessage =>
      'Я твой наставник, а не призрачный автор. '
      'Я помогу тебе развить идеи, структурировать мысли и улучшить черновик — '
      'но эссе должно быть твоим. Давай начнём: о чём ты хочешь написать?';
}

/// Simple needle holder used by the guard list.
class _CaseInsensitiveContains {
  const _CaseInsensitiveContains(this.needle);

  final String needle;
}
