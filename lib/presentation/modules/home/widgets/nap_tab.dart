import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/sleep_providers.dart';
import '../../../../domain/entities/sleep_models.dart';
import '../../../shared/molecules/bento_card.dart';

class NapTab extends ConsumerWidget {
  const NapTab({super.key});

  Future<void> _scheduleAlarm(DateTime wakeTime, String label) async {
    // Check permissions
    if (await Permission.notification.request().isGranted) {
      final alarmSettings = AlarmSettings(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        dateTime: wakeTime,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        volumeSettings: VolumeSettings.fade(
          volume: 0.8,
          fadeDuration: const Duration(seconds: 3),
          volumeEnforced: false,
        ),
        notificationSettings: NotificationSettings(
          title: 'NeuroSueño',
          body: 'Hora de despertar: $label',
          stopButton: 'Detener',
          icon: 'notification_icon',
        ),
      );
      await Alarm.set(alarmSettings: alarmSettings);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sleepProvider);
    final notifier = ref.read(sleepProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.surfaceHighlight, AppTheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.surfaceHighlight),
            ),
            child: Column(
              children: [
                const Text(
                  "Power Nap Lab",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.clock,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text.rich(
                      TextSpan(
                        text: "Latencia incluida en timer: ",
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "${state.effectiveLatency} min",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Nap Options
          ...state.napResults.map(
            (nap) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BentoCard(
                color: nap.type == NapType.bad
                    ? AppTheme.surface.withValues(alpha: 0.5)
                    : AppTheme.surface,
                border: nap.type == NapType.bad
                    ? BorderSide(
                        color: AppTheme.surfaceHighlight.withValues(alpha: 0.3),
                      )
                    : null,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    nap.label,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (nap.type == NapType.good)
                                    _Tag(
                                      label: "RECOMENDADO",
                                      color: Colors.white,
                                    )
                                  else if (nap.type == NapType.bad)
                                    _Tag(
                                      label: "INERCIA ALTA",
                                      color: Colors.grey,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nap.desc,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: "${nap.minutes}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "m",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              "Duración",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (nap.type != NapType.bad)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            notifier.startNapTimer(nap.minutes, nap.label);
                            // Optional: Schedule system alarm
                            _scheduleAlarm(nap.wakeTime, nap.label);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.play, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Iniciar Timer (${nap.minutes + state.effectiveLatency} min)",
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHighlight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.surfaceHighlight),
                        ),
                        child: const Text(
                          "No recomendado: Despertarías aturdido",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
