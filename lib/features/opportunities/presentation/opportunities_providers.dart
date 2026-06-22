import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_filter.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
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

  void setAccessibility(Accessibility? accessibility) =>
      state = state.copyWith(
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
