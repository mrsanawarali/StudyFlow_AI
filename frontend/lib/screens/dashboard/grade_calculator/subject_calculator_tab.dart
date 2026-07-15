import 'package:flutter/material.dart';

class SubjectCalculatorTab extends StatefulWidget {
  const SubjectCalculatorTab({super.key});

  @override
  State<SubjectCalculatorTab> createState() => _SubjectCalculatorTabState();
}

class _SubjectCalculatorTabState extends State<SubjectCalculatorTab> {
  bool hasLab = false;

  int quizCount = 1, assignmentCount = 1, labAssignmentCount = 1;

  final Color primaryColor = const Color(0xFF1B2660);

  List<TextEditingController> quizObt = [], quizTotal = [];
  List<TextEditingController> assignObt = [], assignTotal = [];
  List<TextEditingController> labAssignObt = [], labAssignTotal = [];

  final midObt = TextEditingController(), midTotal = TextEditingController();
  final finalObt = TextEditingController(), finalTotal = TextEditingController();
  final labMidObt = TextEditingController(), labMidTotal = TextEditingController();
  final labFinalObt = TextEditingController(), labFinalTotal = TextEditingController();

  double? totalMarks;
  String? grade;
  double? gpa;

  @override
  void initState() {
    super.initState();
    _generateFields();
  }

  void _generateFields() {
    quizObt = List.generate(quizCount, (_) => TextEditingController());
    quizTotal = List.generate(quizCount, (_) => TextEditingController());
    assignObt = List.generate(assignmentCount, (_) => TextEditingController());
    assignTotal = List.generate(assignmentCount, (_) => TextEditingController());
    labAssignObt = List.generate(labAssignmentCount, (_) => TextEditingController());
    labAssignTotal = List.generate(labAssignmentCount, (_) => TextEditingController());
  }

  double _calcPercent(String obt, String total) {
    double o = double.tryParse(obt) ?? 0;
    double t = double.tryParse(total) ?? 1;
    return t == 0 ? 0 : (o / t) * 100;
  }

  Map<String, dynamic> _getGradeInfo(double percent) {
    if (percent >= 85) return {'grade': 'A', 'gpa': 4.00};
    if (percent >= 80) return {'grade': 'A–', 'gpa': 3.66};
    if (percent >= 75) return {'grade': 'B+', 'gpa': 3.33};
    if (percent >= 71) return {'grade': 'B', 'gpa': 3.00};
    if (percent >= 68) return {'grade': 'B–', 'gpa': 2.66};
    if (percent >= 64) return {'grade': 'C+', 'gpa': 2.33};
    if (percent >= 61) return {'grade': 'C', 'gpa': 2.00};
    if (percent >= 58) return {'grade': 'C–', 'gpa': 1.66};
    if (percent >= 54) return {'grade': 'D+', 'gpa': 1.30};
    if (percent >= 50) return {'grade': 'D', 'gpa': 1.00};
    return {'grade': 'F', 'gpa': 0.00};
  }

  void calculateMarks() {
    double avg(List<TextEditingController> obt, List<TextEditingController> total) {
      double sum = 0;
      for (int i = 0; i < obt.length; i++) sum += _calcPercent(obt[i].text, total[i].text);
      return obt.isEmpty ? 0 : sum / obt.length;
    }

    double theory = avg(assignObt, assignTotal) * 0.10 +
        avg(quizObt, quizTotal) * 0.15 +
        _calcPercent(midObt.text, midTotal.text) * 0.25 +
        _calcPercent(finalObt.text, finalTotal.text) * 0.50;

    double lab = 0;
    if (hasLab) {
      lab = avg(labAssignObt, labAssignTotal) * 0.25 +
          _calcPercent(labMidObt.text, labMidTotal.text) * 0.25 +
          _calcPercent(labFinalObt.text, labFinalTotal.text) * 0.50;
      totalMarks = theory * 0.67 + lab * 0.33;
    } else {
      totalMarks = theory;
    }

    final info = _getGradeInfo(totalMarks ?? 0);
    grade = info['grade'];
    gpa = info['gpa'];

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

  Widget _buildSection(String title, Widget child, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
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

  Widget _buildDynamicFields(String title, List<TextEditingController> obt, List<TextEditingController> total) {
    return Column(
      children: List.generate(obt.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(child: _buildField('$title ${i + 1} (Obt.)', obt[i])),
              const SizedBox(width: 10),
              Expanded(child: _buildField('$title ${i + 1} (Total)', total[i])),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCountSelector(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0F2C),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(
              'Subject has Lab',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            value: hasLab,
            activeColor: Colors.white,
            onChanged: (v) => setState(() => hasLab = v),
          ),

          _buildCountSelector('Assignments:', assignmentCount, (v) {
            setState(() {
              assignmentCount = v;
              _generateFields();
            });
          }),

          _buildCountSelector('Quizzes:', quizCount, (v) {
            setState(() {
              quizCount = v;
              _generateFields();
            });
          }),

          _buildSection(
            'Assignments',
            _buildDynamicFields('Assignment', assignObt, assignTotal),
            icon: Icons.assignment,
          ),

          _buildSection(
            'Quizzes',
            _buildDynamicFields('Quiz', quizObt, quizTotal),
            icon: Icons.quiz,
          ),

          _buildSection(
            'Midterm',
            Row(
              children: [
                Expanded(child: _buildField('Mid (Obt.)', midObt)),
                const SizedBox(width: 10),
                Expanded(child: _buildField('Mid (Total)', midTotal)),
              ],
            ),
            icon: Icons.timelapse,
          ),

          _buildSection(
            'Final Exam',
            Row(
              children: [
                Expanded(child: _buildField('Final (Obt.)', finalObt)),
                const SizedBox(width: 10),
                Expanded(child: _buildField('Final (Total)', finalTotal)),
              ],
            ),
            icon: Icons.check_circle,
          ),

          if (hasLab) ...[
            _buildCountSelector('Lab Assignments:', labAssignmentCount, (v) {
              setState(() {
                labAssignmentCount = v;
                _generateFields();
              });
            }),

            _buildSection(
              'Lab Assignments',
              _buildDynamicFields('Lab Assignment', labAssignObt, labAssignTotal),
              icon: Icons.science,
            ),

            _buildSection(
              'Lab Midterm',
              Row(
                children: [
                  Expanded(child: _buildField('Lab Mid (Obt.)', labMidObt)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField('Lab Mid (Total)', labMidTotal)),
                ],
              ),
              icon: Icons.timelapse,
            ),

            _buildSection(
              'Lab Final',
              Row(
                children: [
                  Expanded(child: _buildField('Lab Final (Obt.)', labFinalObt)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField('Lab Final (Total)', labFinalTotal)),
                ],
              ),
              icon: Icons.check_circle,
            ),
          ],

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: calculateMarks,
            child: const Text('Calculate', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),

          if (totalMarks != null)
            _buildSection(
              'Result',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stacked_bar_chart, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Total Marks: ${totalMarks!.toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: primaryColor),
                      const SizedBox(width: 8),
                      Text('Grade: $grade', style: const TextStyle(fontSize: 18, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: primaryColor),
                      const SizedBox(width: 8),
                      Text('GPA: ${gpa!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
