import 'package:flutter/material.dart';

class ToDo extends StatelessWidget {
  final List<Map<String, dynamic>> checkedLists; // User todos
  final List<Map<String, dynamic>> noteTodos; // Note todos
  final TextEditingController inputController;
  final void Function(String) onAddItem;
  final void Function(int, bool) onToggleItem;
  final void Function(int, bool)? onNoteTodoToggle;
  final void Function(int)? onNoteTodoTap;
  final VoidCallback? onViewAll;

  const ToDo({
    super.key,
    required this.checkedLists,
    this.noteTodos = const [],
    required this.inputController,
    required this.onAddItem,
    required this.onToggleItem,
    this.onNoteTodoToggle,
    this.onNoteTodoTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Count active todos
    // isCompleted is stored as int (0 or 1) in database
    final activeUserTodos = checkedLists
        .where((t) => (t['isCompleted'] ?? 0) == 0)
        .length;
    final activeNoteTodos = noteTodos
        .where((t) => !(t['value'] ?? false))
        .length;
    final totalActive = activeUserTodos + activeNoteTodos;

    // Get limited list for preview (max 4 items)
    final previewUserTodos = checkedLists
        .where((t) => (t['isCompleted'] ?? 0) == 0)
        .take(2)
        .toList();
    final previewNoteTodos = noteTodos
        .where((t) => !(t['value'] ?? false))
        .take(2)
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Reminders',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalActive active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: totalActive == 0
                  ? const Center(
                      child: Text(
                        "Тэмдэглэл нэмнэ үү.",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    )
                  : Column(
                      children: [
                        // User todos preview
                        ...previewUserTodos.asMap().entries.map((entry) {
                          final todo = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => onToggleItem(
                                    checkedLists.indexOf(todo),
                                    true,
                                  ),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo['title'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (todo['deadline'] != null)
                                        Text(
                                          '→ ${DateTime.parse(todo['deadline']).toString().substring(0, 10)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Note todos preview
                        ...previewNoteTodos.map((noteTodo) {
                          return GestureDetector(
                            onTap: () {
                              if (onNoteTodoTap != null &&
                                  noteTodo['noteId'] != null) {
                                onNoteTodoTap!(noteTodo['noteId']);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (onNoteTodoToggle != null) {
                                        onNoteTodoToggle!(
                                          noteTodos.indexOf(noteTodo),
                                          true,
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          noteTodo['title'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'from: ${noteTodo['noteTitle']}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
            ),

            // View all button
            Center(
              child: TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Add todo input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Нэмэх...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.add,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          onAddItem(value.trim());
                          inputController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
