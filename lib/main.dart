import 'dart:async';

import 'package:admity/app.dart';
import 'package:admity/bootstrap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  unawaited(bootstrap(() => const ProviderScope(child: AdmityApp())));
}
