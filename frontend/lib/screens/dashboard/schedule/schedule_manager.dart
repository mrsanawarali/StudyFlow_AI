import 'models/schedule_item.dart';

class ScheduleManager {
  static const List<String> weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static Map<String, List<ScheduleItem>> groupClassesByDay(List<ScheduleItem> items) {
    final classes = items.where((item) => item.type == 'Classes').toList();

    final Map<String, List<ScheduleItem>> grouped = {
      for (var day in weekDays) day: []
    };

    for (var item in classes) {
      final day = item.day ?? 'Monday';
      grouped[day]?.add(item);
    }

    for (var day in weekDays) {
      grouped[day]?.sort((a, b) {
        final startA = _timeStringToMinutes(a.startTime ?? '12:00 AM');
        final startB = _timeStringToMinutes(b.startTime ?? '12:00 AM');
        return startA.compareTo(startB);
      });
    }

    return grouped;
  }

  static int _timeStringToMinutes(String t) {
    final parts = t.split(' ');
    final hm = parts[0].split(':').map(int.parse).toList();
    int h = hm[0];
    final m = hm[1];
    final period = parts[1].toUpperCase();
    if (period == 'PM' && h != 12) h += 12;
    if (period == 'AM' && h == 12) h = 0;
    return h * 60 + m;
  }
}
