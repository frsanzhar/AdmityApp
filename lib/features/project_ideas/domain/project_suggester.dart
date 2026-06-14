import 'package:admity/features/project_ideas/data/project_ideas_seed.dart';
import 'package:admity/features/project_ideas/domain/project_idea.dart';

/// Suggests projects that best fit a student's RIASEC `code`.
abstract final class ProjectSuggester {
  static List<ProjectIdea> suggest(String code, {int limit = 4}) {
    final letters = code.split('');
    int overlap(ProjectIdea idea) =>
        idea.riasecCodes.where(letters.contains).length;

    final ranked = kProjectIdeasSeed.toList()
      ..sort((a, b) {
        final cmp = overlap(b).compareTo(overlap(a));
        return cmp != 0
            ? cmp
            : kProjectIdeasSeed.indexOf(a).compareTo(kProjectIdeasSeed.indexOf(b));
      });
    return ranked.take(limit).toList();
  }
}
