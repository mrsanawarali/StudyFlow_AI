class Subject {
  final String? id;
  final String semesterId;
  final String title;
  final String courseCode;
  final String instructor;
  final DateTime createdAt;

  Subject({
    this.id,
    required this.semesterId,
    required this.title,
    this.courseCode = '',
    this.instructor = '',
    required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      semesterId: json['semesterId'],
      title: json['title'],
      courseCode: json['courseCode'] ?? '',
      instructor: json['instructor'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "semesterId": semesterId,
      "title": title,
      "courseCode": courseCode,
      "instructor": instructor,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
