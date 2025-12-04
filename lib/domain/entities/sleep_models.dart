import 'package:flutter/material.dart';

enum SleepQuality { optimal, good, clash }
enum NapType { good, optimal, bad }

class SleepCycleResult {
  final DateTime wakeTime;
  final int cycles;
  final String label;
  final String shortDesc;
  final SleepQuality quality;
  final String chronoMessage;
  final ScientificDetails science;

  SleepCycleResult({
    required this.wakeTime,
    required this.cycles,
    required this.label,
    required this.shortDesc,
    required this.quality,
    required this.chronoMessage,
    required this.science,
  });
}

class ScientificDetails {
  final List<String> benefits;
  final List<String> drawbacks;
  final String bestFor;
  final IconData icon;

  ScientificDetails({
    required this.benefits,
    required this.drawbacks,
    required this.bestFor,
    required this.icon,
  });
}

class NapOption {
  final int minutes;
  final String label;
  final String desc;
  final NapType type;
  final String risk;
  final DateTime wakeTime;

  NapOption({
    required this.minutes,
    required this.label,
    required this.desc,
    required this.type,
    required this.risk,
    required this.wakeTime,
  });
}

class ChronotypeInfo {
  final String id;
  final String label;
  final String desc;
  final String emoji;
  final List<int> optimalWake;

  ChronotypeInfo({
    required this.id,
    required this.label,
    required this.desc,
    required this.emoji,
    required this.optimalWake,
  });
}
