/// Barrel export for all onboarding illustration/diagram widgets.
///
/// Import this single file to access:
/// - [TopicMapDiagram]        — Obsidian-style graph; split-apart / reassemble
/// - [KnowledgeBranchDiagram] — origin → branch reveal animation
/// - [KnowledgeBranchDiagramController] — optional imperative trigger
/// - [OptionDiagram3D]        — isometric tile; 4 variants via [OptionDiagram3DVariant]
/// - [OptionDiagram3DVariant] — motivation / beginner / advanced / explorer
/// - [UniversitiesDiagram]    — abstract orbital "world-class" visual
/// - [PlanStepDiagram]        — 3-step plan card icon; 3 variants via [PlanStepVariant]
/// - [PlanStepVariant]        — start / improve / test
library;

import 'package:admity/shared/diagrams/onboarding/onboarding_diagrams.dart' show KnowledgeBranchDiagram, KnowledgeBranchDiagramController, OptionDiagram3D, OptionDiagram3DVariant, PlanStepDiagram, PlanStepVariant, TopicMapDiagram, UniversitiesDiagram;

export 'knowledge_branch_diagram.dart';
export 'option_diagram_3d.dart';
export 'plan_step_diagram.dart';
export 'topic_map_diagram.dart';
export 'universities_diagram.dart';
