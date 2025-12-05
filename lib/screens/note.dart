import '../widgets/recordvideo.dart';
import 'package:flutter/material.dart';
import '../widgets/todo.dart';
import '../widgets/recordaudio.dart';
import '../widgets/audioplayerwidget.dart';
import '../widgets/videoplayerwidget.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/note_model.dart';

class Note extends StatefulWidget {
  final NoteModel? note;

  const Note({super.key, this.note});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  final List<Map<String, dynamic>> _checkedLists = [];
  final List<String> _tags = [];

  final TextEditingController _inputToDoController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();

  Color? _selectedColor;
  DateTime dateCreated = DateTime.now();
  String? _audioPath;
  String? _videoPath;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _isEditMode = true;
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = widget.note!.color;
      dateCreated = widget.note!.dateCreated;
      _audioPath = widget.note!.audioPath;
      _videoPath = widget.note!.videoPath;
      _checkedLists.addAll(widget.note!.todoItems);
      // Parse tags from comma-separated string
      if (widget.note!.tag.isNotEmpty && widget.note!.tag != 'Untagged') {
        _tags.addAll(widget.note!.tag.split(',').map((e) => e.trim()));
      }
    } else {
      // Auto-focus title field for new notes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }
  }

  // Available colors for notes
  final List<Color?> _noteColors = [
    null,
    Color(0xFFC4EFAC),
    Color(0xFF9FF2E1),
    Color(0xFFFFDAD7),
    Color(0xFFE6E762),
    Color(0xFFE74AC5),
    Colors.teal[300],
    Colors.cyan[300],
    Colors.blue[300],
    Colors.indigo[300],
    Colors.purple[300],
    Colors.pink[300],
  ];

  // Tag colors that match note colors
  final List<Color> _tagColors = [
    Color(0xFF9E9E9E), // Default gray for null note color
    Color(0xFF7CB342), // Green - Matches C4EFAC
    Color(0xFF26A69A), // Teal - Matches 9FF2E1
    Color(0xFFEF5350), // Red - Matches FFDAD7
    Color(0xFFFFA726), // Orange - Matches E6E762
    Color(0xFFAB47BC), // Purple - Matches E74AC5
    Color(0xFF00897B), // Dark Teal - Matches teal[300]
    Color(0xFF00ACC1), // Cyan - Matches cyan[300]
    Color(0xFF42A5F5), // Blue - Matches blue[300]
    Color(0xFF5C6BC0), // Indigo - Matches indigo[300]
    Color(0xFF7E57C2), // Deep Purple - Matches purple[300]
    Color(0xFFEC407A), // Pink - Matches pink[300]
  ];

  Color _getTagColor() {
    if (_selectedColor == null) return _tagColors[0];
    final index = _noteColors.indexOf(_selectedColor);
    return index >= 0 && index < _tagColors.length
        ? _tagColors[index]
        : _tagColors[0];
  }

  @override
  void dispose() {
    _inputToDoController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _titleFocusNode.dispose();
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
                children: List.generate(_noteColors.length, (index) {
                  final color = _noteColors[index];
                  final tagColor = _tagColors[index];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
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
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Tag',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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
              if (_isEditMode)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Note'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteNote();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ------------------- Save Note -------------------
  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tag = _tags.isEmpty ? 'Untagged' : _tags.join(',');

    if (title.isEmpty && content.isEmpty && _checkedLists.isEmpty) {
      return;
    }

    final note = NoteModel(
      id: _isEditMode ? widget.note!.id : null,
      title: title,
      content: content,
      tag: tag,
      color: _selectedColor,
      dateCreated: _isEditMode ? widget.note!.dateCreated : DateTime.now(),
      audioPath: _audioPath,
      videoPath: _videoPath,
      todoItems: _checkedLists,
    );

    try {
      if (_isEditMode) {
        await DatabaseHelper.instance.updateNote(note.toMap());
      } else {
        await DatabaseHelper.instance.insertNote(note.toMap());
        // Switch to edit mode after first save
        setState(() {
          _isEditMode = true;
        });
      }

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
    }
  }

  // ------------------- Delete Note -------------------
  void _deleteNote() async {
    if (!_isEditMode) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await DatabaseHelper.instance.deleteNote(widget.note!.id!);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
    }
  }

  void _handleRecordingComplete(String filePath, {bool isVideo = false}) {
    print('Recording complete: $filePath (isVideo: $isVideo)');
    setState(() {
      if (isVideo) {
        _videoPath = filePath;
        print('Video path set: $_videoPath');
      } else {
        _audioPath = filePath;
        print('Audio path set: $_audioPath');
      }
    });
  }

  void _deleteAudio() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Audio'),
        content: const Text('Are you sure you want to delete this audio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && _audioPath != null) {
      try {
        final file = File(_audioPath!);
        if (await file.exists()) {
          await file.delete();
        }
        setState(() {
          _audioPath = null;
        });
        if (!mounted) return;
      } catch (e) {
        if (!mounted) return;
      }
    }
  }

  void _deleteVideo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: const Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && _videoPath != null) {
      try {
        final file = File(_videoPath!);
        if (await file.exists()) {
          await file.delete();
        }
        setState(() {
          _videoPath = null;
        });
        if (!mounted) return;
      } catch (e) {
        if (!mounted) return;
      }
    }
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Auto-save when back button is pressed
        await _saveNote();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            _isEditMode ? 'Edit Note' : 'New Note',
            style: const TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              onPressed: _saveNote,
              icon: const Icon(Icons.save),
              tooltip: 'Save note',
            ),
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
                      focusNode: _titleFocusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Гарчиг...',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Tag Chips
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._tags.map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getTagColor(),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _tags.remove(tag);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Add tag text field
                          IntrinsicWidth(
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 60,
                                maxWidth: 200,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getTagColor(),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: IntrinsicWidth(
                                      child: TextField(
                                        controller: _tagController,
                                        decoration: const InputDecoration(
                                          hintText: 'Таг...',
                                          hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        onSubmitted: (value) {
                                          if (value.trim().isNotEmpty &&
                                              !_tags.contains(value.trim())) {
                                            setState(() {
                                              _tags.add(value.trim());
                                              _tagController.clear();
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Note content
                    Container(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 6,
                        bottom: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedColor ?? Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        minLines: 8,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Color(0xFF888888)),
                          hintText: 'Тэмдэглэлээ энд бичээрэй...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 16, 17, 16),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Todo List
                    ToDo(
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

                    // Audio Player
                    if (_audioPath != null)
                      AudioPlayerWidget(
                        audioPath: _audioPath!,
                        onDelete: _deleteAudio,
                      ),

                    // Video Player
                    if (_videoPath != null)
                      VideoPlayerWidget(
                        videoPath: _videoPath!,
                        onDelete: _deleteVideo,
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
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _showColorPicker,
                    icon: const Icon(Icons.color_lens),
                    tooltip: 'Change color',
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return RecordAudioWidget(
                            onRecordingComplete: (path) =>
                                _handleRecordingComplete(path, isVideo: false),
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.mic,
                      color: _audioPath != null ? Colors.green : null,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return RecordVideoWidget(
                            onRecordingComplete: (path) =>
                                _handleRecordingComplete(path, isVideo: true),
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.videocam,
                      color: _videoPath != null ? Colors.green : null,
                    ),
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
      ),
    );
  }
}
