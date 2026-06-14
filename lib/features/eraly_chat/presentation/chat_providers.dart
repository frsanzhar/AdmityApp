import 'package:admity/core/ai/eraly_client.dart';
import 'package:admity/features/career_test/presentation/career_providers.dart';
import 'package:admity/features/chancing_kz/presentation/ent_providers.dart';
import 'package:admity/features/eraly_chat/domain/chat_models.dart';
import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the active Eraly conversation. In-memory for the session (chat history
/// is synced to Supabase when connected).
class ChatController extends Notifier<List<ChatMessage>> {
  var _seq = 0;

  String _id() => 'm${_seq++}_${DateTime.now().microsecondsSinceEpoch}';

  @override
  List<ChatMessage> build() => [
        ChatMessage(
          id: _id(),
          role: ChatRole.eraly,
          content:
              'Привет! Я Ералы. Спроси про твои шансы, стипендии, эссе или с '
              'чего начать. Я помогу и подскажу — но работу за тебя делать не '
              'буду 🙂',
          createdAt: DateTime.now(),
        ),
      ];

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final user = ChatMessage(
      id: _id(),
      role: ChatRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );
    final pending = ChatMessage(
      id: _id(),
      role: ChatRole.eraly,
      content: '',
      createdAt: DateTime.now(),
      pending: true,
    );
    state = [...state, user, pending];

    final reply = await ref.read(eralyClientProvider).send(
          history: state.where((m) => !m.pending).toList(),
          message: trimmed,
          profileContext: _profileContext(),
        );

    state = [
      for (final m in state)
        if (m.id == pending.id)
          m.copyWith(content: reply, pending: false)
        else
          m,
    ];
  }

  Map<String, dynamic> _profileContext() {
    final profile = ref.read(profileProvider);
    final ent = ref.read(entScoreProvider);
    final career = ref.read(careerProvider);
    return {
      'region': profile.region,
      'grade': profile.grade,
      'gpa': profile.gpa,
      'target_geo': profile.targetGeos.map((g) => g.name).toList(),
      'interests': profile.interests.toList(),
      'ent_total': ent?.total,
      'riasec_code': career?.riasecCode,
    };
  }
}

final chatProvider =
    NotifierProvider<ChatController, List<ChatMessage>>(ChatController.new);
