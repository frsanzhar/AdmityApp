// Domain model for a foreign (abroad) university entry sourced from
// assets/data/universities_abroad.json.
//
// Honesty rule: tuition and fin_aid strings are shown as-is from the curated
// source; never synthesise or inflate financial figures.

import 'package:flutter/foundation.dart';

/// Financial-aid generosity tier for international applicants.
///
/// Values mirror the `fin_aid` token set in universities_abroad.json.
enum FinAidTier {
  /// Need-blind for international students.
  needBlindIntl,

  /// Generous need-aware — meaningful aid available but not guaranteed.
  generousNeedAware,

  /// Limited aid — small scholarships only, most pay full sticker price.
  limited,

  /// No aid offered to international students.
  none,
}

/// Parses a [FinAidTier] from its JSON string token.
FinAidTier finAidTierFromJson(String? raw) {
  switch (raw) {
    case 'need_blind_intl':
      return FinAidTier.needBlindIntl;
    case 'generous_need_aware':
      return FinAidTier.generousNeedAware;
    case 'none':
      return FinAidTier.none;
    case 'limited':
    default:
      return FinAidTier.limited;
  }
}

/// Numeric sort priority for [FinAidTier] — lower is better.
int finAidSortOrder(FinAidTier tier) {
  switch (tier) {
    case FinAidTier.needBlindIntl:
      return 0;
    case FinAidTier.generousNeedAware:
      return 1;
    case FinAidTier.limited:
      return 2;
    case FinAidTier.none:
      return 3;
  }
}

/// Human-readable Russian label for a [FinAidTier].
String finAidTierLabel(FinAidTier tier) {
  switch (tier) {
    case FinAidTier.needBlindIntl:
      return 'Нужд-слепой приём';
    case FinAidTier.generousNeedAware:
      return 'Щедрая финпомощь';
    case FinAidTier.limited:
      return 'Ограниченная помощь';
    case FinAidTier.none:
      return 'Без финпомощи';
  }
}

/// A single foreign university from the curated abroad catalog.
@immutable
class AbroadUniversity {
  /// Creates an [AbroadUniversity].
  const AbroadUniversity({
    required this.id,
    required this.nameEn,
    required this.country,
    required this.city,
    required this.majors,
    this.tuitionUsdPerYear,
    this.finAid,
    this.rankingTier,
    this.notableFor,
    this.sourceUrl,
    this.imageUrl,
    this.dormImageUrl,
  });

  /// Builds an [AbroadUniversity] from a decoded JSON map.
  factory AbroadUniversity.fromJson(Map<String, dynamic> json) {
    return AbroadUniversity(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      majors:
          (json['majors'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      tuitionUsdPerYear: json['tuition_usd_per_year'] as int?,
      finAid: json['fin_aid'] != null
          ? finAidTierFromJson(json['fin_aid'] as String?)
          : null,
      rankingTier: json['ranking_tier'] as String?,
      notableFor: json['notable_for'] as String?,
      sourceUrl: json['source_url'] as String?,
      imageUrl: json['image_url'] as String?,
      dormImageUrl: json['dorm_image_url'] as String?,
    );
  }

  /// Stable slug identifier, e.g. `harvard`, `mit`.
  final String id;

  /// English university name.
  final String nameEn;

  /// Country label in Russian (e.g. `США`, `Великобритания`).
  final String country;

  /// City label in Russian (e.g. `Кембридж`, `Лондон`).
  final String city;

  /// Major/field tokens this university is strong in.
  final List<String> majors;

  /// Approximate international sticker tuition per year in USD; null = unknown.
  final int? tuitionUsdPerYear;

  /// Financial-aid generosity tier for international applicants.
  final FinAidTier? finAid;

  /// Ranking tier string from the data, e.g. `T1`, `T2`, `T3`.
  final String? rankingTier;

  /// Short notable-for text (Russian), e.g. programme highlights.
  final String? notableFor;

  /// Provenance URL for this record.
  final String? sourceUrl;

  /// Optional campus photo URL (Wikimedia Commons or similar static CDN).
  ///
  /// Null for most records — the UI must always render a graceful
  /// placeholder when this is null or the request fails.
  final String? imageUrl;

  /// Optional dormitory photo URL — same sourcing/placeholder rules as
  /// [imageUrl].
  final String? dormImageUrl;

  /// Returns a copy with [imageUrl] / [dormImageUrl] set (image-merge loader).
  AbroadUniversity withImages({String? campus, String? dorm}) {
    return AbroadUniversity(
      id: id,
      nameEn: nameEn,
      country: country,
      city: city,
      majors: majors,
      tuitionUsdPerYear: tuitionUsdPerYear,
      finAid: finAid,
      rankingTier: rankingTier,
      notableFor: notableFor,
      sourceUrl: sourceUrl,
      imageUrl: campus ?? imageUrl,
      dormImageUrl: dorm ?? dormImageUrl,
    );
  }
}
