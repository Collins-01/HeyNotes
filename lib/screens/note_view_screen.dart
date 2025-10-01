import 'package:flutter/material.dart';
import 'package:hey_notes/screens/note_edit_screen.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

class NoteViewScreen extends StatelessWidget {
  final Note note;

  const NoteViewScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditScreen(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMd().add_jm().format(note.updatedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(),
            const SizedBox(height: 16),
            Text(note.content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
