import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note_model.dart';
import '../models/todo_model.dart';
import '../screens/note.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _inputController = TextEditingController();
  List<NoteModel> _notes = [];
  List<TodoModel> _userTodos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadNotes();
    await _loadUserTodos();
    setState(() => _isLoading = false);
  }

  Future<void> _loadNotes() async {
    try {
      final notesData = await DatabaseHelper.instance.getAllNotes();
      _notes = notesData.map((noteMap) => NoteModel.fromMap(noteMap)).toList();
    } catch (e) {
      print('Error loading notes: $e');
      _notes = [];
    }
  }

  Future<void> _loadUserTodos() async {
    try {
      final todosData = await DatabaseHelper.instance.getAllTodos();
      _userTodos = todosData
          .map((todoMap) => TodoModel.fromMap(todoMap))
          .toList();
    } catch (e) {
      print('Error loading user todos: $e');
      _userTodos = [];
    }
  }

  Future<void> _addTodo(String title, DateTime? deadline) async {
    try {
      final todo = TodoModel(
        title: title,
        createdDate: DateTime.now(),
        deadline: deadline,
      );
      await DatabaseHelper.instance.insertTodo(todo.toMap());
      await _loadUserTodos();
      setState(() {}); // Refresh UI to show new todo
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> _toggleUserTodo(TodoModel todo) async {
    try {
      final updatedTodo = TodoModel(
        id: todo.id,
        title: todo.title,
        isCompleted: !todo.isCompleted,
        createdDate: todo.createdDate,
        deadline: todo.deadline,
      );
      await DatabaseHelper.instance.updateTodo(updatedTodo.toMap());
      await _loadData(); // Reload all data to ensure full refresh
    } catch (e) {
      print('Error toggling todo: $e');
    }
  }

  Future<void> _deleteUserTodo(TodoModel todo) async {
    try {
      await DatabaseHelper.instance.deleteTodo(todo.id!);
      await _loadUserTodos();
      setState(() {}); // Refresh UI
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  Future<void> _toggleNoteTodo(NoteModel note, int todoIndex) async {
    try {
      final updatedTodoItems = List<Map<String, dynamic>>.from(note.todoItems);
      updatedTodoItems[todoIndex]['value'] = true;

      final updatedNote = NoteModel(
        id: note.id,
        title: note.title,
        content: note.content,
        tag: note.tag,
        color: note.color,
        dateCreated: note.dateCreated,
        audioPath: note.audioPath,
        videoPath: note.videoPath,
        todoItems: updatedTodoItems,
      );

      await DatabaseHelper.instance.updateNote(updatedNote.toMap());
      await _loadNotes();
      setState(() {}); // Refresh UI
    } catch (e) {
      print('Error toggling note todo: $e');
    }
  }

  Future<void> _deleteNoteTodo(NoteModel note, int todoIndex) async {
    try {
      final updatedTodoItems = List<Map<String, dynamic>>.from(note.todoItems);
      updatedTodoItems.removeAt(todoIndex);

      final updatedNote = NoteModel(
        id: note.id,
        title: note.title,
        content: note.content,
        tag: note.tag,
        color: note.color,
        dateCreated: note.dateCreated,
        audioPath: note.audioPath,
        videoPath: note.videoPath,
        todoItems: updatedTodoItems,
      );

      await DatabaseHelper.instance.updateNote(updatedNote.toMap());
      await _loadNotes();
      setState(() {}); // Refresh UI
    } catch (e) {
      print('Error deleting note todo: $e');
    }
  }

  void _openNote(NoteModel note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Note(note: note)),
    );
    _loadData();
  }

  int _countNoteTodos({required bool completed}) {
    int count = 0;
    for (var note in _notes) {
      for (var todo in note.todoItems) {
        if ((todo['value'] == true) == completed) {
          count++;
        }
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final activeUserTodos = _userTodos.where((t) => !t.isCompleted).length;
    final completedUserTodos = _userTodos.where((t) => t.isCompleted).length;
    final activeNoteTodos = _countNoteTodos(completed: false);
    final completedNoteTodos = _countNoteTodos(completed: true);
    final totalTodos =
        activeUserTodos +
        completedUserTodos +
        activeNoteTodos +
        completedNoteTodos;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'All Reminders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${activeUserTodos + activeNoteTodos}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Active',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white30,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${completedUserTodos + completedNoteTodos}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Completed',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white30,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '$totalTodos',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              child: totalTodos == 0
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No todos yet',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView(
                                      padding: const EdgeInsets.all(20),
                                      children: [
                                        if (activeUserTodos > 0) ...[
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Text(
                                              'Your Active Todos',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF7C3AED),
                                              ),
                                            ),
                                          ),
                                          ..._userTodos.where((t) => !t.isCompleted).map((
                                            todo,
                                          ) {
                                            return Card(
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: ListTile(
                                                leading: GestureDetector(
                                                  onTap: () =>
                                                      _toggleUserTodo(todo),
                                                  child: const Icon(
                                                    Icons
                                                        .radio_button_unchecked,
                                                    color: Color(0xFF7C3AED),
                                                  ),
                                                ),
                                                title: Text(todo.title),
                                                subtitle: Text(
                                                  '${todo.createdDate?.toString().substring(0, 16) ?? ''}${todo.deadline != null ? ' → ${todo.deadline!.toString().substring(0, 10)}' : ''}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        todo.deadline != null &&
                                                            todo.deadline!
                                                                .isBefore(
                                                                  DateTime.now(),
                                                                )
                                                        ? Colors.red
                                                        : Colors.grey[600],
                                                    fontWeight:
                                                        todo.deadline != null &&
                                                            todo.deadline!
                                                                .isBefore(
                                                                  DateTime.now(),
                                                                )
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      _deleteUserTodo(todo),
                                                ),
                                              ),
                                            );
                                          }),
                                          const SizedBox(height: 20),
                                        ],
                                        if (activeNoteTodos > 0) ...[
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Text(
                                              'Active Note Todos',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF7C3AED),
                                              ),
                                            ),
                                          ),
                                          ..._notes.expand((note) {
                                            return note.todoItems
                                                .asMap()
                                                .entries
                                                .where(
                                                  (entry) =>
                                                      entry.value['value'] !=
                                                      true,
                                                )
                                                .map((entry) {
                                                  final todoIndex = entry.key;
                                                  final todo = entry.value;
                                                  return Card(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          bottom: 8,
                                                        ),
                                                    child: ListTile(
                                                      leading: GestureDetector(
                                                        onTap: () =>
                                                            _toggleNoteTodo(
                                                              note,
                                                              todoIndex,
                                                            ),
                                                        child: const Icon(
                                                          Icons
                                                              .radio_button_unchecked,
                                                          color: Color(
                                                            0xFF7C3AED,
                                                          ),
                                                        ),
                                                      ),
                                                      title: Text(
                                                        todo['title'],
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'from: ${note.title}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                          ),
                                                          if (todo['createdDate'] !=
                                                                  null ||
                                                              todo['deadline'] !=
                                                                  null)
                                                            Text(
                                                              '${todo['createdDate'] != null ? DateTime.parse(todo['createdDate']).toString().substring(0, 16) : ''}${todo['deadline'] != null ? '  ${DateTime.parse(todo['deadline']).toString().substring(0, 10)}' : ''}',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color:
                                                                    todo['deadline'] !=
                                                                            null &&
                                                                        DateTime.parse(
                                                                          todo['deadline'],
                                                                        ).isBefore(
                                                                          DateTime.now(),
                                                                        )
                                                                    ? Colors.red
                                                                    : Colors
                                                                          .grey[600],
                                                                fontWeight:
                                                                    todo['deadline'] !=
                                                                            null &&
                                                                        DateTime.parse(
                                                                          todo['deadline'],
                                                                        ).isBefore(
                                                                          DateTime.now(),
                                                                        )
                                                                    ? FontWeight
                                                                          .bold
                                                                    : FontWeight
                                                                          .normal,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () =>
                                                                _deleteNoteTodo(
                                                                  note,
                                                                  todoIndex,
                                                                ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: 16,
                                                            ),
                                                            onPressed: () =>
                                                                _openNote(note),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          }),
                                          const SizedBox(height: 20),
                                        ],
                                        if (completedUserTodos > 0 ||
                                            completedNoteTodos > 0) ...[
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Text(
                                              'Completed Todos',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          ..._userTodos
                                              .where((t) => t.isCompleted)
                                              .map((todo) {
                                                return Card(
                                                  margin: const EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  color: Colors.grey[100],
                                                  child: ListTile(
                                                    leading: GestureDetector(
                                                      onTap: () =>
                                                          _toggleUserTodo(todo),
                                                      child: const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      todo.title,
                                                      style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      '${todo.createdDate?.toString().substring(0, 16) ?? ''}${todo.deadline != null ? ' → ${todo.deadline!.toString().substring(0, 10)}' : ''}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    trailing: IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () =>
                                                          _deleteUserTodo(todo),
                                                    ),
                                                  ),
                                                );
                                              }),
                                          ..._notes.expand((note) {
                                            return note.todoItems
                                                .asMap()
                                                .entries
                                                .where(
                                                  (entry) =>
                                                      entry.value['value'] ==
                                                      true,
                                                )
                                                .map((entry) {
                                                  final todoIndex = entry.key;
                                                  final todo = entry.value;
                                                  return Card(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          bottom: 8,
                                                        ),
                                                    color: Colors.grey[100],
                                                    child: ListTile(
                                                      leading: GestureDetector(
                                                        onTap: () async {
                                                          final updatedTodoItems =
                                                              List<
                                                                Map<
                                                                  String,
                                                                  dynamic
                                                                >
                                                              >.from(
                                                                note.todoItems,
                                                              );
                                                          updatedTodoItems[todoIndex]['value'] =
                                                              false;
                                                          final updatedNote =
                                                              NoteModel(
                                                                id: note.id,
                                                                title:
                                                                    note.title,
                                                                content: note
                                                                    .content,
                                                                tag: note.tag,
                                                                color:
                                                                    note.color,
                                                                dateCreated: note
                                                                    .dateCreated,
                                                                audioPath: note
                                                                    .audioPath,
                                                                videoPath: note
                                                                    .videoPath,
                                                                todoItems:
                                                                    updatedTodoItems,
                                                              );
                                                          await DatabaseHelper
                                                              .instance
                                                              .updateNote(
                                                                updatedNote
                                                                    .toMap(),
                                                              );
                                                          await _loadData();
                                                        },
                                                        child: const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        todo['title'],
                                                        style: const TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'from: ${note.title}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                          ),
                                                          if (todo['createdDate'] !=
                                                                  null ||
                                                              todo['deadline'] !=
                                                                  null)
                                                            Text(
                                                              '${todo['createdDate'] != null ? DateTime.parse(todo['createdDate']).toString().substring(0, 16) : ''}${todo['deadline'] != null ? '  ${DateTime.parse(todo['deadline']).toString().substring(0, 10)}' : ''}',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                            ),
                                                        ],
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () =>
                                                                _deleteNoteTodo(
                                                                  note,
                                                                  todoIndex,
                                                                ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: 16,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            onPressed: () =>
                                                                _openNote(note),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          }),
                                        ],
                                      ],
                                    ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _inputController,
                                    decoration: InputDecoration(
                                      hintText: 'Add new todo...',
                                      prefixIcon: const Icon(
                                        Icons.add,
                                        color: Color(0xFF7C3AED),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onSubmitted: (value) async {
                                      if (value.trim().isNotEmpty) {
                                        await _addTodo(value.trim(), null);
                                        _inputController.clear();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
