// lib/screens/dashboard/schedule/ItemDialog/sections/quiz_section.dart
import 'package:flutter/material.dart';
import '../fields/title_field.dart';
import '../fields/details_field.dart';
import '../fields/date_button.dart';
import '../fields/time_button.dart';

class QuizSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final DateTime? date;
  final TimeOfDay? time;
  final VoidCallback pickDate;
  final VoidCallback pickTime;
  final Color accentColor;

  final String? Function(String?)? titleValidator;

  const QuizSection({
    super.key,
    required this.titleController,
    required this.detailsController,
    required this.date,
    required this.time,
    required this.pickDate,
    required this.pickTime,
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
        Row(
          children: [
            Expanded(
              child: DateButton(
                label: 'Date',
                date: date,
                onPressed: pickDate,
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TimeButton(
                label: 'Time',
                time: time,
                onPressed: pickTime,
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
