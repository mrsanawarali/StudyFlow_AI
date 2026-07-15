import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WhatIfAnalysisTab extends StatefulWidget {
  const WhatIfAnalysisTab({super.key});

  @override
  State<WhatIfAnalysisTab> createState() => _WhatIfAnalysisTabState();
}

class _WhatIfAnalysisTabState extends State<WhatIfAnalysisTab> {
  final primaryColor = const Color(0xFF1B2660);

  bool includeLab = false;

  int totalQuizzes = 4;
  int totalAssignments = 4;
  int totalLabAssignments = 4;

  // Controllers
  List<TextEditingController> quizObt = [];
  List<TextEditingController> quizTotal = [];
  List<TextEditingController> assignObt = [];
  List<TextEditingController> assignTotal = [];

  final midObt = TextEditingController();
  final midTotal = TextEditingController();
  final finalObt = TextEditingController();
  final finalTotal = TextEditingController();

  List<TextEditingController> labAssignObt = [];
  List<TextEditingController> labAssignTotal = [];
  final labMidObt = TextEditingController();
  final labMidTotal = TextEditingController();
  final labFinalObt = TextEditingController();
  final labFinalTotal = TextEditingController();

  double? marksEarned;
  double? marksLost;
  double? marksRemaining;
  double? maxAchievable;

  @override
  void initState() {
    super.initState();
    _updateFieldCount();
  }

  /// Updates controller lists according to counts, preserving existing values
  void _updateFieldCount() {
    void resizeList(List<TextEditingController> list, int target) {
      while (list.length < target) list.add(TextEditingController());
      while (list.length > target) list.removeLast();
    }

    resizeList(quizObt, totalQuizzes);
    resizeList(quizTotal, totalQuizzes);

    resizeList(assignObt, totalAssignments);
    resizeList(assignTotal, totalAssignments);

    resizeList(labAssignObt, totalLabAssignments);
    resizeList(labAssignTotal, totalLabAssignments);
  }

  double _itemPercent(String obtStr, String totalStr) {
    final obt = double.tryParse(obtStr);
    final total = double.tryParse(totalStr);
    if (obt == null || total == null || total <= 0) return double.nan;
    return (obt / total) * 100;
  }

  Map<String, double> _averagePercent(
      List<TextEditingController> obt, List<TextEditingController> total) {
    double sum = 0;
    int completed = 0;
    for (int i = 0; i < obt.length; i++) {
      final perc = _itemPercent(obt[i].text, total[i].text);
      if (perc.isFinite) {
        sum += perc;
        completed++;
      }
    }
    double avg = completed > 0 ? sum / completed : 0;
    return {'avg': avg, 'completed': completed.toDouble()};
  }

  void analyze() {
    // Component weights within each section (they sum to 100 locally)
    const double assignWeight = 10;
    const double quizWeight = 15;
    const double midWeight = 25;
    const double finalWeight = 50;

    const double labAssignWeight = 25;
    const double labMidWeight = 25;
    const double labFinalWeight = 50;

    // --- Theory and Lab calculations are done separately ---
    double theoryEarned = 0, theoryLost = 0, theoryRemaining = 0;
    double labEarned = 0, labLost = 0, labRemaining = 0;

    // ========================= THEORY SECTION =========================
    // Assignments
    for (int i = 0; i < assignObt.length; i++) {
      final obt = double.tryParse(assignObt[i].text);
      final total = double.tryParse(assignTotal[i].text);
      double itemWeight = assignWeight / totalAssignments;

      if (obt != null && total != null && total > 0) {
        theoryEarned += (obt / total) * itemWeight;
        theoryLost += ((total - obt) / total) * itemWeight;
      } else {
        theoryRemaining += itemWeight;
      }
    }

    // Quizzes
    for (int i = 0; i < quizObt.length; i++) {
      final obt = double.tryParse(quizObt[i].text);
      final total = double.tryParse(quizTotal[i].text);
      double itemWeight = quizWeight / totalQuizzes;

      if (obt != null && total != null && total > 0) {
        theoryEarned += (obt / total) * itemWeight;
        theoryLost += ((total - obt) / total) * itemWeight;
      } else {
        theoryRemaining += itemWeight;
      }
    }

    // Mid
    final midO = double.tryParse(midObt.text);
    final midT = double.tryParse(midTotal.text);
    if (midO != null && midT != null && midT > 0) {
      theoryEarned += (midO / midT) * midWeight;
      theoryLost += ((midT - midO) / midT) * midWeight;
    } else {
      theoryRemaining += midWeight;
    }

    // Final
    final finalO = double.tryParse(finalObt.text);
    final finalT = double.tryParse(finalTotal.text);
    if (finalO != null && finalT != null && finalT > 0) {
      theoryEarned += (finalO / finalT) * finalWeight;
      theoryLost += ((finalT - finalO) / finalT) * finalWeight;
    } else {
      theoryRemaining += finalWeight;
    }

    // ========================= LAB SECTION =========================
    if (includeLab) {
      for (int i = 0; i < labAssignObt.length; i++) {
        final obt = double.tryParse(labAssignObt[i].text);
        final total = double.tryParse(labAssignTotal[i].text);
        double itemWeight = labAssignWeight / totalLabAssignments;

        if (obt != null && total != null && total > 0) {
          labEarned += (obt / total) * itemWeight;
          labLost += ((total - obt) / total) * itemWeight;
        } else {
          labRemaining += itemWeight;
        }
      }

      final lMidO = double.tryParse(labMidObt.text);
      final lMidT = double.tryParse(labMidTotal.text);
      if (lMidO != null && lMidT != null && lMidT > 0) {
        labEarned += (lMidO / lMidT) * labMidWeight;
        labLost += ((lMidT - lMidO) / lMidT) * labMidWeight;
      } else {
        labRemaining += labMidWeight;
      }

      final lFinalO = double.tryParse(labFinalObt.text);
      final lFinalT = double.tryParse(labFinalTotal.text);
      if (lFinalO != null && lFinalT != null && lFinalT > 0) {
        labEarned += (lFinalO / lFinalT) * labFinalWeight;
        labLost += ((lFinalT - lFinalO) / lFinalT) * labFinalWeight;
      } else {
        labRemaining += labFinalWeight;
      }
    }

    // ========================= FINAL COMBINATION =========================
    double totalEarned, totalLost, totalRemaining;

    if (includeLab) {
      // Apply 67/33 scaling
      totalEarned = (theoryEarned * 0.67) + (labEarned * 0.33);
      totalLost = (theoryLost * 0.67) + (labLost * 0.33);
      totalRemaining = (theoryRemaining * 0.67) + (labRemaining * 0.33);
    } else {
      // No lab = theory contributes 100%
      totalEarned = theoryEarned;
      totalLost = theoryLost;
      totalRemaining = theoryRemaining;
    }

    setState(() {
      marksEarned = totalEarned;
      marksLost = totalLost;
      marksRemaining = totalRemaining;
      maxAchievable = totalEarned + totalRemaining;
    });
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

  Widget _buildCountSelector(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: primaryColor)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove, color: primaryColor),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$value', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: Icon(Icons.add, color: primaryColor),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
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
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
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

  Widget _buildItemInputs(String title, List<TextEditingController> obtList, List<TextEditingController> totalList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
        const SizedBox(height: 8),
        for (int i = 0; i < obtList.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(child: _buildField('$title ${i + 1} Obt.', obtList[i])),
                const SizedBox(width: 8),
                Expanded(child: _buildField('$title ${i + 1} Total', totalList[i])),
              ],
            ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0F2C),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Settings',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text(
                    'Include Lab section',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
                  ),
                  value: includeLab,
                  onChanged: (v) => setState(() => includeLab = v),
                ),
                _buildCountSelector('Quizzes:', totalQuizzes, (v) => setState(() {
                  totalQuizzes = v;
                  _updateFieldCount();
                })),
                _buildCountSelector('Assignments (Theory):', totalAssignments, (v) => setState(() {
                  totalAssignments = v;
                  _updateFieldCount();
                })),
                if (includeLab)
                  _buildCountSelector('Lab Assignments:', totalLabAssignments, (v) => setState(() {
                    totalLabAssignments = v;
                    _updateFieldCount();
                  })),
              ],
            ),
            icon: Icons.settings,
          ),
          _buildSection('Quizzes', _buildItemInputs('Quiz', quizObt, quizTotal), icon: Icons.quiz),
          _buildSection('Assignments', _buildItemInputs('Assignment', assignObt, assignTotal), icon: Icons.assignment),
          _buildSection(
            'Mid & Final (Theory)',
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildField('Mid Obtained', midObt)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField('Mid Total', midTotal)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildField('Final Obtained', finalObt)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField('Final Total', finalTotal)),
                  ],
                ),
              ],
            ),
            icon: Icons.school,
          ),
          if (includeLab) ...[
            _buildSection('Lab Assignments', _buildItemInputs('Lab Assignment', labAssignObt, labAssignTotal),
                icon: Icons.biotech),
            _buildSection(
              'Lab Mid & Final',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildField('Lab Mid Obtained', labMidObt)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildField('Lab Mid Total', labMidTotal)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildField('Lab Final Obtained', labFinalObt)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildField('Lab Final Total', labFinalTotal)),
                    ],
                  ),
                ],
              ),
              icon: Icons.biotech_outlined,
            ),
          ],
          const SizedBox(height: 20),
          _buildButton('Analyze What-If', analyze),
          if (marksEarned != null && marksRemaining != null)
            _buildSection(
              'Result',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marks Earned: ${marksEarned!.toStringAsFixed(2)} / 100',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Marks Lost: ${marksLost?.toStringAsFixed(2) ?? "0"} / 100'),
                  Text('Marks Remaining: ${marksRemaining!.toStringAsFixed(2)} / 100'),
                  Text('Max Achievable: ${maxAchievable?.toStringAsFixed(2) ?? "0"} / 100',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: marksEarned!,
                            color: primaryColor,
                            title: marksEarned! > 5 ? 'Earned\n${marksEarned!.toStringAsFixed(1)}' : '',
                            radius: 60,
                            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                            titlePositionPercentageOffset: 0.6,
                          ),
                          PieChartSectionData(
                            value: marksRemaining!,
                            color: Colors.orange,
                            title: marksRemaining! > 5 ? 'Remaining\n${marksRemaining!.toStringAsFixed(1)}' : '',
                            radius: 60,
                            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                            titlePositionPercentageOffset: 0.6,
                          ),
                          if ((marksLost ?? 0) > 0)
                            PieChartSectionData(
                              value: marksLost!,
                              color: Colors.red,
                              title: marksLost! > 5 ? 'Lost\n${marksLost!.toStringAsFixed(1)}' : '',
                              radius: 60,
                              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                              titlePositionPercentageOffset: 0.6,
                            ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
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
