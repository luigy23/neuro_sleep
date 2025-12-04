import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../entities/sleep_models.dart';

class SleepCalculator {
  static const Map<String, dynamic> chronotypes = {
    'lion': { "label": "León", "desc": "Matutino. Energía máxima al amanecer.", "optimalWake": [5, 6, 7], "emoji": "🦁" },
    'bear': { "label": "Oso", "desc": "Solar. Energía estable durante el día.", "optimalWake": [7, 8, 9], "emoji": "🐻" },
    'wolf': { "label": "Lobo", "desc": "Nocturno. Pico de energía tarde/noche.", "optimalWake": [9, 10, 11], "emoji": "🐺" },
    'dolphin': { "label": "Delfín", "desc": "Irregular. Sueño ligero y fragmentado.", "optimalWake": [6, 7], "emoji": "🐬" }
  };

  static List<ChronotypeInfo> getChronotypes() {
    return chronotypes.entries.map((e) => ChronotypeInfo(
      id: e.key,
      label: e.value['label'],
      desc: e.value['desc'],
      emoji: e.value['emoji'],
      optimalWake: List<int>.from(e.value['optimalWake']),
    )).toList();
  }

  static ScientificDetails getScientificDetails(int cycles) {
    if (cycles == 6) {
      return ScientificDetails(
        benefits: ["Máxima liberación de Hormona del Crecimiento.", "Reparación muscular completa.", "Limpieza profunda de toxinas cerebrales."],
        drawbacks: ["Puede causar 'borrachera de sueño' si no estás acostumbrado.", "Requiere mucha inversión de tiempo."],
        bestFor: "Atletas, Estudiantes, Enfermedad.",
        icon: LucideIcons.dumbbell,
      );
    }
    if (cycles == 5) {
      return ScientificDetails(
        benefits: ["Balance perfecto de fases REM y Sueño Profundo.", "Consolidación óptima de memoria.", "Estabilidad emocional."],
        drawbacks: ["Ninguno significativo. Es el estándar biológico."],
        bestFor: "Adultos sanos (18-64 años).",
        icon: LucideIcons.brain,
      );
    }
    return ScientificDetails(
      benefits: ["Permite funcionalidad básica.", "Útil para agendas apretadas."],
      drawbacks: ["Acumulación de deuda de sueño.", "Aumento de cortisol.", "Riesgo de antojos de azúcar."],
      bestFor: "Emergencias, Siestas muy largas.",
      icon: LucideIcons.heart,
    );
  }

  static String checkChronotypeAlignment(int wakeHour, String chronotypeId) {
    final optimal = List<int>.from(chronotypes[chronotypeId]['optimalWake']);
    if (optimal.contains(wakeHour)) return 'good';
    if (chronotypeId == 'wolf' && wakeHour < 8) return 'bad';
    if (chronotypeId == 'lion' && wakeHour > 9) return 'bad';
    return 'neutral';
  }

  static String getChronoMessage(String score) {
    if (score == 'good') return "Alineado con tu biología";
    if (score == 'bad') return "Desalineado (Jetlag Social)";
    return "Aceptable";
  }

  static List<SleepCycleResult> calculateNightCycles({
    required TimeOfDay targetTime,
    required String mode, // 'wake' or 'sleep'
    required int effectiveLatency,
    required String chronotypeId,
  }) {
    final now = DateTime.now();
    var refDate = DateTime(now.year, now.month, now.day, targetTime.hour, targetTime.minute);
    
    // If target time is in the past (e.g. 7:00 AM when it's 8:00 PM), assume next day for wake
    if (mode == 'wake' && refDate.isBefore(now)) {
      refDate = refDate.add(const Duration(days: 1));
    }

    final cyclesToCalc = [6, 5, 4];
    final List<SleepCycleResult> calculated = [];

    for (var cycles in cyclesToCalc) {
      final durationMinutes = cycles * 90;
      final totalAdj = durationMinutes + effectiveLatency;
      DateTime resultDate;

      if (mode == 'wake') {
        // Counting backwards from wake time
        resultDate = refDate.subtract(Duration(minutes: totalAdj));
      } else {
        // Counting forward from sleep time (now)
        // If mode is sleep, targetTime is usually 'now', but we use the refDate passed in
        resultDate = refDate.add(Duration(minutes: totalAdj));
      }

      // Determine wake hour for chronotype check
      // If mode is wake, wakeHour is targetTime.hour
      // If mode is sleep, wakeHour is resultDate.hour
      int wakeHour = mode == 'wake' ? targetTime.hour : resultDate.hour;
      String chronoScore = checkChronotypeAlignment(wakeHour, chronotypeId);

      calculated.push(SleepCycleResult(
        wakeTime: resultDate,
        cycles: cycles,
        label: cycles == 5 ? "Estándar de Oro" : cycles == 6 ? "Recuperación Total" : "Mínimo Funcional",
        shortDesc: cycles == 5 ? "7.5 horas de sueño" : cycles == 6 ? "9.0 horas de sueño" : "6.0 horas de sueño",
        quality: (cycles >= 5 && chronoScore == 'good') 
            ? SleepQuality.optimal 
            : (chronoScore == 'bad' ? SleepQuality.clash : SleepQuality.good),
        chronoMessage: getChronoMessage(chronoScore),
        science: getScientificDetails(cycles),
      ));
    }

    if (mode == 'wake') {
      calculated.sort((a, b) => b.cycles.compareTo(a.cycles));
    } else {
      calculated.sort((a, b) => a.cycles.compareTo(b.cycles));
    }
    
    return calculated;
  }

  static List<NapOption> calculateNaps(int effectiveLatency) {
    final now = DateTime.now();
    final napTypes = [
      { "min": 20, "label": "Power Nap", "desc": "Solo Fase 1 y 2. Alerta máxima.", "type": NapType.good, "risk": "Bajo" },
      { "min": 90, "label": "Ciclo Completo", "desc": "REM + Profundo. Creatividad.", "type": NapType.optimal, "risk": "Nulo" },
      { "min": 45, "label": "Zona de Peligro", "desc": "Despertarás en Sueño Profundo.", "type": NapType.bad, "risk": "Alto" }
    ];

    return napTypes.map((nap) {
      final minutes = nap['min'] as int;
      final wakeTime = now.add(Duration(minutes: minutes + effectiveLatency));
      return NapOption(
        minutes: minutes,
        label: nap['label'] as String,
        desc: nap['desc'] as String,
        type: nap['type'] as NapType,
        risk: nap['risk'] as String,
        wakeTime: wakeTime,
      );
    }).toList();
  }
}

extension ListPush<T> on List<T> {
  void push(T item) => add(item);
}
