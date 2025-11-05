import 'package:flutter/material.dart';

class NoteToDo extends StatefulWidget {
  final List<Map<String, dynamic>> checkedLists;
  final TextEditingController inputController;
  final void Function(String) onAddItem;
  final void Function(int, bool) onToggleItem;

  const NoteToDo({
    super.key,
    required this.checkedLists,
    required this.inputController,
    required this.onAddItem,
    required this.onToggleItem,
  });

  @override
  State<NoteToDo> createState() => _NoteToDoState();
}

class _NoteToDoState extends State<NoteToDo> {
  void noteTypePicker() {

  }
  @override
  Widget build(BuildContext context) {
    // Calculate checked count
    final checkedCount = widget.checkedLists.where((item) => item['value'] == true).length;
    final totalCount = widget.checkedLists.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // dark background like iOS widget
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: widget.checkedLists.isEmpty ? 0 : 16,

          children: [

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ...widget.checkedLists.asMap().entries.map((entry) {
                      final index = entry.key;
                      final checkedItem = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            // Circle indicator
                            GestureDetector(
                              onTap: () =>
                                  widget.onToggleItem(index, !(checkedItem['value'])),
                              child: Icon(
                                checkedItem['value']
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: checkedItem['value']
                                    ? const Color(0xFFFF9F0A)
                                    : Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Task title
                            Expanded(
                              child: Text(
                                checkedItem['title'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: checkedItem['value']
                                      ? Colors.grey
                                      : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  decoration: checkedItem['value']
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  flex: 9,
                  child: TextField(
                    controller: widget.inputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Нэмэх...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.add, color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        widget.onAddItem(value.trim());
                        widget.inputController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ]),
    );
  }
}