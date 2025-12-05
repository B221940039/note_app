import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note_model.dart';

class NoteList extends StatelessWidget {
  final List<NoteModel> notes;
  final Function(NoteModel) onNoteTap;
  final Function(NoteModel) onNoteDelete;

  const NoteList({
    super.key,
    required this.notes,
    required this.onNoteTap,
    required this.onNoteDelete,
  });

  // Get tag color based on note color
  Color _getTagColor(Color? noteColor) {
    if (noteColor == null) return const Color(0xFF9E9E9E);

    final noteColors = [
      null,
      const Color(0xFFC4EFAC),
      const Color(0xFF9FF2E1),
      const Color(0xFFFFDAD7),
      const Color(0xFFE6E762),
      const Color(0xFFE74AC5),
      Colors.teal[300],
      Colors.cyan[300],
      Colors.blue[300],
      Colors.indigo[300],
      Colors.purple[300],
      Colors.pink[300],
    ];

    final tagColors = [
      const Color(0xFF9E9E9E),
      const Color(0xFF7CB342),
      const Color(0xFF26A69A),
      const Color(0xFFEF5350),
      const Color(0xFFFFA726),
      const Color(0xFFAB47BC),
      const Color(0xFF00897B),
      const Color(0xFF00ACC1),
      const Color(0xFF42A5F5),
      const Color(0xFF5C6BC0),
      const Color(0xFF7E57C2),
      const Color(0xFFEC407A),
    ];

    final index = noteColors.indexOf(noteColor);
    return index >= 0 && index < tagColors.length
        ? tagColors[index]
        : const Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Тэмдэглэл байхгүй байна',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Шинэ тэмдэглэл нэмнэ үү',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final tags = note.tag.isNotEmpty && note.tag != 'Untagged'
            ? note.tag.split(',').map((e) => e.trim()).toList()
            : <String>[];

        return GestureDetector(
          onTap: () => onNoteTap(note),
          child: Container(
            decoration: BoxDecoration(
              color: note.color ?? const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                if (note.title.isNotEmpty && note.title != 'Untitled')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Content
                if (note.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      note.content,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Todo items
                if (note.todoItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: note.todoItems.take(3).map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                item['value'] == true
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    decoration: item['value'] == true
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Tags
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTagColor(note.color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                // Media indicators and location
                if (note.audioPath != null ||
                    note.videoPath != null ||
                    tags.any((tag) => tag.contains(',')))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        if (note.audioPath != null)
                          const Icon(
                            Icons.mic,
                            size: 14,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        if (note.audioPath != null && note.videoPath != null)
                          const SizedBox(width: 4),
                        if (note.videoPath != null)
                          const Icon(
                            Icons.videocam,
                            size: 14,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
