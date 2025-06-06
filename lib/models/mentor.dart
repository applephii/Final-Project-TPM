class Mentor {
  final int id;
  final String name;
  final String expertise;
  final String location;
  final int timezoneOffset;
  final String timezone;
  final String imgUrl;
  bool isFavorite;

  Mentor({
    required this.id,
    required this.name,
    required this.expertise,
    required this.location,
    required this.timezoneOffset,
    required this.timezone,
    required this.imgUrl,
    this.isFavorite = false,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'],
      name: json['name'],
      expertise: json['expertise'],
      location: json['location'],
      timezoneOffset: json['timezoneOffset'],
      timezone: json['timezone'],
      imgUrl: json['imgUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expertise': expertise,
      'location': location,
      'timezoneOffset': timezoneOffset,
      'timezone': timezone,
      'imgUrl': imgUrl,
    };
  }

  DateTime getCurrentMentorTime() {
    return DateTime.now().toUtc().add(Duration(minutes: timezoneOffset));
  }
}
