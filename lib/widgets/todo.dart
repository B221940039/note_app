import 'package:flutter/material.dart';

class ToDoListSection extends StatefulWidget {
  final List<Map<String, dynamic>> checkedLists;
  final TextEditingController inputController;
  final void Function(String) onAddItem;
  final void Function(int, bool) onToggleItem;

  const ToDoListSection({
    super.key,
    required this.checkedLists,
    required this.inputController,
    required this.onAddItem,
    required this.onToggleItem,
  });

  @override
  State<ToDoListSection> createState() => _ToDoListSectionState();
}

class _ToDoListSectionState extends State<ToDoListSection> {
  @override
  Widget build(BuildContext context) {
    // Calculate checked count
    final checkedCount = widget.checkedLists.where((item) => item['value'] == true).length;
    final totalCount = widget.checkedLists.length;

    return Container(
      width: 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // dark background like iOS widget
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔶 Header section (Icon + Number + Label on left, items on right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Icon, Number, Label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🟠 Circular icon background
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF9F0A), // iOS orange
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.list,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const SizedBox(height: 4),

                    // 🟠 Label text with counter
                    Text(
                      "Reminders",
                      style: const TextStyle(
                        color: Color(0xFFFF9F0A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      "$checkedCount/$totalCount",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Right side: Todo list items
                Expanded(
                    child: totalCount == 0 ? Center(child: Text("Тэмэдэглэл нэмннэ үү.", style: TextStyle(color: Colors.white, fontSize: 19),)) :

                   Column(
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

            const SizedBox(height: 16),
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