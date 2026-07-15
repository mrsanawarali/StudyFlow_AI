class Chapter {
  final String? id;
  final String semesterId;
  final String subjectId;
  final String title;
  final DateTime createdAt;

  Chapter({
    this.id,
    required this.semesterId,
    required this.subjectId,
    required this.title,
    required this.createdAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      semesterId: json['semesterId'],
      subjectId: json['subjectId'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "semesterId": semesterId,
      "subjectId": subjectId,
      "title": title,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
