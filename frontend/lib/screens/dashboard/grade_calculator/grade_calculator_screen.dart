import 'package:flutter/material.dart';
import 'subject_calculator_tab.dart';
import 'semester_calculator_tab.dart';
import 'cgpa_calculator_tab.dart';
import 'what_if_analysis_tab.dart';

class GradeCalculatorScreen extends StatelessWidget {
  const GradeCalculatorScreen({super.key});

  final Color primaryColor = const Color(0xFF1B2660);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
         appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4, // subtle shadow for depth
        centerTitle: true, // looks good on all platforms
        title: const Text(
          'GPA / Marks Calculator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          isScrollable: true,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3.0, color: Colors.white),
            insets: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Subject GPA'),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Semester GPA'),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('CGPA'),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('What-If Analysis'),
              ),
            ),
          ],
        ),
      ),

      body: const TabBarView(
          children: [
            SubjectCalculatorTab(),
            SemesterCalculatorTab(),
            CgpaCalculatorTab(),
            WhatIfAnalysisTab(),
          ],
        ),
      ),
    );
  }
}
