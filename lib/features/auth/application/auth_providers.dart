/// Riverpod providers for the Auth feature.
///
/// Hand-written (no codegen) per CLAUDE.md §1.
library;

import 'package:admity/features/auth/data/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the singleton [AuthService] for the current [Ref].
///
/// Override in tests:
/// ```dart
/// ProviderScope(
///   overrides: [
///     authServiceProvider.overrideWithValue(FakeAuthService(ref)),
///   ],
///   child: MyApp(),
/// );
/// ```
final authServiceProvider = Provider<AuthService>(AuthService.new);
