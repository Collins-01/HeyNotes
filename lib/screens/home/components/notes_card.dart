// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:hey_notes/core/theme/app_colors.dart';
// import 'package:hey_notes/core/utils/ui_helpers.dart';
// import 'package:hey_notes/models/note.dart';
// import 'package:hey_notes/screens/notes_page/note_view_screen.dart';

// class NoteCard extends StatelessWidget {
//   final Note note;

//   const NoteCard({super.key, required this.note});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => CreateEditNoteScreen(note: note)),
//         );
//       },
//       child: Container(
//         height: 200,
//         padding: const EdgeInsets.all(UIHelpers.md),
//         decoration: BoxDecoration(
//           color: note.parsedColor,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     note.title,
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       overflow: TextOverflow.ellipsis,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const Gap(20),

//                 if (note.isPinned) ...[
//                   const Icon(Icons.push_pin, color: AppColors.white),
//                 ],
//               ],
//             ),
//             const Gap(12),
//             Expanded(
//               child: Text(
//                 note.content,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
