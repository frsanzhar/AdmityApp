import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:admity/features/scholarships/data/scholarships_seed.dart';
import 'package:admity/features/scholarships/domain/scholarship_matcher.dart';
import 'package:admity/features/scholarships/domain/scholarship_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reference scholarship catalogue (seed data; Supabase-backed later).
final scholarshipsProvider =
    Provider<List<Scholarship>>((ref) => kScholarshipsSeed);

/// Eligibility context derived from the student profile (school student,
/// bachelor intent by default).
final eligibilityContextProvider = Provider<EligibilityContext>((ref) {
  final profile = ref.watch(profileProvider);
  final age = profile.grade == null ? null : 6 + profile.grade!;
  return EligibilityContext(ageYears: age);
});

/// Scholarship matches for the current profile, eligible-first.
final scholarshipMatchesProvider = Provider<List<ScholarshipMatch>>((ref) {
  final scholarships = ref.watch(scholarshipsProvider);
  final ctx = ref.watch(eligibilityContextProvider);
  return ScholarshipMatcher.match(scholarships, ctx);
});
