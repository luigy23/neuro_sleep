import 'dart:convert';

class AlarmItem {
  final int id;
  final DateTime time;
  final String label;
  final bool isEnabled;

  AlarmItem({
    required this.id,
    required this.time,
    this.label = 'Alarma',
    this.isEnabled = true,
  });

  AlarmItem copyWith({
    int? id,
    DateTime? time,
    String? label,
    bool? isEnabled,
  }) {
    return AlarmItem(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'label': label,
      'isEnabled': isEnabled,
    };
  }

  factory AlarmItem.fromMap(Map<String, dynamic> map) {
    return AlarmItem(
      id: map['id'],
      time: DateTime.parse(map['time']),
      label: map['label'],
      isEnabled: map['isEnabled'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AlarmItem.fromJson(String source) =>
      AlarmItem.fromMap(json.decode(source));
}
