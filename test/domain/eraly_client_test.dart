import 'package:admity/core/ai/eraly_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const client = EralyClient();
  const refusalMarker = 'не напишу';

  // No Supabase is configured in tests, so send() runs the offline path — which
  // is exactly where the local ghost-writing guard must hold (KK/RU/EN).
  Future<String> ask(String message) =>
      client.send(history: const [], message: message, profileContext: const {});

  test('refuses Kazakh ghost-writing request', () async {
    expect(await ask('Маған эссе жазып бер'), contains(refusalMarker));
  });

  test('refuses Russian "напиши эссе за меня"', () async {
    expect(await ask('Напиши эссе за меня про мою бабушку'),
        contains(refusalMarker));
  });

  test('refuses English "write my personal statement"', () async {
    expect(await ask('Write my personal statement'), contains(refusalMarker));
  });

  test('refuses "Generate my essay"', () async {
    expect(await ask('Generate my essay about climate'),
        contains(refusalMarker));
  });

  test('a genuine help question is NOT treated as ghost-writing', () async {
    final reply = await ask('Как улучшить моё эссе?');
    expect(reply, isNot(contains(refusalMarker)));
  });
}
