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
    return Container(
      color: const Color(0xFF605CF9),

      child: Column(
        children: [
          // ✅ Existing checklist items
          ...widget.checkedLists.asMap().entries.map((entry) {
            final index = entry.key;
            final checkedItem = entry.value;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: Text(
                  checkedItem['title'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                value: checkedItem['value'],
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                onChanged: (bool? value) {
                  widget.onToggleItem(index, value ?? false);
                },
              ),
            );
          }),

          // 🟢 Input field + Add button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: TextField(
                    controller: widget.inputController,
                    decoration: InputDecoration(
                      hintText: 'Хийх зүйл...',
                      prefixIcon: const Icon(Icons.list),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      final text = widget.inputController.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a list name'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      widget.onAddItem(text);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.add), // ✅ icon only
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
