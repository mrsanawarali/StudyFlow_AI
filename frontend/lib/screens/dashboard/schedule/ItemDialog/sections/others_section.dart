// lib/screens/dashboard/schedule/ItemDialog/sections/others_section.dart
import 'package:flutter/material.dart';
import '../fields/title_field.dart';
import '../fields/details_field.dart';
import '../fields/date_button.dart';
import '../fields/time_button.dart';

class OthersSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final VoidCallback pickStartDate;
  final VoidCallback pickEndDate;
  final VoidCallback pickStartTime;
  final VoidCallback pickEndTime;
  final Color accentColor;

  final String? Function(String?)? titleValidator;

  const OthersSection({
    super.key,
    required this.titleController,
    required this.detailsController,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.pickStartDate,
    required this.pickEndDate,
    required this.pickStartTime,
    required this.pickEndTime,
    required this.accentColor,
    this.titleValidator,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];

    rows.add(TitleField(
      controller: titleController,
      validator: titleValidator, // <-- pass it here
    ),
    );
    rows.add(const SizedBox(height: 12));

    rows.add(
      Row(
        children: [
          Expanded(
            child: DateButton(
              label: 'Start Date (optional)',
              date: startDate,
              onPressed: pickStartDate,
              accentColor: accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TimeButton(
              label: 'Start Time (optional)',
              time: startTime,
              onPressed: pickStartTime,
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );

    if (startDate != null || startTime != null) {
      rows.add(const SizedBox(height: 12));
      rows.add(
        Row(
          children: [
            Expanded(
              child: DateButton(
                label: 'End Date (optional)',
                date: endDate,
                onPressed: pickEndDate,
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TimeButton(
                label: 'End Time (optional)',
                time: endTime,
                onPressed: pickEndTime,
                accentColor: accentColor,
              ),
            ),
          ],
        ),
      );
    }

    rows.add(const SizedBox(height: 12));
    rows.add(DetailsField(controller: detailsController));

    return Column(children: rows);
  }
}
