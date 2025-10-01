import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/screens/home_screen.dart';
import 'package:hey_notes/screens/note_edit_screen.dart';
import 'package:hey_notes/screens/note_view_screen.dart';
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

  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Create and view a note', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const HomeScreen(),
          routes: {
            '/edit': (context) => const NoteEditScreen(),
          },
        ),
      ),
    );

    // Wait for any initial loading to complete
    await tester.pumpAndSettle();

    // Tap the FAB to create a new note
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify we're on the edit screen
    expect(find.byType(NoteEditScreen), findsOneWidget);

    // Enter note details
    final titleField = find.byType(TextFormField).first;
    await tester.enterText(titleField, 'Test Note');
    
    final contentField = find.byType(TextFormField).last;
    await tester.enterText(contentField, 'This is a test note');
    
    await tester.pump();

    // Save the note
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify we're back on the home screen
    expect(find.byType(HomeScreen), findsOneWidget);
    
    // Verify the note is visible in the list
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
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Wait for initial load
    await tester.pumpAndSettle();

    // Find the search field and enter text
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'searchable');
    await tester.pumpAndSettle();

    // Verify the note is found
    expect(find.text('Test Search Note'), findsOneWidget);
  });

  testWidgets('Theme switching', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Wait for initial load
    await tester.pumpAndSettle();

    // Find and tap the theme switcher
    final themeButton = find.byIcon(Icons.dark_mode);
    expect(themeButton, findsOneWidget);
    
    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    // Verify the theme icon has changed
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('Delete a note', (WidgetTester tester) async {
    // Add a test note
    final testNote = Note(
      title: 'Note to Delete',
      content: 'This note will be deleted',
      tags: ['test', 'delete'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      id: 'delete_note_id',
    );
    await noteBox.add(testNote);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    // Find and long press the note to show delete option
    await tester.longPress(find.text('Note to Delete'));
    await tester.pumpAndSettle();

    // Tap delete button in the dialog
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify the note is deleted
    expect(find.text('Note to Delete'), findsNothing);
  });

  testWidgets('Edit an existing note', (WidgetTester tester) async {
    // Add a test note
    final testNote = Note(
      title: 'Original Title',
      content: 'Original content',
      tags: ['test', 'edit'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      id: 'edit_note_id',
    );
    await noteBox.add(testNote);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    // Tap the note to edit
    await tester.tap(find.text('Original Title'));
    await tester.pumpAndSettle();

    // Update note details
    await tester.enterText(find.byType(TextFormField).first, 'Updated Title');
    await tester.enterText(
      find.byType(TextFormField).last,
      'Updated content',
    );
    await tester.pump();

    // Save the changes
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify the note is updated
    expect(find.text('Updated Title'), findsOneWidget);
    expect(find.text('Original Title'), findsNothing);
  });

  testWidgets('Prevent saving empty title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    // Tap the FAB to create a new note
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Try to save with empty title
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.enterText(
      find.byType(TextFormField).last,
      'This note has no title',
    );
    await tester.pump();

    // Try to save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Should still be on the edit screen with error message
    expect(find.byType(NoteEditScreen), findsOneWidget);
    expect(find.text('Please enter a title'), findsOneWidget);
  });

  testWidgets('View note details', (WidgetTester tester) async {
    // Add a test note
    final testNote = Note(
      title: 'Test Note',
      content: 'This is a detailed note with some content',
      tags: ['test', 'view'],
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
      id: 'view_note_id',
    );
    await noteBox.add(testNote);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    // Tap the note to view details
    await tester.tap(find.text('Test Note'));
    await tester.pumpAndSettle();

    // Verify we're on the view screen and content is displayed
    expect(find.byType(NoteViewScreen), findsOneWidget);
    expect(find.text('This is a detailed note with some content'), findsOneWidget);
  });

  testWidgets('Empty state shows message', (WidgetTester tester) async {
    // Ensure the box is empty
    await noteBox.clear();
    
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    // Verify empty state message is shown
    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Search with no results shows empty state', (WidgetTester tester) async {
    // Add a test note
    final testNote = Note(
      title: 'Test Note',
      content: 'This is a test note',
      tags: ['test'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      id: 'search_test_id',
    );
    await noteBox.add(testNote);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    // Enter search query that won't match
    await tester.tap(find.byType(SearchBar));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'nonexistent');
    await tester.pumpAndSettle();

    // Verify empty state for search results
    expect(find.text('No notes found'), findsOneWidget);
  });
}
