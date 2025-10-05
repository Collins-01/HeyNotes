import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/extension/extension.dart';
import 'package:hey_notes/providers/theme_provider.dart';

class ThemeOption extends ConsumerWidget {
  final String title;
  final IconData icon;
  final AppThemeMode mode;
  final AppThemeMode currentMode;
  final Color activeColor;
  final Color inactiveColor;

  const ThemeOption({
    super.key,
    required this.title,
    required this.icon,
    required this.mode,
    required this.currentMode,
    this.activeColor = AppColors.black,
    this.inactiveColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = currentMode == mode;
    final screenWidth = MediaQuery.of(context).size.width;
    const padding = UIHelpers.scaffoldPadding * 2;
    const gap = UIHelpers.md * 2; // Gap between items
    final itemWidth =
        (screenWidth - padding - gap * 2) / 3; // 3 items with gaps

    return GestureDetector(
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      child: Container(
        width: itemWidth,
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: UIHelpers.sm),
        decoration: BoxDecoration(
          color: isActive ? activeColor : inactiveColor,
          border: Border.all(
            color: isActive ? activeColor : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: activeColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.black87,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class AppearancePage extends ConsumerStatefulWidget {
  static const String routeName = '/appearance';
  const AppearancePage({super.key});

  @override
  ConsumerState<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends ConsumerState<AppearancePage> {
  @override
  Widget build(BuildContext context) {
    final themeModeNotifier = ref.watch(themeModeProvider.notifier);
    final currentThemeMode = themeModeNotifier.getCurrentAppThemeMode();

    return Scaffold(
      appBar: AppBar(
        title: SlideInLeft(
          child: Text(
            'Appearance',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIHelpers.scaffoldPadding,
          vertical: UIHelpers.md,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ThemeOption(
                  title: 'System',
                  icon: Icons.brightness_auto,
                  mode: AppThemeMode.system,
                  currentMode: currentThemeMode,
                  activeColor: Colors.blue,
                ),
                const SizedBox(width: 12),
                ThemeOption(
                  title: 'Light',
                  icon: Icons.light_mode_outlined,
                  mode: AppThemeMode.light,
                  currentMode: currentThemeMode,
                  activeColor: Colors.blue,
                ),
                const SizedBox(width: 12),
                ThemeOption(
                  title: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  mode: AppThemeMode.dark,
                  currentMode: currentThemeMode,
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
