import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hey_notes/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/screens/home_screen.dart';
import 'package:hey_notes/screens/note_edit_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Box<Note> noteBox;

  // Set up Hive for testing
  setUpAll(() async {
    Hive.init('test/hive');
    Hive.registerAdapter(NoteAdapter());
    noteBox = await Hive.openBox<Note>('notes');
  });

  // Clear Hive box after each test
  tearDown(() async {
    await noteBox.clear();
  });

  // Close Hive after all tests
  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App launches and shows home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Create and view a note', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    // Tap the FAB to create a new note
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify we're on the edit screen
    expect(find.byType(NoteEditScreen), findsOneWidget);

    // Enter note details
    await tester.enterText(find.byType(TextFormField).first, 'Test Note');
    await tester.enterText(
      find.byType(TextFormField).last,
      'This is a test note',
    );

    // Save the note
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify we're back on the home screen and note is visible
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Test Note'), findsOneWidget);
  });

  testWidgets('Search functionality', (WidgetTester tester) async {
    // Add a test note
    final testNote = Note(
      title: 'Test Search Note',
      content: 'This note should be searchable',
      tags: ['test', 'search'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      id: 'test_note_id',
    );
    await noteBox.add(testNote);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    // Find and tap the search field
    await tester.tap(find.byType(SearchBar));
    await tester.pumpAndSettle();

    // Enter search query
    await tester.enterText(find.byType(TextField), 'searchable');
    await tester.pumpAndSettle();

    // Verify the note is found
    expect(find.text('Test Search Note'), findsOneWidget);
  });

  testWidgets('Theme switching', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    // Find and tap the theme switcher
    await tester.tap(find.byIcon(Icons.brightness_4));
    await tester.pumpAndSettle();

    // Verify the theme has changed (this is a simple check, might need adjustment)
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, isNotNull);
  });
}
