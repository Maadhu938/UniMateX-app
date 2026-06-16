import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/local/hive_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

class SettingsService {
  Box<Map> get _metaBox => Hive.box<Map>(HiveService.metaBox);

  static const String _attendanceTargetKey = 'global_attendance_target';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  static const String _swipeTipSeenKey = 'swipe_tip_seen';

  bool get notificationsEnabled {
    final value = _metaBox.get(_notificationsEnabledKey);
    if (value != null && value.containsKey('value')) {
      return value['value'] as bool;
    }
    return false; // Default is disabled
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _metaBox.put(_notificationsEnabledKey, {'value': enabled});
  }

  bool get swipeTipSeen {
    final value = _metaBox.get(_swipeTipSeenKey);
    if (value != null && value.containsKey('value')) {
      return value['value'] as bool;
    }
    return false;
  }

  Future<void> setSwipeTipSeen(bool seen) async {
    await _metaBox.put(_swipeTipSeenKey, {'value': seen});
  }

  double get globalAttendanceTarget {
    final value = _metaBox.get(_attendanceTargetKey);
    if (value != null && value.containsKey('value')) {
      return value['value'] as double;
    }
    return 0.75; // Default is 75%
  }

  Future<void> setGlobalAttendanceTarget(double target) async {
    await _metaBox.put(_attendanceTargetKey, {'value': target});
  }
}

final globalAttendanceTargetProvider = Provider.autoDispose<double>((ref) {
  // We can't simply watch a hive box without a ValueListenableBuilder or Stream,
  // but since we only need to read it on mount or we can just invalidate it on change.
  // Actually, we can return a Future or just stream it.
  // For simplicity, we just return the value. When changed, we can invalidate this provider.
  return ref.watch(settingsServiceProvider).globalAttendanceTarget;
});

final notificationsEnabledProvider = StateProvider<bool>((ref) {
  return ref.watch(settingsServiceProvider).notificationsEnabled;
});
