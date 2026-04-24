class Task {
  String id;
  String title;
  String description;
  bool isDone;
  String createdAt;

  Task({
    this.id = '',
    required this.title,
    this.description = "",
    required this.isDone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': createdAt,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
      createdAt: map['createdAt'] ?? '',
    );
  }
}
