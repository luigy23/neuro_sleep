import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/alarm.dart';
import 'core/theme/app_theme.dart';
import 'presentation/modules/home/screens/home_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Alarm.init();
  await initializeDateFormatting('es', null);

  runApp(const ProviderScope(child: NeuroSleepApp()));
}

class NeuroSleepApp extends StatelessWidget {
  const NeuroSleepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroSueño',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
