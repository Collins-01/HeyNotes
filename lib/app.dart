import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/navigation/navigation.dart';
import 'package:hey_notes/core/theme/app_theme.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/providers/theme_provider.dart';
import 'package:hey_notes/screens/home/homepage/home_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use watch to listen to theme changes
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Hey Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: UIHelpers.mediumDuration,
      themeAnimationCurve: Curves.linear,
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: HomeScreen.routeName,
    );
  }
}
