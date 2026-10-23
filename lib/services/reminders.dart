import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Jadwal pengingat latihan mingguan.
class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.weekdays,
  });

  /// Hari bawaan mengikuti target mingguan, dengan jeda di antaranya.
  factory ReminderSettings.defaultsFor(int weeklyTargetDays) =>
      ReminderSettings(
        enabled: false,
        hour: 17,
        minute: 0,
        weekdays: switch (weeklyTargetDays) {
          <= 1 => {DateTime.wednesday},
          2 => {DateTime.tuesday, DateTime.friday},
          3 => {DateTime.monday, DateTime.wednesday, DateTime.friday},
          4 => {
            DateTime.monday,
            DateTime.tuesday,
            DateTime.thursday,
            DateTime.friday,
          },
          5 => {for (var d = DateTime.monday; d <= DateTime.friday; d++) d},
          6 => {for (var d = DateTime.monday; d <= DateTime.saturday; d++) d},
          _ => {for (var d = DateTime.monday; d <= DateTime.sunday; d++) d},
        },
      );

  final bool enabled;
  final int hour;
  final int minute;

  /// 1 = Senin … 7 = Minggu (sama dengan [DateTime.weekday]).
  final Set<int> weekdays;

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    Set<int>? weekdays,
  }) => ReminderSettings(
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    weekdays: weekdays ?? this.weekdays,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'hour': hour,
    'minute': minute,
    'weekdays': (weekdays.toList()..sort()),
  };

  factory ReminderSettings.fromJson(Map<String, dynamic> json) =>
      ReminderSettings(
        enabled: json['enabled'] as bool,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        weekdays: {for (final d in json['weekdays'] as List<dynamic>) d as int},
      );
}

/// Pemasang notifikasi. Dipisah supaya tes tidak butuh plugin.
abstract class ReminderScheduler {
  /// Minta izin notifikasi (Android 13+). true jika diizinkan.
  Future<bool> requestPermission();

  /// Ganti semua jadwal dengan [settings].
  Future<void> apply(ReminderSettings settings);
}

class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> apply(ReminderSettings settings) async {}
}

/// Notifikasi lokal mingguan lewat flutter_local_notifications.
class LocalReminderScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'pengingat_latihan',
      'Pengingat latihan',
      channelDescription: 'Pengingat di hari dan jam latihan yang kamu pilih',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(_deviceLocation());
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
        ),
      );
      _ready = true;
    } catch (_) {
      // Platform tanpa dukungan notifikasi; pengingat dinonaktifkan.
    }
  }

  /// Lokasi zona waktu dengan offset sama seperti HP. Indonesia tidak
  /// memakai DST, jadi pencocokan offset sudah tepat.
  static tz.Location _deviceLocation() {
    final offset = DateTime.now().timeZoneOffset.inMilliseconds;
    const preferred = ['Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura'];
    final now = DateTime.now().millisecondsSinceEpoch;
    bool matches(tz.Location l) => l.timeZone(now).offset == offset;
    for (final name in preferred) {
      final location = tz.getLocation(name);
      if (matches(location)) return location;
    }
    for (final location in tz.timeZoneDatabase.locations.values) {
      if (matches(location)) return location;
    }
    return tz.UTC;
  }

  @override
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> apply(ReminderSettings settings) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      if (!settings.enabled) return;
      for (final day in settings.weekdays) {
        await _plugin.zonedSchedule(
          day,
          'Waktunya latihan',
          'Latihan hari ini sudah menunggu. Ketuk untuk mulai.',
          _next(day, settings.hour, settings.minute),
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (_) {
      // Gagal memasang jadwal (mis. izin dicabut); tidak menghentikan app.
    }
  }

  static tz.TZDateTime _next(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (at.weekday != weekday || !at.isAfter(now)) {
      at = tz.TZDateTime(tz.local, at.year, at.month, at.day + 1, hour, minute);
    }
    return at;
  }
}
