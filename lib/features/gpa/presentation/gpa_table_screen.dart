import 'dart:io';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/gpa/domain/gpa_calculator.dart';
import 'package:admity/features/gpa/domain/gpa_models.dart';
import 'package:admity/features/gpa/presentation/gpa_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:admity/shared/widgets/selectable_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// «Калькулятор GPA» — an editable subject table that computes the student's
/// GPA live on both the Kazakh 5-point scale and the US 4.0 scale, plus an
/// optional report-card photo attachment.
class GpaTableScreen extends ConsumerWidget {
  /// Creates the GPA calculator screen.
  const GpaTableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(gpaSubjectsProvider);
    final result = ref.watch(gpaResultProvider);
    final photoPath = ref.watch(gpaReportPhotoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Калькулятор GPA')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GpaSummary(result: result, hasSubjects: subjects.isNotEmpty),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'Предметы',
                subtitle: 'Добавь предметы и выбери оценку для каждого.',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (subjects.isEmpty)
                _EmptyHint(context: context)
              else
                ...subjects.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _SubjectCard(subject: s),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Добавить предмет',
                icon: Icons.add_rounded,
                onPressed: () => _addSubject(context, ref),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ReportPhotoCard(photoPath: photoPath),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addSubject(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _AddSubjectDialog(),
    );
    if (name == null || name.trim().isEmpty) return;
    ref.read(gpaSubjectsProvider.notifier).add(
          Subject(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: name.trim(),
            grade: Grade.excellent,
          ),
        );
  }
}

/// The large dual-scale GPA readout shown at the top of the screen.
class _GpaSummary extends StatelessWidget {
  const _GpaSummary({required this.result, required this.hasSubjects});

  final GpaResult result;
  final bool hasSubjects;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      accent: AppColors.terracotta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Твой GPA',
            style: context.text.titleSmall
                ?.copyWith(color: context.tokens.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ScaleValue(
                  value: result.scale5,
                  max: '5',
                  caption: '5-балльная',
                  enabled: hasSubjects,
                ),
              ),
              Container(
                width: 1,
                height: 56,
                color: context.colors.outlineVariant,
              ),
              Expanded(
                child: _ScaleValue(
                  value: result.scale4,
                  max: '4.0',
                  caption: 'US 4.0',
                  enabled: hasSubjects,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Считаем сами по твоей таблице.',
            style: context.text.labelSmall
                ?.copyWith(color: context.tokens.textMuted),
          ),
        ],
      ),
    );
  }
}

/// A single big GPA figure with its scale caption.
class _ScaleValue extends StatelessWidget {
  const _ScaleValue({
    required this.value,
    required this.max,
    required this.caption,
    required this.enabled,
  });

  final double value;
  final String max;
  final String caption;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final shown = enabled ? value.toStringAsFixed(2) : '—';
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: shown,
            style: context.text.displaySmall?.copyWith(
              color: enabled
                  ? AppColors.terracotta
                  : context.tokens.textMuted,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(
                text: ' / $max',
                style: context.text.titleMedium
                    ?.copyWith(color: context.tokens.textMuted),
              ),
            ],
          ),
        ),
        Text(
          caption,
          style: context.text.labelSmall
              ?.copyWith(color: context.tokens.textMuted),
        ),
      ],
    );
  }
}

/// One editable subject row: name, grade chips and a remove action.
class _SubjectCard extends ConsumerWidget {
  const _SubjectCard({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gpaSubjectsProvider.notifier);
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(subject.name, style: context.text.titleSmall),
              ),
              IconButton(
                onPressed: () => notifier.remove(subject.id),
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Удалить',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final g in Grade.values)
                SelectableChip(
                  label: g.points5.toString(),
                  selected: subject.grade == g,
                  onTap: () => notifier.update(subject.copyWith(grade: g)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Empty-state hint shown when no subjects have been added yet.
class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      color: context.tokens.surfaceSunken,
      child: Text(
        'Пока пусто. Добавь первый предмет ниже.',
        style: context.text.bodyMedium
            ?.copyWith(color: context.tokens.textMuted),
      ),
    );
  }
}

/// The report-card photo card: prominent capture button, thumbnail and the
/// Eraly note. We still compute the GPA ourselves from the table above.
class _ReportPhotoCard extends ConsumerWidget {
  const _ReportPhotoCard({required this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Табель',
            subtitle: 'Прикрепи фото табеля для сверки.',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (hasPhoto) ...[
            ClipRRect(
              borderRadius: AppRadii.brMd,
              child: Image.file(
                File(photoPath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ералы сможет свериться с фото — '
              'а пока проверь оценки сам.',
              style: context.text.bodySmall
                  ?.copyWith(color: context.tokens.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(gpaReportPhotoProvider.notifier).setPath(null),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Убрать фото'),
              ),
            ),
          ],
          PrimaryButton(
            label: 'Сфотографировать табель',
            icon: Icons.photo_camera_rounded,
            onPressed: () => _pickPhoto(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => const _PhotoSourceSheet(),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 70);
    if (file == null) return;
    ref.read(gpaReportPhotoProvider.notifier).setPath(file.path);
  }
}

/// Bottom sheet letting the student pick camera vs. gallery.
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_rounded),
            title: const Text('Камера'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Галерея'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

/// Simple dialog that collects a new subject's name.
class _AddSubjectDialog extends StatefulWidget {
  const _AddSubjectDialog();

  @override
  State<_AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<_AddSubjectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый предмет'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Например, Математика'),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
