import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/sleep_providers.dart';
import 'night_tab.dart';
import 'nap_tab.dart';
import 'tab_button.dart';

class CalculatorView extends ConsumerWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sleepProvider);
    final notifier = ref.read(sleepProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.moon,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            children: const [
                              TextSpan(text: 'Neuro'),
                              TextSpan(
                                text: 'Sueño',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: ' v5.0',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      TabButton(
                        label: 'Noche',
                        isActive: state.activeTab == 'night',
                        onTap: () => notifier.setActiveTab('night'),
                      ),
                      TabButton(
                        label: 'Siesta',
                        isActive: state.activeTab == 'nap',
                        onTap: () => notifier.setActiveTab('nap'),
                        isAccent: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: state.activeTab == 'night'
                    ? const NightTab()
                    : const NapTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
