import 'package:admity/features/gap_closer/domain/gap_task.dart';
import 'package:admity/shared/models/profile.dart';

/// Generates concrete, dated, achievable gap tasks from a [Profile] and an
/// optional career result. Each task links to an intensive where relevant.
abstract final class GapGenerator {
  static List<GapTask> generate({
    required Profile profile,
    required bool hasCareerResult,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    DateTime due(int days) => today.add(Duration(days: days));
    final tasks = <GapTask>[];

    if (!hasCareerResult) {
      tasks.add(
        GapTask(
          id: 'career-test',
          title: 'Пройти тест профориентации',
          description: 'RIASEC + Big Five помогут выбрать направление и вузы.',
          dueDate: due(3),
        ),
      );
    }

    if (profile.targetGeos.contains(TargetGeo.kz)) {
      tasks.add(
        GapTask(
          id: 'ent-math',
          title: 'Поднять матграмотность ЕНТ',
          description: '2-недельный спринт по слабым темам с мини-тестом.',
          dueDate: due(14),
          linkedIntensiveSlug: 'ent-math-14',
        ),
      );
    }

    final wantsAbroad = profile.targetGeos.contains(TargetGeo.us) ||
        profile.targetGeos.contains(TargetGeo.eu) ||
        profile.targetGeos.contains(TargetGeo.asia);
    if (wantsAbroad) {
      tasks
        ..add(
          GapTask(
            id: 'ielts',
            title: 'IELTS Writing band 6.5',
            description: '2-недельный трек по Task 1 и Task 2 с рубрикой.',
            dueDate: due(14),
            linkedIntensiveSlug: 'ielts-writing-14',
          ),
        )
        ..add(
          GapTask(
            id: 'essay',
            title: 'Написать черновик эссе',
            description: 'Трек «Эссе за 14 дней» — ты автор, Ералы помогает.',
            dueDate: due(14),
            linkedIntensiveSlug: 'essay-14',
          ),
        );
    }

    if (profile.targetGeos.contains(TargetGeo.us)) {
      tasks.add(
        GapTask(
          id: 'activities',
          title: 'Собрать activities list',
          description: '10 сильных строк Common App с impact.',
          dueDate: due(7),
          linkedIntensiveSlug: 'activities-7',
        ),
      );
    }

    return tasks;
  }
}
