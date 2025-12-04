import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/sleep_providers.dart';
import '../../../../domain/entities/sleep_models.dart';
import '../../../../domain/logic/sleep_calculator.dart';
import '../../../shared/molecules/bento_card.dart';
import '../../../shared/molecules/glass_modal.dart';

class NightTab extends ConsumerStatefulWidget {
  const NightTab({super.key});

  @override
  ConsumerState<NightTab> createState() => _NightTabState();
}

class _NightTabState extends ConsumerState<NightTab> {
  SleepCycleResult? selectedResult;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepProvider);
    final notifier = ref.read(sleepProvider.notifier);
    final chronotypes = SleepCalculator.getChronotypes();

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chronotype Section
              BentoCard(
                padding: const EdgeInsets.all(12),
                color: AppTheme.surface.withValues(alpha: 0.4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.user,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "CRONOTIPO",
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ],
                        ),
                        Text(
                          chronotypes
                              .firstWhere((c) => c.id == state.chronotype)
                              .desc,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: chronotypes
                          .map(
                            (c) => Expanded(
                              child: GestureDetector(
                                onTap: () => notifier.setChronotype(c.id),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: state.chronotype == c.id
                                        ? AppTheme.secondary
                                        : AppTheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: state.chronotype == c.id
                                          ? AppTheme.secondary
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        c.emoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: state.chronotype == c.id
                                              ? Colors.white
                                              : AppTheme.textSecondary,
                                          fontWeight: state.chronotype == c.id
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Time Selector
              BentoCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeButton(
                              label: "Despertar a las...",
                              isActive: state.mode == 'wake',
                              onTap: () => notifier.setMode('wake'),
                            ),
                          ),
                          Expanded(
                            child: _ModeButton(
                              label: "Dormir Ahora",
                              isActive: state.mode == 'sleep',
                              onTap: () => notifier.setMode('sleep'),
                              icon: state.mode == 'sleep'
                                  ? LucideIcons.clock
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: state.time,
                          builder: (context, child) {
                            return Theme(
                              data: AppTheme.darkTheme.copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppTheme.primary,
                                  surface: AppTheme.surface,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) notifier.setTime(picked);
                      },
                      child: Text(
                        "${state.time.hour.toString().padLeft(2, '0')}:${state.time.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                    if (state.mode == 'sleep')
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Hora actual seleccionada autom.",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Factors
              Row(
                children: [
                  _FactorButton(
                    id: 'caffeine',
                    icon: LucideIcons.coffee,
                    label: 'Café',
                    time: '+25',
                    isActive: state.factors['caffeine']!,
                    onTap: () => notifier.toggleFactor('caffeine'),
                  ),
                  const SizedBox(width: 8),
                  _FactorButton(
                    id: 'blueLight',
                    icon: LucideIcons.smartphone,
                    label: 'Luz',
                    time: '+15',
                    isActive: state.factors['blueLight']!,
                    onTap: () => notifier.toggleFactor('blueLight'),
                  ),
                  const SizedBox(width: 8),
                  _FactorButton(
                    id: 'exercise',
                    icon: LucideIcons.activity,
                    label: 'Gym',
                    time: '+15',
                    isActive: state.factors['exercise']!,
                    onTap: () => notifier.toggleFactor('exercise'),
                  ),
                  const SizedBox(width: 8),
                  _FactorButton(
                    id: 'stress',
                    icon: LucideIcons.wind,
                    label: 'Stress',
                    time: '+30',
                    isActive: state.factors['stress']!,
                    onTap: () => notifier.toggleFactor('stress'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Results
              const Text(
                "👇 Toca una tarjeta para ver análisis",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ...state.results.map(
                (res) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResultCard(
                    result: res,
                    onTap: () => setState(() => selectedResult = res),
                  ),
                ),
              ),
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),

        // Scientific Modal
        if (selectedResult != null)
          GlassModal(
            onClose: () => setState(() => selectedResult = null),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => setState(() => selectedResult = null),
                    child: const Icon(
                      LucideIcons.x,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.surfaceHighlight),
                  ),
                  child: Icon(
                    selectedResult!.science.icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  selectedResult!.label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "${selectedResult!.cycles} Ciclos (${selectedResult!.cycles * 1.5} horas)",
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontFamily: 'Monospace',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "BENEFICIOS",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...selectedResult!.science.benefits.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "✓",
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            b,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.surfaceHighlight.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "RECOMENDADO PARA:",
                        style: TextStyle(
                          color: AppTheme.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedResult!.science.bestFor,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      notifier.navigateToAlarm(selectedResult!.wakeTime);
                      setState(() => selectedResult = null);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.alarmClock, size: 18),
                        SizedBox(width: 8),
                        Text("Configurar Alarma"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.surfaceHighlight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactorButton extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final String time;
  final bool isActive;
  final VoidCallback onTap;

  const _FactorButton({
    required this.id,
    required this.icon,
    required this.label,
    required this.time,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primary.withValues(alpha: 0.2)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppTheme.primary.withValues(alpha: 0.5)
                  : AppTheme.surfaceHighlight,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? AppTheme.primary.withValues(alpha: 0.8)
                    : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isActive)
                Text(
                  "$time m",
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.primary,
                    fontFamily: 'Monospace',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final SleepCycleResult result;
  final VoidCallback onTap;

  const _ResultCard({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Monochrome accents (shades of white/grey)
    Color accentColor;
    if (result.quality == SleepQuality.optimal) {
      accentColor = Colors.white;
    } else if (result.quality == SleepQuality.clash) {
      accentColor = Colors.grey.shade600;
    } else {
      accentColor = Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.surfaceHighlight.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat.Hm().format(result.wakeTime),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            result.shortDesc,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                result.label,
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                LucideIcons.arrowRight,
                                size: 14,
                                color: accentColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceHighlight,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppTheme.surfaceHighlight,
                              ),
                            ),
                            child: Text(
                              result.chronoMessage,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
