import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/alarm_provider.dart';
import '../../../providers/sleep_providers.dart';
import '../../../shared/molecules/bento_card.dart';

class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key});

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> {
  DateTime? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final autoTime = ref.read(sleepProvider).selectedAlarmTime;
    if (autoTime != null) {
      _selectedTime = autoTime;
    } else {
      final now = DateTime.now();
      _selectedTime = DateTime(now.year, now.month, now.day, 7, 0);
      if (_selectedTime!.isBefore(now)) {
        _selectedTime = _selectedTime!.add(const Duration(days: 1));
      }
    }
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permisos de notificación requeridos.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        openAppSettings();
      }
      return;
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final initialTime = _selectedTime ?? now;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  const Text(
                    'Seleccionar Hora',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Listo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDateTime) {
                    final newTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      newDateTime.hour,
                      newDateTime.minute,
                    );

                    if (newTime.isBefore(now)) {
                      setState(() {
                        _selectedTime = newTime.add(const Duration(days: 1));
                      });
                    } else {
                      setState(() {
                        _selectedTime = newTime;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAlarm() async {
    if (_selectedTime == null) return;
    setState(() => _isLoading = true);

    await _checkPermissions();

    await ref.read(alarmListProvider.notifier).addAlarm(_selectedTime!);

    if (mounted) {
      final now = DateTime.now();
      final diff = _selectedTime!.difference(now);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;

      String message = 'Alarma configurada para dentro de ';
      if (hours > 0) message += '$hours h ';
      message += '$minutes min';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.surfaceHighlight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final alarms = ref.watch(alarmListProvider);
    final notifier = ref.read(alarmListProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Configurar Alarma",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Big Clock & Save Button
              GestureDetector(
                onTap: _pickTime,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        _selectedTime != null
                            ? DateFormat('HH:mm').format(_selectedTime!)
                            : "--:--",
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedTime != null
                            ? DateFormat(
                                'EEEE, d MMMM',
                                'es',
                              ).format(_selectedTime!)
                            : "Seleccionar hora",
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              BentoCard(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAlarm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.alarmClock),
                              SizedBox(width: 8),
                              Text("Guardar Alarma"),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                "Mis Alarmas",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Alarm List
              Expanded(
                child: alarms.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay alarmas guardadas",
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: alarms.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final alarm = alarms[index];
                          return Dismissible(
                            key: Key(alarm.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                LucideIcons.trash2,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              notifier.deleteAlarm(alarm.id);
                            },
                            child: BentoCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'HH:mm',
                                          ).format(alarm.time),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: alarm.isEnabled
                                                ? Colors.white
                                                : AppTheme.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          alarm.label,
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: alarm.isEnabled,
                                    activeTrackColor: AppTheme.primary,
                                    onChanged: (value) {
                                      notifier.toggleAlarm(alarm.id);

                                      if (value) {
                                        final now = DateTime.now();
                                        var alarmTime = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          alarm.time.hour,
                                          alarm.time.minute,
                                        );
                                        if (alarmTime.isBefore(now)) {
                                          alarmTime = alarmTime.add(
                                            const Duration(days: 1),
                                          );
                                        }

                                        final diff = alarmTime.difference(now);
                                        final hours = diff.inHours;
                                        final minutes = diff.inMinutes % 60;

                                        String message = 'Sonará en ';
                                        if (hours > 0) message += '$hours h ';
                                        message += '$minutes min';

                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(message),
                                            backgroundColor:
                                                AppTheme.surfaceHighlight,
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Alarma desactivada'),
                                            backgroundColor:
                                                AppTheme.surfaceHighlight,
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    onPressed: () =>
                                        notifier.deleteAlarm(alarm.id),
                                    icon: const Icon(
                                      LucideIcons.trash2,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
