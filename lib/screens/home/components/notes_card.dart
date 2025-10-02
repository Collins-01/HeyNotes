import 'package:flutter/material.dart';
import 'package:hey_notes/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: note.parsedColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(note.title, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (note.isPinned) ...[const Icon(Icons.push_pin)],
            ],
          ),
          Text(note.content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
