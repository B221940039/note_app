import 'package:flutter/material.dart';
import 'package:assigmentv4/widgets/todo.dart';
import 'package:assigmentv4/widgets/notelist.dart';
import 'package:assigmentv4/database/database_helper.dart';
import 'package:assigmentv4/models/note_model.dart';
import 'package:assigmentv4/models/todo_model.dart';
import 'package:assigmentv4/screens/note.dart';
import 'package:assigmentv4/screens/todoscreen.dart';
import 'package:assigmentv4/screens/allnotes.dart';
import 'package:assigmentv4/screens/savednotes.dart';
import 'package:assigmentv4/screens/hiddennotes.dart';
import 'package:assigmentv4/screens/deletednotes.dart';
import 'package:assigmentv4/core/utils/sample_data.dart';

final TextEditingController _inputToDoController = TextEditingController();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  List<NoteModel> _notes = [];
  List<NoteModel> _filteredNotes = [];
  bool _isSearching = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _allUncheckedTodos = [];
  List<TodoModel> _userTodos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotes();
    _loadTodos();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh notes when app comes back to foreground
      _loadNotes();
      _loadTodos();
    }
  }

  Future<void> _loadTodos() async {
    try {
      final todosData = await DatabaseHelper.instance.getAllTodos();
      setState(() {
        _userTodos = todosData
            .map((todoMap) => TodoModel.fromMap(todoMap))
            .toList();
      });
    } catch (e) {
      print('Error loading todos: $e');
      setState(() {
        _userTodos = [];
      });
    }
  }

  Future<void> _addTodo(String title, {DateTime? deadline}) async {
    try {
      final todo = TodoModel(
        title: title,
        createdDate: DateTime.now(),
        deadline: deadline,
      );
      await DatabaseHelper.instance.insertTodo(todo.toMap());
      await _loadTodos();
      _loadNotes();
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> _toggleTodo(int index, bool value) async {
    try {
      final todo = _userTodos[index];
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      await DatabaseHelper.instance.updateTodo(updatedTodo.toMap());
      await _loadTodos();
      _loadNotes();
    } catch (e) {
      print('Error toggling todo: $e');
    }
  }

  Future<void> _deleteUserTodo(int index) async {
    try {
      final todo = _userTodos[index];
      await DatabaseHelper.instance.deleteTodo(todo.id!);
      await _loadTodos();
      _loadNotes();
    } catch (e) {
      print('Error deleting user todo: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() async {
    setState(() => _isLoading = true);

    try {
      final notesData = await DatabaseHelper.instance.getAllNotes();
      _notes = notesData
          .map((noteMap) => NoteModel.fromMap(noteMap))
          .where((note) => !note.isHidden) // Filter out hidden notes
          .toList();

      // Extract only unchecked todos from notes (not user todos)
      List<Map<String, dynamic>> noteTodos = [];
      for (var note in _notes) {
        for (var todo in note.todoItems) {
          if (todo['value'] != true) {
            noteTodos.add({
              'title': todo['title'],
              'value': false,
              'noteId': note.id,
              'noteTitle': note.title,
              'createdDate':
                  todo['createdDate'] ?? DateTime.now().toIso8601String(),
              'deadline': todo['deadline'],
              'isNoteTodo': true,
            });
          }
        }
      }

      // Sort note todos by createdDate (newest first)
      noteTodos.sort((a, b) {
        DateTime dateA = DateTime.parse(a['createdDate']);
        DateTime dateB = DateTime.parse(b['createdDate']);
        return dateB.compareTo(dateA);
      });

      _allUncheckedTodos = noteTodos;
    } catch (e) {
      print('Error loading notes: $e');
      _notes = [];
      _allUncheckedTodos = [];
    }

    if (!mounted) return;
    setState(() {
      _filteredNotes = _notes;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredNotes = _notes;
      });
    } else {
      setState(() {
        _isSearching = true;
        _filteredNotes = _notes
            .where(
              (note) =>
                  note.title.toLowerCase().contains(query.toLowerCase()) ||
                  note.content.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  void _openNote(NoteModel note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Note(note: note)),
    );

    // Always reload notes when returning from note screen
    _loadNotes();
  }

  Future<void> _deleteNote(NoteModel note) async {
    try {
      await DatabaseHelper.instance.deleteNote(note.id!);
      _loadNotes();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"${note.title}" deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting note: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 30, left: 0, right: 0, bottom: 0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt_rounded,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Тэмдэглэл',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    Navigator.of(context).pushReplacementNamed('/login');
                  } else if (value == 'generate_sample') {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Жишээ өгөгдөл үүсгэх'),
                        content: const Text(
                          'Одоо байгаа бүх өгөгдлийг устгаад 20 жишээ тэмдэглэл үүсгэх үү?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Болих'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Тийм'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      setState(() => _isLoading = true);
                      try {
                        await SampleDataGenerator.generateSampleNotes();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ 20 жишээ тэмдэглэл амжилттай үүслээ!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadNotes();
                          _loadTodos();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('❌ Алдаа гарлаа: $e')),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'generate_sample',
                    child: Row(
                      children: [
                        Icon(
                          Icons.data_object,
                          size: 18,
                          color: Color(0xFF7C3AED),
                        ),
                        SizedBox(width: 8),
                        Text('Жишээ өгөгдөл'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: Color(0xFF7C3AED)),
                        SizedBox(width: 8),
                        Text('Гарах'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        // 🔍 Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search notes...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: const Color(0xFF7C3AED).withOpacity(0.7),
                                size: 22,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        ToDo(
                          checkedLists: _userTodos
                              .map((todo) => todo.toMap())
                              .toList(),
                          noteTodos: _allUncheckedTodos,
                          inputController: _inputToDoController,
                          useCompactLayout:
                              true, // Use compact layout for home screen
                          onAddItem: (text) async {
                            DateTime? deadline;
                            await showDialog(
                              context: context,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setDialogState) => AlertDialog(
                                  title: const Text('Set Deadline (Optional)'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Todo: $text'),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.calendar_today),
                                        label: Text(
                                          deadline == null
                                              ? 'Select Deadline'
                                              : '${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}',
                                        ),
                                        onPressed: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(
                                              const Duration(days: 365),
                                            ),
                                          );
                                          if (picked != null) {
                                            setDialogState(() {
                                              deadline = picked;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        deadline = null;
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Skip'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            await _addTodo(text, deadline: deadline);
                            _inputToDoController.clear();
                          },
                          onToggleItem: (index, value) async {
                            await _toggleTodo(index, value);
                          },
                          onDeleteUserTodo: (index) async {
                            await _deleteUserTodo(index);
                          },
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TodoScreen(),
                              ),
                            ).then((_) {
                              _loadNotes();
                              _loadTodos();
                            });
                          },
                          onNoteTodoToggle: (todoIndex, value) async {
                            // Find the note and update its todo item
                            final noteTodo = _allUncheckedTodos[todoIndex];
                            final noteId = noteTodo['noteId'];
                            final note = _notes.firstWhere(
                              (n) => n.id == noteId,
                            );

                            // Update the todo item in the note
                            final updatedTodoItems =
                                List<Map<String, dynamic>>.from(note.todoItems);
                            final todoTitle = noteTodo['title'];
                            final todoItemIndex = updatedTodoItems.indexWhere(
                              (item) =>
                                  item['title'] == todoTitle &&
                                  item['value'] != true,
                            );

                            if (todoItemIndex != -1) {
                              updatedTodoItems[todoItemIndex]['value'] = value;

                              // Save to database
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

                              await DatabaseHelper.instance.updateNote(
                                updatedNote.toMap(),
                              );

                              // Reload notes to refresh the todo list
                              _loadNotes();
                            }
                          },
                          onNoteTodoTap: (noteId) {
                            // Find and open the note
                            final note = _notes.firstWhere(
                              (n) => n.id == noteId,
                            );
                            _openNote(note);
                          },
                        ),

                        // Action Cards Row
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                icon: Icons.description,
                                label: 'Бүх тэмдэглэл',
                                color: Colors.grey[400]!,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AllNotesScreen(),
                                    ),
                                  ).then((_) {
                                    _loadNotes();
                                    _loadTodos();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionCard(
                                icon: Icons.visibility_off,
                                label: 'Нууцласан',
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HiddenNotesScreen(),
                                    ),
                                  ).then((_) {
                                    _loadNotes();
                                    _loadTodos();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                icon: Icons.star,
                                label: 'Хадгалсан',
                                color: Colors.amber,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SavedNotesScreen(),
                                    ),
                                  ).then((_) {
                                    _loadNotes();
                                    _loadTodos();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionCard(
                                icon: Icons.delete,
                                label: 'Хогийн сав',
                                color: Colors.red,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DeletedNotesScreen(),
                                    ),
                                  ).then((_) {
                                    _loadNotes();
                                    _loadTodos();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        // 🟩 Notes Section
                        const SizedBox(height: 16),
                        _filteredNotes.isEmpty && _isSearching
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 60,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF7C3AED,
                                        ).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.search_off_rounded,
                                        size: 48,
                                        color: const Color(
                                          0xFF7C3AED,
                                        ).withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Тэмдэглэл олдсонгүй',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF1F2937),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Өөр хайлт туршиж үзнэ үү',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : NoteList(
                                notes: _filteredNotes,
                                onNoteTap: _openNote,
                                onNoteDelete: _deleteNote,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
      ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Note()),
            );

            // Always reload notes when returning from note screen
            _loadNotes();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
