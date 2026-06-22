import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_filter.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Section notifier ──────────────────────────────────────────────────────────

class OpportunitiesSectionNotifier extends Notifier<OpportunitySection> {
  @override
  OpportunitySection build() => OpportunitySection.scholarships;

  // ignore: use_setters_to_change_properties, Riverpod Notifier methods cannot use Dart setter syntax; state assignment is the correct pattern here.
  void switchToSection(OpportunitySection newSection) {
    state = newSection;
  }
}

final opportunitiesSectionProvider =
    NotifierProvider<OpportunitiesSectionNotifier, OpportunitySection>(
      OpportunitiesSectionNotifier.new,
    );

// ── Filter notifier ───────────────────────────────────────────────────────────

class OpportunityFilterNotifier extends Notifier<OpportunityFilter> {
  @override
  OpportunityFilter build() => const OpportunityFilter();

  void setCity(String? city) =>
      state = state.copyWith(city: city, clearCity: city == null);

  void setField(AcademicField? field) =>
      state = state.copyWith(field: field, clearField: field == null);

  void setAccessibility(Accessibility? accessibility) => state = state.copyWith(
    accessibility: accessibility,
    clearAccessibility: accessibility == null,
  );

  void clearAll() => state = const OpportunityFilter();
}

final opportunityFilterProvider =
    NotifierProvider<OpportunityFilterNotifier, OpportunityFilter>(
      OpportunityFilterNotifier.new,
    );

// ── Derived filtered lists ────────────────────────────────────────────────────

final filteredScholarshipsProvider = Provider<List<Scholarship>>((ref) {
  final filter = ref.watch(opportunityFilterProvider);
  return filterScholarships(seedScholarships, filter);
});

final filteredUniversitiesProvider = Provider<List<University>>((ref) {
  final filter = ref.watch(opportunityFilterProvider);
  return filterUniversities(seedUniversities, filter);
});

// ── Personalised project ideas (driven by profile interests) ─────────────────

/// Result of personalising project ideas for the current student.
class PersonalizedProjectIdeasResult {
  const PersonalizedProjectIdeasResult({
    required this.ideas,
    required this.matchedInterest,
    required this.hasProfileInterests,
  });

  /// The ordered list of ideas to display.
  final List<ProjectIdea> ideas;

  /// The interest label that was matched (or null when falling back to general).
  final String? matchedInterest;

  /// Whether the profile had any interests at all.
  final bool hasProfileInterests;
}

/// Maps a free-text interest string to an [AcademicField] by keyword matching.
///
/// Interests are stored as plain strings (e.g. "Программирование", "Математика").
/// This function is intentionally liberal — partial case-insensitive matches win.
AcademicField? _interestToField(String interest) {
  final lower = interest.toLowerCase();
  if (lower.contains('информ') ||
      lower.contains('программ') ||
      lower.contains('it') ||
      lower.contains('айти') ||
      lower.contains('компьютер') ||
      lower.contains('cs')) {
    return AcademicField.informatics;
  }
  if (lower.contains('матем') ||
      lower.contains('алгебр') ||
      lower.contains('геометр')) {
    return AcademicField.mathematics;
  }
  if (lower.contains('инженер') ||
      lower.contains('техник') ||
      lower.contains('физик') ||
      lower.contains('робот')) {
    return AcademicField.engineering;
  }
  if (lower.contains('медицин') ||
      lower.contains('биолог') ||
      lower.contains('врач') ||
      lower.contains('химия') ||
      lower.contains('хими')) {
    return AcademicField.medicine;
  }
  if (lower.contains('эконом') ||
      lower.contains('бизнес') ||
      lower.contains('финанс')) {
    return AcademicField.economics;
  }
  if (lower.contains('право') ||
      lower.contains('юрид') ||
      lower.contains('закон')) {
    return AcademicField.law;
  }
  if (lower.contains('искусств') ||
      lower.contains('рисов') ||
      lower.contains('творч') ||
      lower.contains('дизайн') ||
      lower.contains('музык')) {
    return AcademicField.arts;
  }
  if (lower.contains('природ') ||
      lower.contains('экологи') ||
      lower.contains('биолог') ||
      lower.contains('географ')) {
    return AcademicField.natural;
  }
  return null;
}

/// Derives a [PersonalizedProjectIdeasResult] from the student's profile.
///
/// Algorithm:
/// 1. Map each interest string to an [AcademicField] via keyword matching.
/// 2. Pick the first interest that matches at least one seed idea; use that
///    field to rank (matching ideas first, then the rest).
/// 3. If no interest maps to a field, return all ideas (general fallback).
PersonalizedProjectIdeasResult _personalizeIdeas(List<String> interests) {
  if (interests.isEmpty) {
    return const PersonalizedProjectIdeasResult(
      ideas: seedProjectIdeas,
      matchedInterest: null,
      hasProfileInterests: false,
    );
  }

  for (final interest in interests) {
    final field = _interestToField(interest);
    if (field == null) continue;

    final matching = seedProjectIdeas.where((p) => p.field == field).toList();
    if (matching.isEmpty) continue;

    final rest = seedProjectIdeas.where((p) => p.field != field).toList();
    return PersonalizedProjectIdeasResult(
      ideas: [...matching, ...rest],
      matchedInterest: interest,
      hasProfileInterests: true,
    );
  }

  // Interests exist but none matched a field — show all with the first interest
  // as context so the UI can still show the "по твоему интересу" label.
  return PersonalizedProjectIdeasResult(
    ideas: seedProjectIdeas,
    matchedInterest: interests.first,
    hasProfileInterests: true,
  );
}

final personalizedProjectIdeasProvider =
    Provider<PersonalizedProjectIdeasResult>((ref) {
      final profile = ref.watch(profileProvider).profile;
      return _personalizeIdeas(profile.interests);
    });

// ── Location-based events (driven by profile city) ────────────────────────────

/// Result of ranking events for the student's city.
class LocalEventsResult {
  const LocalEventsResult({
    required this.events,
    required this.profileCity,
  });

  /// Events ordered: local matches first, then the rest.
  final List<OpportunityEvent> events;

  /// The city from the student's profile (null = not set).
  final String? profileCity;
}

/// Ranks events with the student's city first, everything else after.
LocalEventsResult _rankEventsByCity(String? city) {
  if (city == null || city.trim().isEmpty) {
    return const LocalEventsResult(
      events: seedEvents,
      profileCity: null,
    );
  }

  final lower = city.trim().toLowerCase();
  final local = seedEvents
      .where((e) => e.city.toLowerCase().contains(lower))
      .toList();
  final remote = seedEvents
      .where((e) => !e.city.toLowerCase().contains(lower))
      .toList();

  return LocalEventsResult(
    events: [...local, ...remote],
    profileCity: city.trim(),
  );
}

final localEventsProvider = Provider<LocalEventsResult>((ref) {
  final city = ref.watch(profileProvider).profile.city;
  return _rankEventsByCity(city);
});

// ── Application form ──────────────────────────────────────────────────────────

enum ApplicationFormStatus { idle, submitting, success }

class ApplicationFormState {
  const ApplicationFormState({
    required this.fullName,
    required this.contact,
    required this.motivation,
    required this.status,
    this.fieldErrors,
  });

  factory ApplicationFormState.initial() => const ApplicationFormState(
    fullName: '',
    contact: '',
    motivation: '',
    status: ApplicationFormStatus.idle,
  );

  final String fullName;
  final String contact;
  final String motivation;
  final ApplicationFormStatus status;
  final Map<String, String>? fieldErrors;

  ApplicationFormState copyWith({
    String? fullName,
    String? contact,
    String? motivation,
    ApplicationFormStatus? status,
    Map<String, String>? fieldErrors,
    bool clearErrors = false,
  }) {
    return ApplicationFormState(
      fullName: fullName ?? this.fullName,
      contact: contact ?? this.contact,
      motivation: motivation ?? this.motivation,
      status: status ?? this.status,
      fieldErrors: clearErrors ? null : (fieldErrors ?? this.fieldErrors),
    );
  }

  bool get isSuccess => status == ApplicationFormStatus.success;
}

class ApplicationFormNotifier extends Notifier<ApplicationFormState> {
  @override
  ApplicationFormState build() => ApplicationFormState.initial();

  void setFullName(String v) =>
      state = state.copyWith(fullName: v, clearErrors: true);
  void setContact(String v) =>
      state = state.copyWith(contact: v, clearErrors: true);
  void setMotivation(String v) =>
      state = state.copyWith(motivation: v, clearErrors: true);

  void reset() => state = ApplicationFormState.initial();

  Future<void> submit() async {
    // Validate
    final errors = <String, String>{};
    if (state.fullName.trim().isEmpty) {
      errors['fullName'] = 'Введите ФИО';
    }
    final contact = state.contact.trim();
    if (contact.isEmpty) {
      errors['contact'] = 'Введите контакт';
    }
    if (state.motivation.trim().length < 20) {
      errors['motivation'] = 'Напишите не менее 20 символов';
    }
    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return;
    }

    state = state.copyWith(
      status: ApplicationFormStatus.submitting,
      clearErrors: true,
    );
    // Simulate async submit (no network yet).
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(status: ApplicationFormStatus.success);
  }
}

final applicationFormProvider =
    NotifierProvider<ApplicationFormNotifier, ApplicationFormState>(
      ApplicationFormNotifier.new,
    );
