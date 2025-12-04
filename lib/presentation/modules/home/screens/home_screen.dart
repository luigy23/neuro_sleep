import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/sleep_providers.dart';
import '../widgets/calculator_view.dart';
import '../widgets/nav_bar_item.dart';
import 'package:alarm/alarm.dart';
import '../../alarm/screens/alarm_ring_screen.dart';
import '../../alarm/screens/alarm_screen.dart';
import '../../../shared/organisms/timer_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  StreamSubscription<AlarmSettings>? _alarmSubscription;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ref.read(sleepProvider.notifier).tickTimer();
    });

    _alarmSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlarmRingScreen(alarmSettings: alarmSettings),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _alarmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepProvider);
    final notifier = ref.read(sleepProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Main Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.mainTab == 'alarm'
                ? const AlarmScreen()
                : const CalculatorView(),
          ),

          // Floating Navbar
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHighlight.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NavBarItem(
                      icon: LucideIcons.calculator,
                      label: "Calculadora",
                      isActive: state.mainTab == 'calculator',
                      onTap: notifier.navigateToCalculator,
                    ),
                    const SizedBox(width: 8),
                    NavBarItem(
                      icon: LucideIcons.alarmClock,
                      label: "Alarma",
                      isActive: state.mainTab == 'alarm',
                      onTap: () => notifier.navigateToAlarm(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Timer Modal Overlay
          if (state.activeTimer != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.activeTimer!.label,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (state.activeTimer!.isFinished)
                        const Text(
                          "¡Hora de despertar!",
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      else
                        Text.rich(
                          TextSpan(
                            text:
                                "Incluye ${state.activeTimer!.napMinutes}m siesta + ",
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: "${state.effectiveLatency}m latencia",
                                style: const TextStyle(color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 40),
                      CircularTimer(
                        totalSeconds: state.activeTimer!.totalSeconds,
                        remainingSeconds: state.activeTimer!.remainingSeconds,
                        isFinished: state.activeTimer!.isFinished,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!state.activeTimer!.isFinished)
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: FloatingActionButton(
                                onPressed: notifier.toggleTimer,
                                backgroundColor: AppTheme.surfaceHighlight,
                                foregroundColor: Colors.white,
                                child: Icon(
                                  state.activeTimer!.isRunning
                                      ? LucideIcons.pause
                                      : LucideIcons.play,
                                ),
                              ),
                            ),
                          FloatingActionButton(
                            onPressed: notifier.resetTimer,
                            backgroundColor: AppTheme.surfaceHighlight,
                            foregroundColor: AppTheme.primary,
                            child: Icon(
                              state.activeTimer!.isFinished
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.rotateCcw,
                            ),
                          ),
                        ],
                      ),
                      if (!state.activeTimer!.isFinished &&
                          state.activeTimer!.isRunning)
                        const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Text(
                            "Deja el móvil, cierra los ojos y relájate...",
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
        ],
      ),
    );
  }
}
