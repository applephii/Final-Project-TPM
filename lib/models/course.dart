class MentorCourse {
  final int id;
  final int mentorId;
  final String statusPublish;
  final double price;
  final String title;
  final String description;

  MentorCourse({
    required this.id,
    required this.mentorId,
    required this.statusPublish,
    required this.price,
    required this.title,
    required this.description,
  });

  factory MentorCourse.fromJson(Map<String, dynamic> json) {
    return MentorCourse(
      id: json['id'],
      mentorId: json['mentorId'],
      statusPublish: json['status_publish'],
      price: (json['price'] as num).toDouble(),
      title: json['title'],
      description: json['desc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentorId': mentorId,
      'status_publish': statusPublish,
      'price': price,
      'title': title,
      'desc': description,
    };
  }
}
