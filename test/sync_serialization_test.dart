import 'package:admity/features/eraly_chat/domain/chat_models.dart';
import 'package:admity/features/essay_review/domain/essay_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage serialization', () {
    test('round-trips id/role/content/createdAt; never persists pending', () {
      final msg = ChatMessage(
        id: 'm1',
        role: ChatRole.user,
        content: 'Привет',
        createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
        pending: true,
      );
      final back = ChatMessage.fromJson(msg.toJson());
      expect(back.id, 'm1');
      expect(back.role, ChatRole.user);
      expect(back.content, 'Привет');
      expect(back.createdAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
      expect(back.pending, isFalse); // transient — not serialized
    });

    test('unknown role degrades to eraly, bad timestamp tolerated', () {
      final back = ChatMessage.fromJson(
        const <String, dynamic>{'id': 'x', 'role': 'bogus', 'content': 'c'},
      );
      expect(back.role, ChatRole.eraly);
      expect(back.content, 'c');
    });
  });

  group('Essay serialization', () {
    test('EssayRecord + EssayFeedback round-trip, incl. byEraly + partial rubric',
        () {
      const feedback = EssayFeedback(
        scores: [
          RubricScore(
            criterion: RubricCriterion.concreteness,
            score: 3,
            comment: 'good detail',
            byEraly: true,
          ),
          RubricScore(
            criterion: RubricCriterion.wordEconomy,
            score: 2,
            comment: 'trim it',
          ),
        ],
        wordCount: 120,
        strengths: ['voice'],
        suggestions: ['shorten intro'],
        overall: 'solid start',
      );
      final rec = EssayRecord(
        kind: EssayKind.commonApp,
        draftText: 'my draft',
        feedback: feedback,
        updatedAt: DateTime.utc(2026, 6, 15),
      );

      final back = EssayRecord.tryFromJson(rec.toJson());
      expect(back, isNotNull);
      expect(back!.kind, EssayKind.commonApp);
      expect(back.draftText, 'my draft');
      expect(back.updatedAt, DateTime.utc(2026, 6, 15));
      expect(back.feedback!.wordCount, 120);
      expect(back.feedback!.overall, 'solid start');
      expect(back.feedback!.scores.length, 2);
      expect(back.feedback!.scores.first.criterion, RubricCriterion.concreteness);
      expect(back.feedback!.scores.first.byEraly, isTrue);
      expect(back.feedback!.scores[1].byEraly, isFalse);
    });

    test('a draft with no feedback round-trips', () {
      final rec = EssayRecord(
        kind: EssayKind.ucas,
        draftText: 'wip',
        updatedAt: DateTime.utc(2026),
      );
      final back = EssayRecord.tryFromJson(rec.toJson())!;
      expect(back.feedback, isNull);
      expect(back.draftText, 'wip');
    });

    test('unknown kind / criterion degrade gracefully', () {
      expect(
        EssayRecord.tryFromJson({'kind': 'bogus', 'draft_text': 'x'}),
        isNull,
      );
      expect(
        RubricScore.tryFromJson({'criterion': 'bogus', 'score': 2, 'comment': ''}),
        isNull,
      );
    });
  });
}
