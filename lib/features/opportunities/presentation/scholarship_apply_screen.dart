import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/opportunities/presentation/opportunities_providers.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// In-app scholarship application form screen.
///
/// Fields: ФИО, контакт (email/телефон), мотивация.
/// Validation: all fields required, motivation ≥ 20 chars.
/// Submit: shows success state with MascotSlot celebrating.
///
/// Layout: AppScaffold > SingleChildScrollView > Column(mainAxisSize: .min).
/// Accent: AppColors.primary (field borders when focused).
/// PrimaryButton for submit (normal action).
/// resizeToAvoidBottomInset: true so keyboard doesn't cover form.
class ScholarshipApplyScreen extends ConsumerWidget {
  const ScholarshipApplyScreen({required this.scholarshipId, super.key});

  final String scholarshipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(applicationFormProvider);

    if (formState.isSuccess) {
      return _SuccessScreen(scholarshipId: scholarshipId);
    }

    return AppScaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () =>
              context.go('/opportunities/scholarship/$scholarshipId'),
        ),
        title: Text(
          'Подача заявки',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
              ),
        ),
        elevation: 0,
        surfaceTintColor: AppColors.white,
      ),
      body: _ApplicationForm(scholarshipId: scholarshipId),
    );
  }
}

class _ApplicationForm extends ConsumerWidget {
  const _ApplicationForm({required this.scholarshipId});

  final String scholarshipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(applicationFormProvider);
    final notifier = ref.read(applicationFormProvider.notifier);
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Заполните заявку',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.ink,
                ),
          ),
          SizedBox(height: tokens.gapSm),
          Text(
            'Все поля обязательны. Данные хранятся локально.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSecondary,
                ),
          ),
          SizedBox(height: tokens.gapXl),

          // ── Full name ──────────────────────────────────────────────────
          AppCard(
            padding: EdgeInsets.all(tokens.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel(label: 'ФИО'),
                SizedBox(height: tokens.gapSm),
                _AppTextField(
                  hint: 'Иванов Иван Иванович',
                  onChanged: notifier.setFullName,
                  errorText: formState.fieldErrors?['fullName'],
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.gapMd),

          // ── Contact ────────────────────────────────────────────────────
          AppCard(
            padding: EdgeInsets.all(tokens.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel(label: 'Контакт (email или телефон)'),
                SizedBox(height: tokens.gapSm),
                _AppTextField(
                  hint: 'example@mail.kz или +7 777 000 00 00',
                  onChanged: notifier.setContact,
                  errorText: formState.fieldErrors?['contact'],
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.gapMd),

          // ── Motivation ─────────────────────────────────────────────────
          AppCard(
            padding: EdgeInsets.all(tokens.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel(label: 'Мотивационное письмо'),
                SizedBox(height: tokens.gapSm),
                _AppTextField(
                  hint: 'Расскажите, почему вы хотите получить эту стипендию '
                      'и как она поможет вашему обучению...',
                  onChanged: notifier.setMotivation,
                  errorText: formState.fieldErrors?['motivation'],
                  maxLines: 5,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.gapXxl),

          // ── Submit ─────────────────────────────────────────────────────
          PrimaryButton(
            label: 'Отправить заявку',
            isLoading: formState.status == ApplicationFormStatus.submitting,
            onPressed: () => unawaited(notifier.submit()),
          ),
          SizedBox(height: tokens.gapXl),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.ink,
          ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.hint,
    required this.onChanged,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.ink,
          ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkSecondary,
            ),
        errorText: errorText,
        errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.errorRed,
            ),
        filled: true,
        fillColor: AppColors.surfaceTint,
        contentPadding: EdgeInsets.all(tokens.cardPadding),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
      ),
    );
  }
}

// ── Success screen ─────────────────────────────────────────────────────────────

class _SuccessScreen extends ConsumerWidget {
  const _SuccessScreen({required this.scholarshipId});

  final String scholarshipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

    return AppScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: tokens.gapXxl),
            // Mascot celebrating
            const MascotSlot(
              tag: 'application-success',
            ),
            SizedBox(height: tokens.gapXxl),
            Text(
              'Заявка отправлена!',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.ink,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.gapMd),
            Text(
              'Мы сохранили твою заявку. Следи за статусом в разделе '
              '«Профиль → Документы».',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.gapXxl),
            AppCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.successGreen,
                    size: 32,
                  ),
                  SizedBox(width: tokens.gapMd),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Заявка принята',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.ink),
                        ),
                        SizedBox(height: tokens.gapXs),
                        Text(
                          'Данные сохранены локально',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.gapXxl),
            PrimaryButton(
              label: 'Вернуться к стипендиям',
              onPressed: () {
                ref.read(applicationFormProvider.notifier).reset();
                context.go('/opportunities');
              },
            ),
            SizedBox(height: tokens.gapXl),
          ],
        ),
      ),
    );
  }
}
