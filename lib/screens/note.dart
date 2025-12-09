import '../widgets/recordvideo.dart';
import 'package:flutter/material.dart';
import '../widgets/todo.dart';
import '../widgets/recordaudio.dart';
import '../widgets/audioplayerwidget.dart';
import '../widgets/videoplayerwidget.dart';
import '../widgets/typography_picker.dart';
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
  List<String> _audioPaths = [];
  List<String> _videoPaths = [];
  bool _isEditMode = false;
  bool _isSaved = false;
  bool _isHidden = false;

  // Text formatting states
  bool _isBold = false;
  bool _isUnderline = false;
  bool _isItalic = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _isEditMode = true;
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = widget.note!.color;
      dateCreated = widget.note!.dateCreated;
      if (widget.note!.audioPath != null &&
          widget.note!.audioPath!.isNotEmpty) {
        _audioPaths = [widget.note!.audioPath!];
      }
      if (widget.note!.videoPath != null &&
          widget.note!.videoPath!.isNotEmpty) {
        _videoPaths = [widget.note!.videoPath!];
      }
      _checkedLists.addAll(widget.note!.todoItems);
      _isSaved = widget.note!.isSaved;
      _isHidden = widget.note!.isHidden;
      _isBold = widget.note!.isBold;
      _isUnderline = widget.note!.isUnderline;
      _isItalic = widget.note!.isItalic;
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

  Color _getTagColor() {
    if (_selectedColor == null) return TypographyPicker.tagColors[0];
    final index = TypographyPicker.noteColors.indexOf(_selectedColor);
    return index >= 0 && index < TypographyPicker.tagColors.length
        ? TypographyPicker.tagColors[index]
        : TypographyPicker.tagColors[0];
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

  // ------------------- Typography Picker -------------------
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return TypographyPicker(
              selectedColor: _selectedColor,
              isBold: _isBold,
              isUnderline: _isUnderline,
              isItalic: _isItalic,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              onBoldToggle: () {
                setState(() => _isBold = !_isBold);
                setModalState(() {}); // Rebuild modal to show changes
                _saveNote(); // Save immediately when formatting changes
              },
              onUnderlineToggle: () {
                setState(() => _isUnderline = !_isUnderline);
                setModalState(() {}); // Rebuild modal to show changes
                _saveNote(); // Save immediately when formatting changes
              },
              onItalicToggle: () {
                setState(() => _isItalic = !_isItalic);
                setModalState(() {}); // Rebuild modal to show changes
                _saveNote(); // Save immediately when formatting changes
              },
            );
          },
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
                'Нэмэлт сонголтууд',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (_isEditMode)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Тэмдэглэл устгах'),
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
      audioPath: _audioPaths.isNotEmpty ? _audioPaths.first : null,
      videoPath: _videoPaths.isNotEmpty ? _videoPaths.first : null,
      todoItems: _checkedLists,
      isSaved: _isSaved,
      isHidden: _isHidden,
      isDeleted: _isEditMode ? widget.note!.isDeleted : false,
      isBold: _isBold,
      isUnderline: _isUnderline,
      isItalic: _isItalic,
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
        title: const Text('Тэмдэглэл устгах'),
        content: const Text('Та энэ тэмдэглэлийг устгахыг хүсч байна уу?'),
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
        _videoPaths.add(filePath);
        print('Video path added: $filePath');
      } else {
        _audioPaths.add(filePath);
        print('Audio path added: $filePath');
      }
    });
  }

  void _deleteAudio(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Аудио устгах'),
        content: const Text('Та энэ аудиог устгахыг хүсч байна уу?'),
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

    if (confirmed == true && index < _audioPaths.length) {
      try {
        final file = File(_audioPaths[index]);
        if (await file.exists()) {
          await file.delete();
        }
        setState(() {
          _audioPaths.removeAt(index);
        });
        if (!mounted) return;
      } catch (e) {
        if (!mounted) return;
      }
    }
  }

  void _deleteVideo(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видео устгах'),
        content: const Text('Та энэ видеог устгахыг хүсч байна уу?'),
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

    if (confirmed == true && index < _videoPaths.length) {
      try {
        final file = File(_videoPaths[index]);
        if (await file.exists()) {
          await file.delete();
        }
        setState(() {
          _videoPaths.removeAt(index);
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
            _isEditMode ? 'Тэмдэглэл засах' : 'Шинэ тэмдэглэл',
            style: const TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            if (_isEditMode)
              IconButton(
                onPressed: () async {
                  final newIsSavedState = !_isSaved;

                  final updatedNote = NoteModel(
                    id: widget.note!.id,
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                    tag: _tags.isEmpty ? 'Untagged' : _tags.join(','),
                    color: _selectedColor,
                    dateCreated: widget.note!.dateCreated,
                    audioPath: _audioPaths.isNotEmpty
                        ? _audioPaths.first
                        : null,
                    videoPath: _videoPaths.isNotEmpty
                        ? _videoPaths.first
                        : null,
                    todoItems: _checkedLists,
                    isSaved: newIsSavedState,
                    isHidden: _isHidden,
                    isDeleted: widget.note!.isDeleted,
                  );

                  await DatabaseHelper.instance.updateNote(updatedNote.toMap());

                  setState(() {
                    _isSaved = newIsSavedState;
                  });

                  if (!mounted) return;
                },
                icon: Icon(
                  _isSaved ? Icons.star : Icons.star_border,
                  color: _isSaved ? Colors.amber : null,
                ),
                tooltip: _isSaved ? 'Хадгалсанаас хасах' : 'Хадгалах',
              ),
            if (_isEditMode)
              IconButton(
                onPressed: () async {
                  final newIsHiddenState = !_isHidden;

                  final updatedNote = NoteModel(
                    id: widget.note!.id,
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                    tag: _tags.isEmpty ? 'Untagged' : _tags.join(','),
                    color: _selectedColor,
                    dateCreated: widget.note!.dateCreated,
                    audioPath: _audioPaths.isNotEmpty
                        ? _audioPaths.first
                        : null,
                    videoPath: _videoPaths.isNotEmpty
                        ? _videoPaths.first
                        : null,
                    todoItems: _checkedLists,
                    isSaved: _isSaved,
                    isHidden: newIsHiddenState,
                    isDeleted: widget.note!.isDeleted,
                  );

                  await DatabaseHelper.instance.updateNote(updatedNote.toMap());

                  setState(() {
                    _isHidden = newIsHiddenState;
                  });

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newIsHiddenState
                            ? 'Тэмдэглэл нуугдлаа'
                            : 'Тэмдэглэл нуухаас хасагдлаа',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(
                  _isHidden ? Icons.visibility_off : Icons.visibility,
                  color: _isHidden ? Colors.blue : null,
                ),
                tooltip: _isHidden ? 'Нуухаас гаргах' : 'Нуух',
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
                                        decoration: InputDecoration(
                                          hintText: 'Түлхүүр үг...',
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

                    // Text formatting toolbar

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
                        style: TextStyle(
                          color: Color.fromARGB(255, 16, 17, 16),
                          fontSize: 16,
                          fontWeight: _isBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          decoration: _isUnderline
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          fontStyle: _isItalic
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Todo List
                    ToDo(
                      checkedLists: _checkedLists,
                      inputController: _inputToDoController,
                      showAllTodos: true, // Show all todos in note screen
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
                      onDeleteUserTodo: (index) {
                        setState(() {
                          _checkedLists.removeAt(index);
                        });
                      },
                    ),

                    // Audio Players
                    ..._audioPaths.asMap().entries.map((entry) {
                      return AudioPlayerWidget(
                        audioPath: entry.value,
                        onDelete: () => _deleteAudio(entry.key),
                      );
                    }).toList(),

                    // Video Players
                    ..._videoPaths.asMap().entries.map((entry) {
                      return VideoPlayerWidget(
                        videoPath: entry.value,
                        onDelete: () => _deleteVideo(entry.key),
                      );
                    }).toList(),

                    const Divider(),

                    // Date created
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${dateCreated.year}-${dateCreated.month.toString().padLeft(2, '0')}-${dateCreated.day.toString().padLeft(2, '0')} ${dateCreated.hour.toString().padLeft(2, '0')}:${dateCreated.minute.toString().padLeft(2, '0')}',
                        ),
                      ],
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
                    tooltip: 'Өнгө солих',
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
                      color: _audioPaths.isNotEmpty ? Colors.green : null,
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
                      color: _videoPaths.isNotEmpty ? Colors.green : null,
                    ),
                  ),
                  IconButton(
                    onPressed: _showMoreOptions,

                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Нэмэлт сонголтууд',
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
