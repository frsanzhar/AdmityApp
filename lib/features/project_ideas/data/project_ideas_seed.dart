import 'package:admity/features/project_ideas/domain/project_idea.dart';

/// Realistic, zero-budget projects tagged by RIASEC fit.
const List<ProjectIdea> kProjectIdeasSeed = [
  ProjectIdea(
    title: 'Локальное приложение для своего села',
    description: 'Собери офлайн-расписание автобусов/кружков и раздай соседям.',
    riasecCodes: ['I', 'R', 'C'],
    effort: '3–4 недели',
  ),
  ProjectIdea(
    title: 'Бесплатный кружок для младших',
    description: 'Веди кружок по Scratch/математике в школе — 1 проектор, 0 бюджета.',
    riasecCodes: ['S', 'A', 'E'],
    effort: '4+ недель',
  ),
  ProjectIdea(
    title: 'Мини-исследование района',
    description: 'Сравни данные (погода, цены, трафик) и сделай выводы в таблице.',
    riasecCodes: ['I', 'C'],
    effort: '2–3 недели',
  ),
  ProjectIdea(
    title: 'Дебат-клуб или волонтёрство',
    description: 'Организуй клуб или помоги НКО — лидерство и работа с людьми.',
    riasecCodes: ['E', 'S'],
    effort: '4+ недель',
  ),
  ProjectIdea(
    title: 'Серия постеров/видео на тему',
    description: 'Сделай визуальную серию о проблеме, которая тебя волнует.',
    riasecCodes: ['A', 'E'],
    effort: '2–3 недели',
  ),
  ProjectIdea(
    title: 'Самодельный датчик/устройство',
    description: 'Собери из дешёвых деталей измеритель (влажность, шум) и веди лог.',
    riasecCodes: ['R', 'I'],
    effort: '3–4 недели',
  ),
];
