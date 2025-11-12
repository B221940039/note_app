import 'package:flutter/material.dart';
import 'package:assigmentv4/widgets/todo.dart';

final List<Map<String, dynamic>> _checkedLists = [];
final TextEditingController _inputToDoController = TextEditingController();

final List<String> _noteTypes = ['typing', 'audio', 'video'];

class Note {
  final String title;
  final String content;
  final bool isLocked;

  final Color color;

  Note({
    required this.title,
    required this.content,
    required this.color,
    this.isLocked = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() async {
    setState(() => _isLoading = true);

    // Simulate loading data
    await Future.delayed(const Duration(milliseconds: 500));

    _notes = [
      Note(
        title: "Санамж",
        content: "Өнөөдөр 14:00 цагт уулзалттай",
        color: Colors.yellow,
      ),
      Note(
        title: "Идэш",
        content:
            "Хоолны жор: гоймон, өндөг, сонгино Хоолны жор: гоймон, өндөг, сонгиноХоолны жор: гоймон, өндөг, сонгино",
        color: Colors.red,
      ),
      Note(
        title: "Тэмдэглэл",
        content: "Flutter төслийн загвар шалгах",
        color: Colors.green,
      ),
    ];

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

  void _openNote(Note note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${note.title}" нээгдлээ (fake action)')),
    );
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тэмдэглэл устгах'),
        content: Text('"${note.title}" устгах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Цуцлах'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      setState(() {
        _notes.remove(note);
        _filteredNotes.remove(note);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"${note.title}" устгагдлаа')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Тэмдэглэл'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('U', style: TextStyle(color: Colors.white)),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Гарах'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.only(left: 20, right: 20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🔍 Search bar
                        Container(
                          decoration: const BoxDecoration(),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Тэмдэглэл хайх',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),

                        ToDo(
                          checkedLists: _checkedLists,
                          inputController: _inputToDoController,
                          onAddItem: (text) {
                            setState(() {
                              _checkedLists.add({
                                'title': text,
                                'value': false,
                              });
                              _inputToDoController.clear();
                            });
                          },
                          onToggleItem: (index, value) {
                            setState(() {
                              _checkedLists[index]['value'] = value;
                            });
                          },
                        ),
                        // 🟩 Notes Section
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            children: _filteredNotes.isEmpty
                                ? [
                                    const SizedBox(height: 60),
                                    Icon(
                                      _isSearching
                                          ? Icons.search_off
                                          : Icons.note_add_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _isSearching
                                          ? 'Тэмдэглэл олдсонгүй'
                                          : 'Тэмдэглэл байхгүй байна',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isSearching
                                          ? 'Өөр хайлт туршиж үзнэ үү'
                                          : 'Шинэ тэмдэглэл нэмнэ үү',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                  ]
                                : _filteredNotes.map((note) {
                                    return Card(
                                      color: note.color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        title: Text(
                                          note.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          note.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.more_horiz),
                                          onPressed: () => _deleteNote(note),
                                        ),
                                        onTap: () => _openNote(note),
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Шинэ тэмдэглэл нэмэх үйлдэл (fake)')),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
