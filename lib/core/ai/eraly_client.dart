import 'package:admity/core/env/app_env.dart';
import 'package:admity/core/utils/app_logger.dart';
import 'package:admity/features/eraly_chat/domain/chat_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _logger = AppLogger('EralyClient');

/// Talks to Eraly. AI runs server-side in the `eraly` Supabase Edge Function
/// (which holds the LLM key and the system prompt). The client never embeds an
/// LLM key. When Supabase isn't configured, a principled offline fallback keeps
/// the app usable for demos — and the ghost-writing refusal is enforced locally
/// regardless, so the product principle holds even offline.
class EralyClient {
  const EralyClient();

  Future<String> send({
    required List<ChatMessage> history,
    required String message,
    required Map<String, dynamic> profileContext,
  }) async {
    if (_isGhostwritingRequest(message)) {
      return _ghostwritingRefusal(message);
    }
    if (!AppEnv.hasSupabase) {
      return _offlineFallback(message);
    }
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'eraly',
        body: {
          'message': message,
          'history': history
              .map((m) => {'role': m.role.name, 'content': m.content})
              .toList(),
          'profile': _minimizePii(profileContext),
        },
      );
      final data = res.data;
      if (data is Map && data['reply'] is String) {
        return data['reply'] as String;
      }
      _logger.warn('Unexpected Eraly response shape: $data');
      return _offlineFallback(message);
    } on Object catch (e) {
      _logger.warn('Eraly call failed: $e');
      return '${_offlineFallback(message)}\n\n'
          '(Не удалось связаться с сервером Ералы — показал офлайн-ответ.)';
    }
  }

  /// Strips identifying PII from the profile before it leaves the device for
  /// Anthropic. Drops the full name and the exact region/city (identifiers for
  /// a minor), and coarsens the exact GPA into a band. Keeps the non-identifying
  /// signal Eraly actually needs: grade, interests, target geos, GPA band and
  /// dream field. Unknown keys are passed through only if they are not on the
  /// identifier denylist, so future callers cannot accidentally leak new PII.
  Map<String, dynamic> _minimizePii(Map<String, dynamic> profile) {
    // Keys that must never reach Anthropic (identify the student or their home).
    const denylist = {
      'full_name',
      'fullName',
      'name',
      'region',
      'city',
      'user_id',
      'userId',
      'email',
      'locale',
      'motivation', // free-form text can embed identifying details
    };

    final out = <String, dynamic>{};
    for (final entry in profile.entries) {
      if (denylist.contains(entry.key)) continue;
      if (entry.key == 'gpa') continue; // replaced by a band below
      if (entry.value == null) continue;
      out[entry.key] = entry.value;
    }

    final gpaBand = _gpaBand(profile['gpa']);
    if (gpaBand != null) out['gpa_band'] = gpaBand;

    return out;
  }

  /// Buckets a 5-point-scale GPA into a coarse band so the exact value (a quasi
  /// identifier and a sensitive number for a minor) never leaves the device.
  String? _gpaBand(Object? gpa) {
    final value = gpa is num ? gpa.toDouble() : null;
    if (value == null) return null;
    if (value >= 4.5) return '4.5–5.0';
    if (value >= 4.0) return '4.0–4.4';
    if (value >= 3.5) return '3.5–3.9';
    if (value >= 3.0) return '3.0–3.4';
    return 'до 3.0';
  }

  /// Detects "write this document for me" intent across Kazakh, Russian and
  /// English. The product is built for Kazakh students and the offline build is
  /// the SOLE enforcement of the no-ghost-writing principle (the server system
  /// prompt only runs online), so this must cover KK + common synonyms.
  bool _isGhostwritingRequest(String message) {
    final m = message.toLowerCase();

    // Names of a document we must never ghost-write.
    const docNouns = [
      'эссе', // RU/KK essay (covers эссені, эссеге, …)
      'сочинение',
      'мотивацион', // мотивационное письмо
      'мотивациялық', // KK motivation letter
      'personal statement',
      'statement of purpose',
      'college essay',
      'admission essay',
      'admissions essay',
      'motivation letter',
      'essay',
    ];
    final hasDocNoun =
        docNouns.any(m.contains) || RegExp(r'\bsop\b').hasMatch(m);
    if (!hasDocNoun) return false;

    // "Do it for me" phrasings (any language) imply ghost-writing on their own.
    const forMe = ['за меня', 'вместо меня', 'орныма', 'for me', 'instead of me'];
    if (forMe.any(m.contains)) return true;

    // Write/generate verbs (RU/EN).
    const writeVerbs = [
      'напиши',
      'напишите',
      'сгенерир',
      'составь',
      'допиши',
      'сочини',
      'write',
      'generate',
      'compose',
      'draft',
      'do my',
    ];
    if (writeVerbs.any(m.contains)) return true;

    // Kazakh "жаз" stem (to write): жаз / жазып / жазып бер.
    return RegExp('жаз').hasMatch(m);
  }

  String _ghostwritingRefusal(String message) {
    return 'Я не напишу эссе за тебя — и вот почему это в твою пользу: '
        'вузы (UCAS, Common App, Chevening) считают сгенерированный текст '
        'списыванием, а твой настоящий голос — твоё главное преимущество.\n\n'
        'Давай по-другому: ответь на 3 вопроса, и история уже будет у тебя.\n'
        '1) Какой один реальный момент изменил твой взгляд на этот предмет?\n'
        '2) Что ты при этом увидел/услышал/сделал — конкретно?\n'
        '3) Что это говорит о том, как ты думаешь?\n\n'
        'Напиши ответы — я помогу превратить их в сильный абзац, '
        'но автором останешься ты.';
  }

  bool _isCyrillic(String s) => RegExp('[а-яёәіңғүұқөһ]').hasMatch(s.toLowerCase());

  String _offlineFallback(String message) {
    if (!_isCyrillic(message)) {
      return "I'm Eraly, your admissions mentor. I'm offline right now "
          "(no backend connected), so I can't run the full sub-agents. "
          'Once Supabase + the Eraly Edge Function are configured, I can give '
          'tailored chancing, scholarship and essay-rubric guidance — and '
          "I'll guide you, never do the work for you.";
    }
    return 'Привет! Я Ералы, твой наставник по поступлению. Сейчас я офлайн '
        '(бэкенд не подключён), поэтому не могу запустить суб-агентов на полную. '
        'Когда подключишь Supabase и Edge Function «eraly», я дам разбор шансов, '
        'стипендий и фидбэк по эссе — и буду направлять тебя, а не делать '
        'работу за тебя.\n\nА пока загляни в Чансинг, Стипендии и Интенсивы — '
        'они работают офлайн.';
  }
}

/// Provides the shared [EralyClient].
final eralyClientProvider = Provider<EralyClient>((ref) => const EralyClient());
