import 'package:flutter/material.dart';
import 'dart:convert';

class NoteModel {
  final int? id;
  final String title;
  final String content;
  final DateTime dateCreated;
  final String tag;
  final Color? color;
  final String? audioPath;
  final String? videoPath;
  final List<Map<String, dynamic>> todoItems;
  final bool isSaved;
  final bool isHidden;
  final bool isDeleted;
  final bool isBold;
  final bool isUnderline;
  final bool isItalic;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.color,
    required this.dateCreated,
    this.audioPath,
    this.videoPath,
    this.todoItems = const [],
    this.isSaved = false,
    this.isHidden = false,
    this.isDeleted = false,
    this.isBold = false,
    this.isUnderline = false,
    this.isItalic = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tag': tag,
      'color': color?.value,
      'dateCreated': dateCreated.toIso8601String(),
      'audioPath': audioPath,
      'videoPath': videoPath,
      'todoItems': jsonEncode(todoItems),
      'isSaved': isSaved ? 1 : 0,
      'isHidden': isHidden ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'isBold': isBold ? 1 : 0,
      'isUnderline': isUnderline ? 1 : 0,
      'isItalic': isItalic ? 1 : 0,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      tag: map['tag'],
      color: map['color'] != null ? Color(map['color']) : null,
      dateCreated: DateTime.parse(map['dateCreated']),
      audioPath: map['audioPath'],
      videoPath: map['videoPath'],
      todoItems: map['todoItems'] != null
          ? List<Map<String, dynamic>>.from(jsonDecode(map['todoItems']))
          : [],
      isSaved: map['isSaved'] == 1,
      isHidden: map['isHidden'] == 1,
      isDeleted: map['isDeleted'] == 1,
      isBold: (map['isBold'] ?? 0) == 1,
      isUnderline: (map['isUnderline'] ?? 0) == 1,
      isItalic: (map['isItalic'] ?? 0) == 1,
    );
  }
}
