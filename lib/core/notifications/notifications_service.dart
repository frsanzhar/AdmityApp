/// Local-notification service for Admity.
///
/// Wraps `flutter_local_notifications` + `timezone` with a static surface
/// so it can be called from bootstrap and anywhere else without a `Ref`.
///
/// All public methods swallow errors and degrade gracefully — consistent with
/// the app's offline-first, never-crash-on-a-non-core-feature philosophy.
///
/// ## iOS integration (TODO for Integrate agent)
/// 1. In `ios/Runner/Info.plist` add the following keys:
///    ```xml
///    <key>NSUserNotificationUsageDescription</key>
///    <string>Admity uses notifications to remind you about daily study sessions.</string>
///    ```
/// 2. In `ios/Runner/AppDelegate.swift` (or AppDelegate.m) make the app
///    delegate extend `FlutterAppDelegate` **and** import
///    `flutter_local_notifications` — the plugin registers the
///    `UNUserNotificationCenterDelegate` automatically when the method channel
///    is bootstrapped, but the app delegate must be the `FlutterAppDelegate`
///    subclass for that registration to succeed.
/// 3. No additional `Podfile` changes are needed; the package ships its own
///    podspec.
///
/// ## Android integration (TODO for Integrate agent)
/// 1. The package already adds the `RECEIVE_BOOT_COMPLETED` permission and the
///    `BroadcastReceiver` entries via its own `AndroidManifest.xml`, so
///    **no manual `AndroidManifest.xml` edits are needed for basic use**.
/// 2. For Android 13+ (API 33+), runtime notification permission is requested
///    via [NotificationsService.requestPermission].  The package handles the
///    `POST_NOTIFICATIONS` permission declaration automatically on AGP 8+.
/// 3. If targeting Android 12+ (API 31+) and you want exact-alarm scheduling,
///    add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
///    ```xml
///    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
///    ```
///    and inside `<application>` add the service entry the package requires for
///    exact alarms:
///    ```xml
///    <receiver android:exported="false"
///              android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
///    ```
///    (The package docs at pub.dev/packages/flutter_local_notifications have the
///    full snippet — copy from there to stay in sync with the package version.)
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// ── Singleton plugin instance ─────────────────────────────────────────────────

final _plugin = FlutterLocalNotificationsPlugin();

// ── Android channel ───────────────────────────────────────────────────────────

const _studyChannelId = 'admity_study';
const _studyChannelName = 'Ежедневные напоминания';
const _studyChannelDesc =
    'Напоминания о ежедневной учёбе и предстоящих событиях';

// ── Service ───────────────────────────────────────────────────────────────────

/// Static facade over [FlutterLocalNotificationsPlugin].
///
/// Call [init] once in `bootstrap.dart`, then use the other static methods
/// anywhere in the app.  Every method is safe to call before [init] finishes —
/// it catches the resulting state error and swallows it.
class NotificationsService {
  // Pure-static class — prevent external instantiation.
  const NotificationsService._();

  /// Singleton handle — useful when you need an object reference (e.g. for
  /// provider injection).  All behaviour is via static methods.
  static const instance = NotificationsService._();

  static bool _ready = false;

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  /// Initialises timezone data and the plugin for iOS + Android.
  ///
  /// Uses a fixed zone (`Asia/Almaty`) to avoid `initializeDateFormatting`
  /// crashes (see CLAUDE.md §Dates).  Must be awaited before the app calls
  /// any other method on this service.
  static Future<void> init() async {
    try {
      // Timezone setup — fixed to Asia/Almaty to avoid locale-init crashes.
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Almaty'));

      // Android: create notification channel.
      const androidChannel = AndroidNotificationChannel(
        _studyChannelId,
        _studyChannelName,
        description: _studyChannelDesc,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // Initialise the plugin itself.
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(initSettings);
      _ready = true;
    } on Object catch (e, st) {
      debugPrint('[NotificationsService] init failed: $e\n$st');
    }
  }

  // ── Permissions ─────────────────────────────────────────────────────────────

  /// Requests notification permission from the OS.
  ///
  /// Returns `true` if permission was granted (or was already granted).
  /// Returns `false` if the plugin is not ready or permission was denied.
  static Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      // iOS / macOS.
      final iosResult = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      if (iosResult != null) return iosResult;

      // Android 13+.
      final androidResult = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      if (androidResult != null) return androidResult;

      // Other platforms — assume granted.
      return true;
    } on Object catch (e) {
      debugPrint('[NotificationsService] requestPermission failed: $e');
      return false;
    }
  }

  // ── Scheduling ──────────────────────────────────────────────────────────────

  /// Schedules a repeating daily notification at [hour]:[minute] (local time,
  /// Asia/Almaty).
  ///
  /// [id] must be unique per notification slot.  The notification repeats
  /// daily via [DateTimeComponents.time] matching.
  static Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    try {
      final scheduledTime = _nextInstanceOfTime(hour, minute);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _studyChannelId,
            _studyChannelName,
            channelDescription: _studyChannelDesc,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on Object catch (e) {
      debugPrint('[NotificationsService] scheduleDailyReminder failed: $e');
    }
  }

  /// Shows a notification immediately (for due-now items).
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _studyChannelId,
            _studyChannelName,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } on Object catch (e) {
      debugPrint('[NotificationsService] showNow failed: $e');
    }
  }

  /// Cancels all scheduled and delivered notifications.
  static Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } on Object catch (e) {
      debugPrint('[NotificationsService] cancelAll failed: $e');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Returns the next [tz.TZDateTime] for [hour]:[minute] in Asia/Almaty.
  ///
  /// If today's occurrence is in the past (or within the next 10 seconds to
  /// avoid same-second firing), returns tomorrow's occurrence.
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final almatyZone = tz.getLocation('Asia/Almaty');
    final now = tz.TZDateTime.now(almatyZone);
    var scheduled = tz.TZDateTime(
      almatyZone,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now.add(const Duration(seconds: 10)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
