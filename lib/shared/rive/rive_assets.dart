// Rive asset path constants and State Machine contracts for Admity.
//
// Each constant documents:
//   - assetPath  — path under assets/rive/ (add to pubspec once the .riv
//                  file is delivered by the designer).
//   - machineName — Rive State Machine name inside the .riv file.
//   - Input/trigger constants — strings expected by the State Machine.
//
// Until the .riv files are delivered every slot falls back to the existing
// static placeholder (MascotSlot blob, etc.).  A TODO(rive-asset) marker
// is placed on each constant that is still missing its file.

// ── Mascot ────────────────────────────────────────────────────────────────────

/// Asset path for the mascot Rive file.
// TODO(rive-asset): Deliver assets/rive/mascot.riv from designer.
const kMascotRivAsset = 'assets/rive/mascot.riv';

/// State Machine name inside mascot.riv.
const kMascotMachineName = 'MascotSM';

/// Boolean input: mascot is idle (true) vs active (false).
const kMascotInputIdle = 'isIdle';

/// Boolean input: mascot is in happy state.
const kMascotInputHappy = 'isHappy';

/// Trigger: mascot flies down from top (used on "Start Lesson" tap).
const kMascotTriggerFlyDown = 'flyDown';

/// Trigger: mascot enters celebration state (lesson complete).
const kMascotTriggerCelebrate = 'celebrate';

// ── Splash ────────────────────────────────────────────────────────────────────

/// Asset path for the splash screen Rive file.
// TODO(rive-asset): Deliver assets/rive/splash.riv from designer.
const kSplashRivAsset = 'assets/rive/splash.riv';

/// State Machine name inside splash.riv.
const kSplashMachineName = 'SplashSM';

/// Trigger: start the light-sweep + fly-up animation sequence.
const kSplashTriggerPlay = 'play';

// ── Lesson feedback ───────────────────────────────────────────────────────────

/// Asset path for the lesson feedback Rive file (checkmark/cross burst).
// TODO(rive-asset): Deliver assets/rive/lesson_feedback.riv from designer.
const kFeedbackRivAsset = 'assets/rive/lesson_feedback.riv';

/// State Machine name inside lesson_feedback.riv.
const kFeedbackMachineName = 'FeedbackSM';

/// Trigger: play the correct-answer celebration burst.
const kFeedbackTriggerCorrect = 'correct';

/// Trigger: play the wrong-answer shake/cross burst.
const kFeedbackTriggerIncorrect = 'incorrect';

// ── Lesson complete / confetti ────────────────────────────────────────────────

/// Asset path for the lesson-complete confetti Rive file.
// TODO(rive-asset): Deliver assets/rive/lesson_complete.riv from designer.
const kLessonCompleteRivAsset = 'assets/rive/lesson_complete.riv';

/// State Machine name inside lesson_complete.riv.
const kLessonCompleteMachineName = 'CompleteSM';

/// Trigger: fire confetti / celebration animation.
const kLessonCompleteTriggerCelebrate = 'celebrate';

// ── Streak badge ──────────────────────────────────────────────────────────────

/// Asset path for the streak badge Rive file.
// TODO(rive-asset): Deliver assets/rive/streak_badge.riv from designer.
const kStreakBadgeRivAsset = 'assets/rive/streak_badge.riv';

/// State Machine name inside streak_badge.riv.
const kStreakBadgeMachineName = 'StreakSM';

/// Number input: current streak day count (drives the badge count display).
const kStreakBadgeInputDays = 'days';

/// Trigger: play the streak increment animation (bolt pulse).
const kStreakBadgeTriggerPulse = 'pulse';
