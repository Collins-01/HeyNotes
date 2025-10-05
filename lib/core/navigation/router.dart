import 'package:flutter/material.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/screens/home/homepage/home_screen.dart';
import 'package:hey_notes/screens/home/settings_page.dart';
import 'package:hey_notes/screens/notes_page/create_edit_notes.dart/create_edit_note_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case CreateEditNoteScreen.routeName:
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
