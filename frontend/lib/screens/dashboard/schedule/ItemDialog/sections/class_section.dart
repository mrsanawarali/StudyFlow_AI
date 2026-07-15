// lib/screens/dashboard/schedule/ItemDialog/sections/class_section.dart
import 'package:flutter/material.dart';
import '../fields/day_dropdown.dart';
import '../fields/time_button.dart';
import '../fields/room_field.dart';
import '../fields/title_field.dart';
import '../fields/details_field.dart';

class ClassSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController roomController;
  final TextEditingController detailsController;
  final String? selectedDay;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<String?> onDayChanged;
  final VoidCallback pickStartTime;
  final VoidCallback pickEndTime;
  final Color accentColor;

  final String? Function(String?)? titleValidator;

  const ClassSection({
    super.key,
    required this.titleController,
    required this.roomController,
    required this.detailsController,
    required this.selectedDay,
    required this.startTime,
    required this.endTime,
    required this.onDayChanged,
    required this.pickStartTime,
    required this.pickEndTime,
    required this.accentColor,
    this.titleValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleField(
          controller: titleController,
          validator: titleValidator, // <-- pass it here
        ),
        const SizedBox(height: 12),
        RoomField(controller: roomController),
        const SizedBox(height: 12),
        DayDropdown(selectedDay: selectedDay, onChanged: onDayChanged),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TimeButton(
                label: 'Start Time',
                time: startTime,
                onPressed: pickStartTime,
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TimeButton(
                label: 'End Time',
                time: endTime,
                onPressed: pickEndTime,
                accentColor: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DetailsField(controller: detailsController),
      ],
    );
  }
}
