import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/navigation/navigation_service.dart';
import 'package:hey_notes/core/theme/app_theme.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/providers/theme_provider.dart';
import 'package:hey_notes/screens/home/homepage/home_screen.dart';
import 'package:hey_notes/screens/home/settings_page.dart';
import 'package:hey_notes/screens/notes_page/create_edit_notes.dart/create_edit_note_page.dart';

// Theme Provider is defined in theme_provider.dart

class AppRoutes {
  static const String home = '/';
  static const String noteView = '/view';
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

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use watch to listen to theme changes
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
  }
}
