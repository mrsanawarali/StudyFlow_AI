class ScheduleItem {
  final String? id;
  final String userId;
  final String type;
  final String title;

  final String? day;               // Only for Classes
  final String? startTime;         // String "3:30 PM"
  final String? endTime;           // String "4:30 PM"

  final String? room;
  final String? details;

  final DateTime? startDate;       // quizzes/assignments/others
  final DateTime? endDate;         // optional

  ScheduleItem({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.day,
    this.startTime,
    this.endTime,
    this.room,
    this.details,
    this.startDate,
    this.endDate,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
    id: json['id'],
    userId: json['userId'],
    type: json['type'],
    title: json['title'],
    day: json['day'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    room: json['room'],
    details: json['details'],
    startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) "id": id,
    "userId": userId,
    "type": type,
    "title": title,
    if (day != null) "day": day,
    if (startTime != null) "startTime": startTime,
    if (endTime != null) "endTime": endTime,
    if (room != null) "room": room,
    if (details != null) "details": details,
    if (startDate != null) "startDate": startDate!.toIso8601String(),
    if (endDate != null) "endDate": endDate!.toIso8601String(),
  };
}
