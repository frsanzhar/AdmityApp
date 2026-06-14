import 'package:flutter/foundation.dart';

/// A realistic, zero-budget project a student can do with their own hands to
/// strengthen an application and build skills.
@immutable
class ProjectIdea {
  const ProjectIdea({
    required this.title,
    required this.description,
    required this.riasecCodes,
    required this.effort,
  });

  final String title;
  final String description;

  /// RIASEC letters this project suits (e.g. ['I', 'S']).
  final List<String> riasecCodes;

  /// Short effort hint, e.g. "2–4 недели".
  final String effort;
}
