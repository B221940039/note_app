// User's standalone todo model
class TodoModel {
  final int? id;
  final String title;
  final bool isCompleted;
  final DateTime? createdDate;
  final DateTime? deadline;

  TodoModel({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.createdDate,
    this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'createdDate': createdDate?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'],
      title: map['title'],
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'])
          : null,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
    );
  }

  TodoModel copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdDate,
    DateTime? deadline,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate ?? this.createdDate,
      deadline: deadline ?? this.deadline,
    );
  }
}
