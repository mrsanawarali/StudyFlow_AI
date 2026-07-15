import 'package:flutter/material.dart';

class CgpaCalculatorTab extends StatefulWidget {
  const CgpaCalculatorTab({super.key});

  @override
  State<CgpaCalculatorTab> createState() => _CgpaCalculatorTabState();
}

class _CgpaCalculatorTabState extends State<CgpaCalculatorTab> {
  final primaryColor = const Color(0xFF1B2660);

  int semesterCount = 1;
  List<TextEditingController> semesterGpaControllers = [TextEditingController()];
  List<TextEditingController> semesterCreditControllers = [TextEditingController()];

  double? cgpa;

  void _generateFields() {
    semesterGpaControllers = List.generate(semesterCount, (_) => TextEditingController());
    semesterCreditControllers = List.generate(semesterCount, (_) => TextEditingController());
  }

  double _calculateCgpa() {
    double totalGPA = 0;
    double totalCredits = 0;

    for (int i = 0; i < semesterGpaControllers.length; i++) {
      double gpa = double.tryParse(semesterGpaControllers[i].text) ?? 0;
      double credits = double.tryParse(semesterCreditControllers[i].text) ?? 0;

      totalGPA += gpa * credits;
      totalCredits += credits;
    }

    return totalCredits == 0 ? 0 : totalGPA / totalCredits;
  }

  void calculateCgpa() {
    cgpa = _calculateCgpa();
    setState(() {});
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildSemesterRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: _buildField('Semester ${index + 1} GPA', semesterGpaControllers[index])),
          const SizedBox(width: 10),
          Expanded(child: _buildField('Semester ${index + 1} Credits', semesterCreditControllers[index])),
        ],
      ),
    );
  }

  Widget _buildCountSelector(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove, color: Colors.white),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildSection(String title, Widget child, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, color: primaryColor, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _generateFields();

    return Container(
      color: const Color(0xFF0A0F2C),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCountSelector('Semesters:', semesterCount, (v) {
            setState(() {
              semesterCount = v;
            });
          }),
          const SizedBox(height: 12),
          _buildSection(
            'Semester Details',
            Column(
              children: List.generate(semesterCount, (i) => _buildSemesterRow(i)),
            ),
            icon: Icons.school,
          ),
          const SizedBox(height: 20),
          _buildButton('Calculate CGPA', calculateCgpa),
          const SizedBox(height: 20),
          if (cgpa != null)
            _buildSection(
              'Result',
              Row(
                children: [
                  Icon(Icons.trending_up, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'CGPA: ${cgpa!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ],
              ),
              icon: Icons.bar_chart,
            ),
        ],
      ),
    );
  }
}
