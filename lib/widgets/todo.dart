import 'package:flutter/material.dart';

class ToDo extends StatelessWidget {
  final List<Map<String, dynamic>> checkedLists; // User todos
  final List<Map<String, dynamic>> noteTodos; // Note todos
  final TextEditingController inputController;
  final void Function(String) onAddItem;
  final void Function(int, bool) onToggleItem;
  final void Function(int)? onDeleteUserTodo;
  final void Function(int, bool)? onNoteTodoToggle;
  final void Function(int)? onNoteTodoTap;
  final VoidCallback? onViewAll;
  final bool showAllTodos; // Show all todos or just preview
  final bool useCompactLayout; // Use compact layout for home screen

  const ToDo({
    super.key,
    required this.checkedLists,
    this.noteTodos = const [],
    required this.inputController,
    required this.onAddItem,
    required this.onToggleItem,
    this.onDeleteUserTodo,
    this.onNoteTodoToggle,
    this.onNoteTodoTap,
    this.onViewAll,
    this.showAllTodos = false,
    this.useCompactLayout = false,
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

    // Count completed todos
    final completedUserTodos = checkedLists
        .where((t) => (t['isCompleted'] ?? 0) == 1)
        .length;
    final completedNoteTodos = noteTodos
        .where((t) => (t['value'] ?? false))
        .length;
    final totalCompleted = completedUserTodos + completedNoteTodos;

    // Get list for preview or all todos based on showAllTodos flag
    final previewUserTodos = showAllTodos
        ? checkedLists // Show all todos when showAllTodos is true
        : checkedLists
              .where((t) => (t['isCompleted'] ?? 0) == 0)
              .take(2)
              .toList();
    final previewNoteTodos = showAllTodos
        ? noteTodos // Show all todos when showAllTodos is true
        : noteTodos.where((t) => !(t['value'] ?? false)).take(2).toList();

    // Use compact layout for home screen
    if (useCompactLayout) {
      return _buildCompactLayout(
        context,
        totalActive,
        totalCompleted,
        previewUserTodos,
        previewNoteTodos,
      );
    }

    // Use full layout for note screen
    return _buildFullLayout(
      context,
      totalActive,
      previewUserTodos,
      previewNoteTodos,
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    int totalActive,
    int totalCompleted,
    List<Map<String, dynamic>> previewUserTodos,
    List<Map<String, dynamic>> previewNoteTodos,
  ) {
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: Icon, title, stats, and button
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon and title
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Хийх зүйлс',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Stats
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Хийх: $totalActive',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // View all button
                    if (onViewAll != null)
                      TextButton(
                        onPressed: onViewAll,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Бүгдийг харах',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right side: Todo list
              Expanded(
                flex: 3,
                child: totalActive == 0
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt,
                              color: Colors.white.withOpacity(0.5),
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Тэмдэглэл\nнэмнэ үү.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // User todos preview
                            ...previewUserTodos.map((todo) {
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
                                        (todo['isCompleted'] ?? 0) == 0,
                                      ),
                                      child: Container(
                                        width: 20,
                                        height: 20,
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
                                              fontSize: 13,
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
                                    if (onDeleteUserTodo != null)
                                      GestureDetector(
                                        onTap: () => onDeleteUserTodo!(
                                          checkedLists.indexOf(todo),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            size: 16,
                                            color: Colors.white70,
                                          ),
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
                                          width: 20,
                                          height: 20,
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
                                                fontSize: 13,
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
                                        size: 12,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullLayout(
    BuildContext context,
    int totalActive,
    List<Map<String, dynamic>> previewUserTodos,
    List<Map<String, dynamic>> previewNoteTodos,
  ) {
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
                          final isCompleted = (todo['value'] ?? false) == true;
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
                                    !isCompleted,
                                  ),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted
                                          ? Colors.white
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: isCompleted
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Color(0xFF7C3AED),
                                          )
                                        : null,
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
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
                                if (onDeleteUserTodo != null)
                                  GestureDetector(
                                    onTap: () => onDeleteUserTodo!(
                                      checkedLists.indexOf(todo),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.white70,
                                      ),
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

            // View all button - only show if onViewAll callback is provided
            if (onViewAll != null) ...[
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
                        'Бүгдийг харах',
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
            ],

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
