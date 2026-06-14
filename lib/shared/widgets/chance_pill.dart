import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/shared/models/chance_category.dart';
import 'package:flutter/material.dart';

/// A colored category pill for chancing results (reach/target/likely or
/// below/at-risk/safe). Color comes from the theme's chancing tokens.
class ChancePill extends StatelessWidget {
  const ChancePill.kz(this.kz, {super.key}) : world = null;
  const ChancePill.world(this.world, {super.key}) : kz = null;

  final KzChance? kz;
  final WorldChance? world;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (label, color) = switch ((kz, world)) {
      (KzChance.belowThreshold, _) => ('Ниже порога', tokens.chanceReach),
      (KzChance.atRisk, _) => ('Зона риска', tokens.warning),
      (KzChance.safe, _) => ('Проходишь', tokens.chanceLikely),
      (_, WorldChance.reach) => ('Reach', tokens.chanceReach),
      (_, WorldChance.target) => ('Target', tokens.chanceTarget),
      (_, WorldChance.likely) => ('Likely', tokens.chanceLikely),
      _ => ('—', tokens.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadii.brPill,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
