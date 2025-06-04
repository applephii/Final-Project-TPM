class Task {
  final int? id;
  final String title;
  final String task;
  final String statusTask;

  Task({
    required this.id,
    required this.title,
    required this.task,
    required this.statusTask,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      task: json['task'],
      statusTask: json['statusTask'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'task': task,
      'statusTask': statusTask,
    };
  }
}
