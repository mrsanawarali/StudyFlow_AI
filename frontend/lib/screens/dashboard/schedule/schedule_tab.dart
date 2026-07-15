import 'package:flutter/material.dart';
import 'package:untitled/screens/dashboard/schedule/schedule_notification_manager.dart';
import 'ItemDialog/item_dialog.dart';
import 'api_service.dart';
import 'models/hive_service.dart';
import 'models/network_utils.dart';
import 'models/schedule_item_local.dart';
import 'schedule_card.dart';
import 'models/schedule_item.dart';
import 'schedule_manager.dart';
import 'package:collection/collection.dart';

class ScheduleTab extends StatefulWidget {
  final List<ScheduleItem> items;
  final String type;
  final VoidCallback onUpdate;

  const ScheduleTab({
    super.key,
    required this.items,
    required this.type,
    required this.onUpdate,
  });

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  String _searchQuery = '';
  bool _isSorted = false;

  // Filter out deleted items from Hive before rendering
  List<ScheduleItem> get _visibleItems {
    return widget.items.where((item) {
      final local = HiveService.getAll().firstWhereOrNull(
            (i) => i.serverId == item.id,
      );
      return local == null || !local.isDeleted;
    }).toList();
  }


  Color getTypeColor() {
    switch (widget.type) {
      case 'Classes': return Colors.blueAccent;
      case 'Quizzes': return Colors.orangeAccent;
      case 'Assignments': return Colors.purpleAccent;
      case 'Others': return Colors.teal;
      default: return Colors.grey;
    }
  }

  Future<void> _deleteItem(ScheduleItem item) async {
    try {
      final localItem = HiveService.getAll().firstWhereOrNull((i) {
        if (i.serverId != null) return i.serverId == item.id;
        // fallback for offline-created items
        return i.title == item.title && i.startDate == item.startDate;
      });

      if (localItem != null) {

        await HiveService.deleteItemOfflineFirst(localItem);

        // Remove from UI immediately
        setState(() {
          widget.items.removeWhere(
                (i) => i.id == localItem.serverId || i.id == item.id,
          );
        });

        // Cancel notification
        await ScheduleNotificationManager.cancelItem(localItem);


        widget.onUpdate();
      } else {
        print("No matching local item found for deletion: ${item.id ?? item.title}");
      }
    } catch (e) {
      print('Failed to delete: $e');
    }
  }


  void _showAddDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => ItemDialog(
        type: widget.type,
        existingItem: null,
        onSubmit: (item) {
          setState(() { widget.items.add(item); });
          widget.onUpdate();
        },
      ),
    );
  }

  void _showEditDialog(ScheduleItem item) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => ItemDialog(
        type: widget.type,
        existingItem: item,
        onSubmit: (updatedItem) {
          setState(() {
            final index = widget.items.indexWhere((i) => i.id == updatedItem.id);
            if (index != -1) widget.items[index] = updatedItem;
          });
          widget.onUpdate();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = getTypeColor();

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.type}',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1A1F3F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: typeColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: typeColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _isSorted = !_isSorted),
                    icon: Icon(Icons.sort, color: _isSorted ? typeColor : Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.type == 'Classes' ? _buildClassesList() : _buildOtherList(),
            ),
          ],
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: FloatingActionButton.extended(
            onPressed: _showAddDialog,
            label: const Text('Add Item', style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.add, color: Colors.white),
            backgroundColor: typeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildClassesList() {
    final grouped = ScheduleManager.groupClassesByDay(
      _visibleItems.where(
              (item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList(),
    );

    final List<Widget> list = [];
    final typeColor = Colors.blueAccent;

    for (var day in ScheduleManager.weekDays) {
      final dayItems = grouped[day]!;

      list.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(day, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

      if (dayItems.isEmpty) {
        list.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 20),
            child: Text('No Classes', style: TextStyle(color: Colors.white38, fontSize: 14, fontStyle: FontStyle.italic)),
          ),
        );
      } else {
        for (var item in dayItems) {
          list.add(
            ScheduleCard(
              item: item,
              type: widget.type,
              onDelete: () => _deleteItem(item),
              onEdit: () => _showEditDialog(item),
            ),
          );
        }
      }
    }

    return ListView(padding: const EdgeInsets.fromLTRB(0, 8, 0, 70), children: list);
  }

  Widget _buildOtherList() {
    var filtered = _visibleItems
        .where((item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (_isSorted) filtered.sort(_compareScheduleItems);

    if (filtered.isEmpty) {
      return Center(child: Text('No ${widget.type} found', style: const TextStyle(color: Colors.white70, fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 70),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return ScheduleCard(
          item: item,
          type: widget.type,
          onDelete: () => _deleteItem(item),
          onEdit: () => _showEditDialog(item),
        );
      },
    );
  }

  int _compareScheduleItems(ScheduleItem a, ScheduleItem b) {
    final aDate = _getSortableDateTime(a);
    final bDate = _getSortableDateTime(b);
    return aDate.compareTo(bDate);
  }

  DateTime _getSortableDateTime(ScheduleItem item) {
    if (item.startDate != null && item.startTime != null) {
      final dt = _combineDateTime(item.startDate, item.startTime);
      if (dt != null) return dt;
    }
    if (item.startDate != null) return item.startDate!;
    if (item.endDate != null) return item.endDate!;
    return DateTime(2100);
  }

  DateTime? _combineDateTime(DateTime? date, String? time) {
    if (date == null || time == null) return null;
    final regex = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
    final match = regex.firstMatch(time);
    if (match == null) return null;

    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
