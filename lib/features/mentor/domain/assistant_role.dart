import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The four AI assistants available in the Mentor hub.
///
/// Each role has its own persona, accent colour, icon, Hive history key,
/// and greeting message.  The [supportsAttachments] flag is true only for
/// [aruzhan] (homework photo/file upload).
enum AssistantRole {
  /// Ералы — главный наставник по поступлению.
  ///
  /// Ведёт общий чат, составляет планы, предлагает события.
  eraly,

  /// Азамат — строгий, но справедливый филолог.
  ///
  /// Оценивает эссе по критериям и помогает улучшить — НЕ пишет за ученика.
  azamat,

  /// Мадина — дотошная и заботливая. Проверяет комплект документов.
  ///
  /// Объясняет, где взять каждый документ (086-У, аттестат, etc.).
  madina,

  /// Аружан — вдохновляющая учительница.
  ///
  /// Уроки из календаря, мини-курсы, проверка ДЗ по фото/файлам.
  aruzhan;

  /// Display name shown in the hub card and app bar.
  String get displayName => switch (this) {
        eraly => 'Ералы',
        azamat => 'Азамат',
        madina => 'Мадина',
        aruzhan => 'Аружан',
      };

  /// One-word role label shown below the name on the hub card.
  String get roleLabel => switch (this) {
        eraly => 'Наставник',
        azamat => 'Эссе-коуч',
        madina => 'Документы',
        aruzhan => 'Учитель',
      };

  /// Short tagline shown on the hub card.
  String get tagline => switch (this) {
        eraly => 'Поступление, стипендии, события',
        azamat => 'Оценка эссе · не пишет за тебя',
        madina => 'Комплект документов для поступления',
        aruzhan => 'Уроки, ДЗ и мини-курсы',
      };

  /// First assistant message shown when the chat opens for the first time.
  String get greeting => switch (this) {
        eraly =>
          'Привет! Я Ералы — твой наставник по поступлению. '
              'Расскажи, куда целишься и с чего начнём?',
        azamat =>
          'Привет! Я Азамат — строгий, но справедливый. '
              'Скинь черновик эссе — разберём структуру, аргументы, стиль. '
              'Писать за тебя не буду: твоя история должна быть твоей.',
        madina =>
          'Привет! Я Мадина. Задай любой вопрос про документы: '
              '086-У, аттестат, грамоты, рекомендательные письма — '
              'объясню, где взять и как правильно оформить.',
        aruzhan =>
          'Привет! Я Аружан — твоя учительница. '
              'Можешь прикрепить фото задания или задать вопрос — '
              'разберём вместе по шагам!',
      };

  /// Placeholder text inside the message input field.
  String get inputHint => switch (this) {
        eraly => 'Напиши Ералы...',
        azamat => 'Вставь черновик или задай вопрос...',
        madina => 'Спроси про документы...',
        aruzhan => 'Задай вопрос или прикрепи ДЗ...',
      };

  /// Whether this assistant supports file/photo attachments.
  ///
  /// Currently only [aruzhan] (homework review) uses this capability.
  bool get supportsAttachments => this == aruzhan;

  /// Hive box key for persisting this assistant's chat history on-device.
  String get hiveKey => switch (this) {
        eraly => 'chat_eraly',
        azamat => 'chat_azamat',
        madina => 'chat_madina',
        aruzhan => 'chat_aruzhan',
      };

  /// Brand accent colour used for avatar background and active bubble.
  Color get accentColor => switch (this) {
        eraly => AppColors.primary,
        azamat => const Color(0xFF7C3AED),
        madina => const Color(0xFF0891B2),
        aruzhan => const Color(0xFFF59E0B),
      };

  /// Icon displayed on the hub card and assistant app bar.
  IconData get icon => switch (this) {
        eraly => Icons.school_rounded,
        azamat => Icons.edit_note_rounded,
        madina => Icons.folder_special_rounded,
        aruzhan => Icons.auto_stories_rounded,
      };
}
