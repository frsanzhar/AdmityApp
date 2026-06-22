import 'package:admity/features/opportunities/domain/opportunity_models.dart';

/// Pure filtering functions — no Flutter deps, fully unit-testable.

/// Returns scholarships that match ALL non-null filter criteria.
List<Scholarship> filterScholarships(
  List<Scholarship> source,
  OpportunityFilter filter,
) {
  if (filter.isEmpty) return source;
  return source.where((s) {
    if (filter.city != null &&
        !s.city.toLowerCase().contains(filter.city!.toLowerCase())) {
      return false;
    }
    if (filter.field != null && s.field != filter.field) {
      return false;
    }
    if (filter.accessibility != null &&
        s.accessibility != filter.accessibility) {
      return false;
    }
    return true;
  }).toList();
}

/// Returns universities that match ALL non-null filter criteria.
List<University> filterUniversities(
  List<University> source,
  OpportunityFilter filter,
) {
  if (filter.isEmpty) return source;
  return source.where((u) {
    if (filter.city != null &&
        !u.city.toLowerCase().contains(filter.city!.toLowerCase())) {
      return false;
    }
    if (filter.field != null && u.field != filter.field) {
      return false;
    }
    if (filter.accessibility != null &&
        u.accessibility != filter.accessibility) {
      return false;
    }
    return true;
  }).toList();
}

/// Returns project ideas keyed to a specific field (or all if null).
List<ProjectIdea> filterProjectIdeas(
  List<ProjectIdea> source,
  AcademicField? field,
) {
  if (field == null) return source;
  return source.where((p) => p.field == field).toList();
}
