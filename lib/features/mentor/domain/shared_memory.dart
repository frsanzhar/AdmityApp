/// Cross-assistant shared memory context sent with every LLM request.
///
/// When the student sends a message to any assistant, the client includes:
/// - The minimised student profile (no PII, GPA as a band).
/// - 2–3 line text summaries of what the OTHER assistants have recently
///   discussed, so each assistant is contextually aware of parallel
///   conversations.
///
/// Ералы is the primary coordinator; his summary is injected into every other
/// assistant's context.  Summaries are generated locally from the last few
/// messages — no extra LLM round-trip required.
///
/// Privacy: no PII is stored here.  Mirrors the same constraints as the
/// profile payload (no name/email/city; GPA only as a band).
class SharedMemory {
  const SharedMemory({this.summaries = const {}});

  /// Per-assistant recent-chat summaries.
  ///
  /// Key = the role name string (e.g. `'eraly'`), value = plain-text summary.
  final Map<String, String> summaries;

  /// Returns a copy of this object with [summary] set for [role].
  SharedMemory withSummary(String role, String summary) {
    final updated = Map<String, String>.from(summaries)..[role] = summary;
    return SharedMemory(summaries: updated);
  }

  /// Returns the summaries of all assistants EXCEPT [role].
  ///
  /// This is the context injected into the current assistant's request payload
  /// so it can reason about what the other assistants have been discussing.
  Map<String, String> othersFor(String role) {
    return Map<String, String>.fromEntries(
      summaries.entries.where((e) => e.key != role),
    );
  }

  /// Creates a copy with optional field overrides.
  SharedMemory copyWith({Map<String, String>? summaries}) =>
      SharedMemory(summaries: summaries ?? this.summaries);
}
