// item_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/clippers/top_pattern_clipper.dart';
import 'package:untitled/screens/dashboard/schedule/ItemDialog/utils/dialog_validations.dart';
import '../models/hive_service.dart';
import '../models/network_utils.dart' as ConnectivityHelper;
import '../models/schedule_item.dart';
import '../models/schedule_item_local.dart';
import '../schedule_notification_manager.dart';
import 'sections/class_section.dart';
import 'sections/quiz_section.dart';
import 'sections/assignment_section.dart';
import 'sections/others_section.dart';

class ItemDialog extends StatefulWidget {
  final String type;
  final ScheduleItem? existingItem;
  final ValueChanged<ScheduleItem> onSubmit;

  const ItemDialog({
    super.key,
    required this.type,
    this.existingItem,
    required this.onSubmit,
  });

  @override
  State<ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late TextEditingController _roomController;

  String? _selectedDay;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isSubmitting = false;

  bool get isEdit => widget.existingItem != null;
  String get _type => widget.type;

  // 🔥 Shake Animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Text Controllers
    _titleController = TextEditingController(
      text: widget.existingItem?.title ?? '',
    );
    _detailsController = TextEditingController(
      text: widget.existingItem?.details ?? '',
    );
    _roomController = TextEditingController(
      text: widget.existingItem?.room ?? '',
    );

    // Editing existing item
    if (widget.existingItem != null) {
      _selectedDay = widget.existingItem!.day;
      _startDate = widget.existingItem!.startDate;
      _endDate = widget.existingItem!.endDate;
      _startTime = widget.existingItem!.startTime != null
          ? parseTimeOfDay(widget.existingItem!.startTime!)
          : null;
      _endTime = widget.existingItem!.endTime != null
          ? parseTimeOfDay(widget.existingItem!.endTime!)
          : null;
    }

    // Shake animation init
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 12,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    // ✅ Schedule notifications after the first frame if editing
    if (isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ScheduleNotificationManager.rescheduleAll();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _roomController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _shakeDialog() {
    _shakeController.forward(from: 0);
  }

  Color _getAccent() {
    switch (_type) {
      case 'Classes':
        return Colors.blueAccent;
      case 'Quizzes':
        return Colors.orangeAccent;
      case 'Assignments':
        return Colors.purpleAccent;
      default:
        return Colors.tealAccent;
    }
  }

  // 🌟 FIXED DATE PICKER — with correct edit mode logic + NO past dates allowed
  Future<void> _pickDate(bool isStart) async {
    final today = DateTime.now();
    final isEditMode = widget.existingItem != null;

    final current = isStart ? _startDate : _endDate;
    final initial = current ?? today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isEditMode
          ? DateTime(2000)
          : DateTime(today.year, today.month, today.day),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final cleanPicked = DateTime(picked.year, picked.month, picked.day);
      final cleanToday = DateTime(today.year, today.month, today.day);

      // ❌ Reject past dates
      if (cleanPicked.isBefore(cleanToday)) {
        _shakeDialog();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot select a past date.")),
        );
        return;
      }

      // Accept valid date
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ?? TimeOfDay.now());
    final picked = await showTimePicker(context: context, initialTime: initial);

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    // Form validation
    if (!_formKey.currentState!.validate()) {
      _shakeDialog();
      return;
    }

    final validationError = validateSchedule(
      type: _type,
      title: _titleController.text,
      startDate: _startDate,
      startTime: _startTime,
      endDate: _endDate,
      endTime: _endTime,
      day: _selectedDay,
    );

    if (validationError != null) {
      _shakeDialog();
      showErrorSnack(context, validationError);
      return;
    }

    if (mounted) setState(() => _isSubmitting = true);

    try {
      // Create local item
      final localItem = ScheduleItemLocal(
        localId: widget.existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        serverId: widget.existingItem?.id, // null if new
        userId: widget.existingItem?.userId ?? 'testUser123',
        type: _type,
        title: _titleController.text.trim(),
        day: _selectedDay,
        startTime: _startTime != null ? formatTime(_startTime) : null,
        endTime: _endTime != null ? formatTime(_endTime) : null,
        room: _roomController.text.trim().isNotEmpty ? _roomController.text.trim() : null,
        details: _detailsController.text.trim().isNotEmpty ? _detailsController.text.trim() : null,
        startDate: _startDate,
        endDate: _endDate,
        isSynced: false, // always false initially
        isDeleted: false,
      );

      // Save locally first
      await HiveService.addOrUpdateItem(localItem);

      // Update UI immediately
      widget.onSubmit(
        ScheduleItem(
          id: localItem.serverId ?? localItem.localId,
          userId: localItem.userId,
          type: localItem.type,
          title: localItem.title,
          day: localItem.day,
          startTime: localItem.startTime,
          endTime: localItem.endTime,
          room: localItem.room,
          details: localItem.details,
          startDate: localItem.startDate,
          endDate: localItem.endDate,
        ),
      );

      // 📌 Schedule notification for this item
      await ScheduleNotificationManager.scheduleItem(localItem);

      // Attempt server sync if online
      final hasInternet = await ConnectivityHelper.connectivityService.hasInternet();
      if (hasInternet) {
        try {
          final syncedItem = await HiveService.syncSingleItem(localItem);
          await HiveService.addOrUpdateItem(syncedItem); // update Hive with serverId and synced status
        } catch (e) {
          print('Sync failed: $e');
        }
      }

      if (mounted) Navigator.pop(context);

    } catch (e) {
      _shakeDialog();
      showErrorSnack(context, "Failed to save. Try again.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final accent = _getAccent();

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: FocusScope(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F2C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (_type == 'Classes')
                              ClassSection(
                                titleController: _titleController,
                                roomController: _roomController,
                                detailsController: _detailsController,
                                selectedDay: _selectedDay,
                                startTime: _startTime,
                                endTime: _endTime,
                                onDayChanged: (v) =>
                                    setState(() => _selectedDay = v),
                                pickStartTime: () => _pickTime(true),
                                pickEndTime: () => _pickTime(false),
                                accentColor: accent,
                                titleValidator: (v) =>
                                    v == null || v.trim().isEmpty
                                    ? 'Title is required'
                                    : null,
                              ),

                            if (_type == 'Quizzes')
                              QuizSection(
                                titleController: _titleController,
                                detailsController: _detailsController,
                                date: _startDate,
                                time: _startTime,
                                pickDate: () => _pickDate(true),
                                pickTime: () => _pickTime(true),
                                accentColor: accent,
                                titleValidator: (v) =>
                                    v == null || v.trim().isEmpty
                                    ? 'Title is required'
                                    : null,
                              ),

                            if (_type == 'Assignments')
                              AssignmentSection(
                                titleController: _titleController,
                                detailsController: _detailsController,
                                date: _startDate,
                                time: _startTime,
                                pickDate: () => _pickDate(true),
                                pickTime: () => _pickTime(true),
                                accentColor: accent,
                                titleValidator: (v) =>
                                    v == null || v.trim().isEmpty
                                    ? 'Title is required'
                                    : null,
                              ),

                            if (_type == 'Others')
                              OthersSection(
                                titleController: _titleController,
                                detailsController: _detailsController,
                                startDate: _startDate,
                                startTime: _startTime,
                                endDate: _endDate,
                                endTime: _endTime,
                                pickStartDate: () => _pickDate(true),
                                pickEndDate: () => _pickDate(false),
                                pickStartTime: () => _pickTime(true),
                                pickEndTime: () => _pickTime(false),
                                accentColor: accent,
                                titleValidator: (v) =>
                                    v == null || v.trim().isEmpty
                                    ? 'Title is required'
                                    : null,
                              ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white70,
                                    ),
                                    label: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: accent),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.save,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      isEdit ? 'Save Changes' : 'Save',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed: _isSubmitting ? null : _save,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: -20,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: TopPatternClipper(),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isEdit ? 'Edit $_type' : 'Add $_type',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
