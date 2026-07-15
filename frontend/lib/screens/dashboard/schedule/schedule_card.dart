import 'package:flutter/material.dart';
import 'models/schedule_item.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  final String type;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const ScheduleCard({
    super.key,
    required this.item,
    required this.type,
    required this.onDelete,
    this.onEdit,

  });

  Color getTypeColor() {
    switch (type) {
      case 'Classes':
        return Colors.blueAccent;
      case 'Quizzes':
        return Colors.orangeAccent;
      case 'Assignments':
        return Colors.purpleAccent;
      case 'Others':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return date.toLocal().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = getTypeColor();

    List<Widget> infoLines = [];

    switch (type) {
      case 'Classes':
        if (item.startTime != null && item.startTime!.isNotEmpty) {
          String line = item.startTime!;
          if (item.endTime != null && item.endTime!.isNotEmpty) {
            line += ' – ${item.endTime}';
          }
          infoLines.add(Text(line, style: const TextStyle(color: Colors.black54)));
        }
        break;

      case 'Quizzes':
      case 'Assignments':
        if (item.startDate != null) {
          infoLines.add(Text(_formatDate(item.startDate), style: const TextStyle(color: Colors.black54)));
        }
        if (item.startTime != null && item.startTime!.isNotEmpty) {
          infoLines.add(Text(item.startTime!, style: const TextStyle(color: Colors.black54)));
        }
        break;

      case 'Others':
        if (item.startDate != null || (item.startTime != null && item.startTime!.isNotEmpty)) {
          infoLines.add(Text(
            'Starts: ${item.startDate != null ? _formatDate(item.startDate) : ""}${item.startTime != null ? " • ${item.startTime}" : ""}',
            style: const TextStyle(color: Colors.black54),
          ));
        }
        if (item.endDate != null || (item.endTime != null && item.endTime!.isNotEmpty)) {
          infoLines.add(Text(
            'Ends: ${item.endDate != null ? _formatDate(item.endDate) : ""}${item.endTime != null ? " • ${item.endTime}" : ""}',
            style: const TextStyle(color: Colors.black54),
          ));
        }
        break;
    }

    // Room and details
    if (item.room != null && item.room!.isNotEmpty) {
      infoLines.add(Text('Room: ${item.room}', style: const TextStyle(color: Colors.black45)));
    }
    if (item.details != null && item.details!.isNotEmpty) {
      infoLines.add(Text(item.details!, style: const TextStyle(color: Colors.black45)));
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: typeColor, width: 5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            item.title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: infoLines,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: const Color(0xFF1B2660)),
                onPressed: onEdit, // <-- callback for editing
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
