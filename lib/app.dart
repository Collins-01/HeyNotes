import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/screens/home/settings_page.dart';
import 'core/navigation/navigation_service.dart';
import 'core/theme/app_theme.dart';
import 'models/note.dart';
import 'screens/home/homepage/home_screen.dart';
import 'screens/notes_page/note_view_screen.dart';

// Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

class AppRoutes {
  static const String home = '/';
  static const String noteView = '/view';
  static const String noteEdit = '/edit';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.noteView:
        final note = settings.arguments as Note?;
        if (note == null) {
          return _errorRoute('Note not found');
        }
        return MaterialPageRoute(
          builder: (_) => CreateEditNoteScreen(note: note),
        );

      case SettingsPage.routeName:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      default:
        return _errorRoute('Route not found');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text(message))),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeProvider);

        return MaterialApp(
          title: 'Hey Notes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          navigatorKey: NavigationService.navigatorKey,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRoutes.home,
        );
      },
    );
  }
}
