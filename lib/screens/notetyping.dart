import '../widgets/recordvideo.dart';
import 'package:flutter/material.dart';
import '../widgets/notetodo.dart';
import '../widgets/recordaudio.dart';

class Note {
  final int id;
  final String title;
  final String content;
  final DateTime dateCreated;
  final String tag;
  final Color? color;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.color,
    required this.dateCreated,
  });
}

class NoteTyping extends StatefulWidget {
  const NoteTyping({super.key});

  @override
  State<NoteTyping> createState() => _NoteTypingState();
}

class _NoteTypingState extends State<NoteTyping> {
  final List<Map<String, dynamic>> _checkedLists = [];

  final TextEditingController _inputToDoController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Color? _selectedColor;
  DateTime dateCreated = DateTime.now();

  // Available colors for notes
  final List<Color?> _noteColors = [
    null,
    Colors.red[300],
    Colors.brown[300],
    Colors.orange[300],
    Colors.yellow[300],
    Colors.green[300],
    Colors.teal[300],
    Colors.cyan[300],
    Colors.blue[300],
    Colors.indigo[300],
    Colors.purple[300],
    Colors.pink[300],
    Colors.grey[400],
  ];

  @override
  void dispose() {
    _inputToDoController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // ------------------- Color Picker -------------------
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _noteColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color ?? Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color == null
                              ? Colors.grey
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: color == null
                                  ? Colors.black
                                  : Colors.white,
                              size: 28,
                            )
                          : (color == null
                                ? Icon(
                                    Icons.format_color_reset,
                                    color: Colors.grey[600],
                                  )
                                : null),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'More Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Note'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------- Save Note -------------------
  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tag = _tagController.text.trim();

    if (title.isEmpty && content.isEmpty && _checkedLists.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note is empty!')));
      return;
    }

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title.isNotEmpty ? title : 'Untitled',
      content: content,
      tag: tag.isNotEmpty ? tag : 'Untagged',
      color: _selectedColor,
      dateCreated: DateTime.now(),
    );

    print('Saving note: ${note.title}');
    print('Tag: ${note.tag}');
    print('Content: ${note.content}');
    print('Color: ${note.color}');
    print('Todo items: $_checkedLists');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note saved!')));

    Navigator.pop(context, note);
  }

  void _handleRecordingComplete(String filePath) {
    print('Recording saved at: $filePath');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Recording saved at: $filePath')));
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _selectedColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: _selectedColor,
        title: const Text('New Note'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: Column(
        children: [
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Title Field
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Tag Field
                  TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Tag (e.g. work, study, personal)',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),

                  // Note content
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Type your note here...',
                      border: InputBorder.none,
                    ),
                  ),

                  // Todo List
                  NoteToDo(
                    checkedLists: _checkedLists,
                    inputController: _inputToDoController,
                    onAddItem: (text) {
                      setState(() {
                        _checkedLists.add({'title': text, 'value': false});
                        _inputToDoController.clear();
                      });
                    },
                    onToggleItem: (index, value) {
                      setState(() {
                        _checkedLists[index]['value'] = value;
                      });
                    },
                  ),

                  const Divider(),

                  // Date created
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Text(dateCreated.toString())],
                  ),
                ],
              ),
            ),
          ),

          // Fixed bottom actions
          Container(
            decoration: BoxDecoration(
              color:
                  _selectedColor ?? Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _showColorPicker,
                  icon: const Icon(Iz cons.color_lens),
                  tooltip: 'Change color',
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return RecordAudioWidget(
                          onRecordingComplete: _handleRecordingComplete,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.mic),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return RecordVideoWidget(
                          onRecordingComplete: _handleRecordingComplete,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.videocam),
                ),
                IconButton(
                  onPressed: _showMoreOptions,

                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More options',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
