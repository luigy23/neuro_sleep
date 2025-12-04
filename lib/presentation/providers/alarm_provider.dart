import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/alarm.dart';
import '../../domain/entities/alarm_item.dart';

final alarmListProvider =
    StateNotifierProvider<AlarmListNotifier, List<AlarmItem>>((ref) {
      return AlarmListNotifier();
    });

class AlarmListNotifier extends StateNotifier<List<AlarmItem>> {
  AlarmListNotifier() : super([]) {
    _loadAlarms();
  }

  static const String _storageKey = 'neuro_sleep_alarms';

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedAlarms = prefs.getStringList(_storageKey);

    if (storedAlarms != null) {
      state = storedAlarms.map((e) => AlarmItem.fromJson(e)).toList();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = state.map((e) => e.toJson()).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> addAlarm(DateTime time, {String label = 'Alarma'}) async {
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final newAlarm = AlarmItem(
      id: id,
      time: time,
      label: label,
      isEnabled: true,
    );

    state = [...state, newAlarm];
    await _saveToStorage();
    await _scheduleAlarm(newAlarm);
  }

  Future<void> toggleAlarm(int id) async {
    state = [
      for (final alarm in state)
        if (alarm.id == id)
          alarm.copyWith(isEnabled: !alarm.isEnabled)
        else
          alarm,
    ];
    await _saveToStorage();

    final alarm = state.firstWhere((element) => element.id == id);
    if (alarm.isEnabled) {
      await _scheduleAlarm(alarm);
    } else {
      await Alarm.stop(id);
    }
  }

  Future<void> deleteAlarm(int id) async {
    state = state.where((element) => element.id != id).toList();
    await _saveToStorage();
    await Alarm.stop(id);
  }

  Future<void> _scheduleAlarm(AlarmItem item) async {
    final alarmSettings = AlarmSettings(
      id: item.id,
      dateTime: item.time,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 1),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: 'NeuroSueño',
        body: item.label,
        stopButton: 'Detener',
        icon: 'notification_icon',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }
}
