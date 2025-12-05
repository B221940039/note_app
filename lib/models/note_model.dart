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
    );
  }
}
