import 'dart:async';
import 'dart:io';

import 'package:admity/core/storage/local_store.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// What kind of deliverable the student captures for a camera task.
enum CameraEvidenceKind {
  /// A photo — e.g. a snapshot of a handwritten plan or a filled worksheet.
  photo,

  /// A short video — e.g. a 60-second self-presentation.
  video,
}

/// Stores captured-evidence file paths keyed by task id, persisted offline via
/// the [localStoreProvider]. A task is considered «done» once its path is set.
///
/// State maps a task id (e.g. `'essay-14:day-4'`) to the absolute file path of
/// the captured photo or video on disk.
class CameraEvidenceController extends Notifier<Map<String, String>> {
  static const _key = 'intensive_camera_evidence';

  @override
  Map<String, String> build() {
    final json = ref.read(localStoreProvider).readJson(_key);
    if (json == null) return const {};
    return json.map((key, value) => MapEntry(key, value as String));
  }

  /// Records the captured file [path] for the given [taskId].
  void setPath(String taskId, String path) {
    state = {...state, taskId: path};
    _persist();
  }

  /// Clears the captured evidence for [taskId] (lets the student redo it).
  void clear(String taskId) {
    final copy = {...state}..remove(taskId);
    state = copy;
    _persist();
  }

  /// The stored path for [taskId], or null if nothing has been captured.
  String? pathFor(String taskId) => state[taskId];

  void _persist() => ref.read(localStoreProvider).put(_key, state);
}

/// Provides captured-evidence paths keyed by intensive task id.
final cameraEvidenceProvider =
    NotifierProvider<CameraEvidenceController, Map<String, String>>(
  CameraEvidenceController.new,
);

/// A reusable intensive-task widget for capturing a deliverable with the
/// device camera or library (via `image_picker`): a photo of a handwritten
/// plan, or a short self-presentation video.
///
/// The captured file path is stored in [cameraEvidenceProvider] keyed by
/// [taskId], so it survives navigation and app restarts. The card shows a
/// thumbnail and a «Готово» state once evidence exists, and exposes
/// [onEvidenceChanged] for the parent to mark the day's evidence as collected.
class CameraTaskCard extends ConsumerWidget {
  /// Creates a camera/attachment task card.
  const CameraTaskCard({
    required this.taskId,
    required this.prompt,
    this.kind = CameraEvidenceKind.photo,
    this.onEvidenceChanged,
    super.key,
  });

  /// Unique id for this task, used as the storage key (e.g. `slug:day-N`).
  final String taskId;

  /// Short instruction shown on the card (Russian, user-facing).
  final String prompt;

  /// Whether the student attaches a photo or a video.
  final CameraEvidenceKind kind;

  /// Called with the new path (or null when cleared) after every change.
  final ValueChanged<String?>? onEvidenceChanged;

  Future<void> _capture(WidgetRef ref, {required bool fromCamera}) async {
    final picker = ImagePicker();
    final XFile? file;
    if (kind == CameraEvidenceKind.video) {
      file = await picker.pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );
    } else {
      file = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
    }
    if (file == null) return;
    ref.read(cameraEvidenceProvider.notifier).setPath(taskId, file.path);
    onEvidenceChanged?.call(file.path);
  }

  void _clear(WidgetRef ref) {
    ref.read(cameraEvidenceProvider.notifier).clear(taskId);
    onEvidenceChanged?.call(null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(
      cameraEvidenceProvider.select((map) => map[taskId]),
    );
    final hasEvidence = path != null;
    final isVideo = kind == CameraEvidenceKind.video;
    final cameraLabel = isVideo ? 'Записать видео' : 'Сделать фото';

    return BentoCard(
      accent: hasEvidence ? context.tokens.success : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isVideo
                    ? Icons.videocam_rounded
                    : Icons.photo_camera_rounded,
                color: context.colors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(prompt, style: context.text.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (hasEvidence)
            _EvidencePreview(path: path, isVideo: isVideo)
          else
            _EvidencePlaceholder(isVideo: isVideo),
          const SizedBox(height: AppSpacing.sm),
          if (hasEvidence)
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: context.tokens.success,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Готово',
                  style: context.text.labelLarge
                      ?.copyWith(color: context.tokens.success),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _clear(ref),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Заменить'),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        unawaited(_capture(ref, fromCamera: true)),
                    icon: Icon(
                      isVideo
                          ? Icons.videocam_rounded
                          : Icons.photo_camera_rounded,
                      size: 18,
                    ),
                    label: Text(cameraLabel),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        unawaited(_capture(ref, fromCamera: false)),
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: const Text('Из галереи'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Shows a thumbnail of the captured evidence: the image itself for photos, or
/// a film-strip placeholder with the file name for videos.
class _EvidencePreview extends StatelessWidget {
  const _EvidencePreview({required this.path, required this.isVideo});

  final String path;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    if (isVideo) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: context.tokens.surfaceSunken,
          borderRadius: AppRadii.brMd,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Icon(
                Icons.movie_rounded,
                color: context.tokens.textMuted,
                size: 36,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Видео прикреплено: ${path.split('/').last}',
                  style: context.text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: AppRadii.brMd,
      child: Image.file(
        File(path),
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 160,
          alignment: Alignment.center,
          color: context.tokens.surfaceSunken,
          child: Icon(
            Icons.broken_image_rounded,
            color: context.tokens.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Empty-state hint shown before the student captures anything.
class _EvidencePlaceholder extends StatelessWidget {
  const _EvidencePlaceholder({required this.isVideo});

  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.tokens.surfaceSunken,
        borderRadius: AppRadii.brMd,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Icon(
              isVideo
                  ? Icons.video_call_rounded
                  : Icons.add_a_photo_rounded,
              color: context.tokens.textMuted,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isVideo
                  ? 'Запиши короткое видео до 60 секунд'
                  : 'Прикрепи фото своей работы',
              textAlign: TextAlign.center,
              style: context.text.bodySmall
                  ?.copyWith(color: context.tokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
