import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sleep_models.dart';
import '../../domain/logic/sleep_calculator.dart';

class SleepState {
  final String activeTab; // 'night' | 'nap'
  final String mode; // 'wake' | 'sleep'
  final TimeOfDay time;
  final int baseLatency;
  final int effectiveLatency;
  final String chronotype;
  final Map<String, bool> factors;
  final List<SleepCycleResult> results;
  final List<NapOption> napResults;
  final NapTimerState? activeTimer;
  final String mainTab; // 'calculator' | 'alarm'
  final DateTime? selectedAlarmTime;

  SleepState({
    this.activeTab = 'night',
    this.mode = 'wake',
    required this.time,
    this.baseLatency = 15,
    this.effectiveLatency = 15,
    this.chronotype = 'bear',
    this.factors = const {
      'caffeine': false,
      'exercise': false,
      'blueLight': true,
      'stress': false,
    },
    this.results = const [],
    this.napResults = const [],
    this.activeTimer,
    this.mainTab = 'calculator',
    this.selectedAlarmTime,
  });

  SleepState copyWith({
    String? activeTab,
    String? mode,
    TimeOfDay? time,
    int? baseLatency,
    int? effectiveLatency,
    String? chronotype,
    Map<String, bool>? factors,
    List<SleepCycleResult>? results,
    List<NapOption>? napResults,
    NapTimerState? activeTimer,
    bool clearTimer = false,
    String? mainTab,
    DateTime? selectedAlarmTime,
    bool clearAlarmTime = false,
  }) {
    return SleepState(
      activeTab: activeTab ?? this.activeTab,
      mode: mode ?? this.mode,
      time: time ?? this.time,
      baseLatency: baseLatency ?? this.baseLatency,
      effectiveLatency: effectiveLatency ?? this.effectiveLatency,
      chronotype: chronotype ?? this.chronotype,
      factors: factors ?? this.factors,
      results: results ?? this.results,
      napResults: napResults ?? this.napResults,
      activeTimer: clearTimer ? null : (activeTimer ?? this.activeTimer),
      mainTab: mainTab ?? this.mainTab,
      selectedAlarmTime: clearAlarmTime
          ? null
          : (selectedAlarmTime ?? this.selectedAlarmTime),
    );
  }
}

class NapTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final String label;
  final int napMinutes;
  final bool isFinished;

  NapTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
    required this.label,
    required this.napMinutes,
    this.isFinished = false,
  });

  NapTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    String? label,
    int? napMinutes,
    bool? isFinished,
  }) {
    return NapTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      label: label ?? this.label,
      napMinutes: napMinutes ?? this.napMinutes,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class SleepNotifier extends StateNotifier<SleepState> {
  SleepNotifier()
    : super(SleepState(time: const TimeOfDay(hour: 7, minute: 0))) {
    calculateEffectiveLatency();
    calculateResults();
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
    calculateResults();
  }

  void setMode(String mode) {
    state = state.copyWith(mode: mode);
    if (mode == 'sleep') {
      state = state.copyWith(time: TimeOfDay.now());
    }
    calculateResults();
  }

  void setTime(TimeOfDay time) {
    state = state.copyWith(time: time);
    calculateResults();
  }

  void setChronotype(String chronotype) {
    state = state.copyWith(chronotype: chronotype);
    calculateResults();
  }

  void toggleFactor(String factor) {
    final newFactors = Map<String, bool>.from(state.factors);
    newFactors[factor] = !(newFactors[factor] ?? false);
    state = state.copyWith(factors: newFactors);
    calculateEffectiveLatency();
    calculateResults();
  }

  void calculateEffectiveLatency() {
    int extra = 0;
    if (state.factors['caffeine'] == true) extra += 25;
    if (state.factors['blueLight'] == true) extra += 15;
    if (state.factors['exercise'] == true) extra += 15;
    if (state.factors['stress'] == true) extra += 30;
    state = state.copyWith(effectiveLatency: state.baseLatency + extra);
  }

  void calculateResults() {
    if (state.activeTab == 'night') {
      final results = SleepCalculator.calculateNightCycles(
        targetTime: state.time,
        mode: state.mode,
        effectiveLatency: state.effectiveLatency,
        chronotypeId: state.chronotype,
      );
      state = state.copyWith(results: results);
    } else {
      final naps = SleepCalculator.calculateNaps(state.effectiveLatency);
      state = state.copyWith(napResults: naps);
    }
  }

  // Timer Logic
  void startNapTimer(int napMinutes, String label) {
    final totalMinutes = napMinutes + state.effectiveLatency;
    final totalSeconds = totalMinutes * 60;
    state = state.copyWith(
      activeTimer: NapTimerState(
        totalSeconds: totalSeconds,
        remainingSeconds: totalSeconds,
        isRunning: true,
        label: label,
        napMinutes: napMinutes,
      ),
    );
  }

  void tickTimer() {
    if (state.activeTimer != null && state.activeTimer!.isRunning) {
      if (state.activeTimer!.remainingSeconds <= 0) {
        state = state.copyWith(
          activeTimer: state.activeTimer!.copyWith(
            isRunning: false,
            remainingSeconds: 0,
            isFinished: true,
          ),
        );
      } else {
        state = state.copyWith(
          activeTimer: state.activeTimer!.copyWith(
            remainingSeconds: state.activeTimer!.remainingSeconds - 1,
          ),
        );
      }
    }
  }

  void toggleTimer() {
    if (state.activeTimer != null) {
      state = state.copyWith(
        activeTimer: state.activeTimer!.copyWith(
          isRunning: !state.activeTimer!.isRunning,
        ),
      );
    }
  }

  void resetTimer() {
    state = state.copyWith(clearTimer: true);
  }

  // Navigation Logic
  void navigateToAlarm([DateTime? time]) {
    state = state.copyWith(
      mainTab: 'alarm',
      selectedAlarmTime: time,
      clearAlarmTime: time == null,
    );
  }

  void navigateToCalculator() {
    state = state.copyWith(mainTab: 'calculator');
  }
}

final sleepProvider = StateNotifierProvider<SleepNotifier, SleepState>((ref) {
  return SleepNotifier();
});
