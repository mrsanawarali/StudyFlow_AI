class Semester {
  final String? id;
  final String userId;
  final String title;
  final DateTime createdAt;

  Semester({
    this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
