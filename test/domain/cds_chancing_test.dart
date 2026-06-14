import 'package:admity/features/chancing_world/domain/cds_chancing.dart';
import 'package:admity/features/chancing_world/domain/cds_models.dart';
import 'package:admity/shared/models/chance_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const harvard = CdsSnapshot(
    university: 'Harvard',
    year: 2024,
    acceptanceRate: 0.04,
    sat25: 1500,
    sat75: 1580,
  );
  const stateFlagship = CdsSnapshot(
    university: 'State Flagship',
    year: 2024,
    acceptanceRate: 0.7,
    sat25: 1000,
    sat75: 1200,
  );
  const selective = CdsSnapshot(
    university: 'Selective Private',
    year: 2024,
    acceptanceRate: 0.3,
    sat25: 1200,
    sat75: 1400,
  );

  group('Ultra-selective is always a reach', () {
    test('even a top-of-band score → reach', () {
      final r = CdsChancing.evaluate(snapshot: harvard, satComposite: 1580);
      expect(r.tier, SelectivityTier.superSelective);
      expect(r.category, WorldChance.reach);
      expect(r.bandPosition, BandPosition.above);
    });
  });

  group('Accessible school', () {
    test('above the band → likely', () {
      final r =
          CdsChancing.evaluate(snapshot: stateFlagship, satComposite: 1300);
      expect(r.category, WorldChance.likely);
    });
    test('below the band → reach', () {
      final r =
          CdsChancing.evaluate(snapshot: stateFlagship, satComposite: 950);
      expect(r.bandPosition, BandPosition.below);
      expect(r.category, WorldChance.reach);
    });
  });

  group('Selective school', () {
    test('mid-band → target', () {
      final r = CdsChancing.evaluate(snapshot: selective, satComposite: 1300);
      expect(r.category, WorldChance.target);
    });
    test('above band → likely', () {
      final r = CdsChancing.evaluate(snapshot: selective, satComposite: 1500);
      expect(r.category, WorldChance.likely);
    });
  });

  test('percentile is interpolated within the band', () {
    final r = CdsChancing.evaluate(snapshot: selective, satComposite: 1300);
    // Midpoint of 1200..1400 → ~50th percentile.
    expect(r.estimatedPercentile, closeTo(50, 1));
    expect(r.testKind, 'SAT');
  });

  test('out-of-band scores never get a fabricated percentile', () {
    final above = CdsChancing.evaluate(snapshot: harvard, satComposite: 1600);
    expect(above.bandPosition, BandPosition.above);
    expect(above.estimatedPercentile, isNull);

    final below =
        CdsChancing.evaluate(snapshot: stateFlagship, satComposite: 950);
    expect(below.bandPosition, BandPosition.below);
    expect(below.estimatedPercentile, isNull);

    final inBand =
        CdsChancing.evaluate(snapshot: selective, satComposite: 1300);
    expect(inBand.estimatedPercentile, isNotNull);
  });
}
