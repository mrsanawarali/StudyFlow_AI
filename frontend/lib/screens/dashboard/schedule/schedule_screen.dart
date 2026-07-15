// schedule_screen.dart
import 'package:flutter/material.dart';
import 'models/hive_service.dart';
import 'schedule_tab.dart';
import 'models/schedule_item.dart';


class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, List<ScheduleItem>> _items = {
    'Classes': [],
    'Quizzes': [],
    'Assignments': [],
    'Others': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _items.keys.length, vsync: this);
    _fetchScheduleItems();
  }

  Future<void> _fetchScheduleItems() async {
    const userId = 'testUser123';
    await HiveService.firstTimeSync(userId, _items);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _items.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A0F2C), Color(0xFF1E2340)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
        ),
        title: const Text(
          'My Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: tabs.map((e) => Tab(text: e)).toList(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F2C), Color(0xFF1E2340)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: tabs
              .map(
                (type) => ScheduleTab(
              key: ValueKey(type), // ensures proper rebuild per tab
              items: _items[type]!,
              type: type,
              onUpdate: () => setState(() {}),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
