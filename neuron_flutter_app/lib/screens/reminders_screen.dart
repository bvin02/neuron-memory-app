import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/reminder.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/db.dart';

class RemindersScreen extends StatefulWidget {
  final List<Reminder> reminders;
  final Function(List<Reminder>) onRemindersUpdated;

  const RemindersScreen({
    super.key,
    required this.reminders,
    required this.onRemindersUpdated,
  });

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late List<Reminder> _reminders;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _editingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _editingFocusNode = FocusNode();
  int? _editingReminderId;
  String? _originalDate;
  double _startX = 0.0;
  bool _isEdgeSwipe = false;

  @override
  void initState() {
    super.initState();
    _reminders = List.from(widget.reminders);
    _sortReminders(); // Sort reminders on initial load
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    _editingController.dispose();
    _editingFocusNode.dispose();
    super.dispose();
  }

  void _addReminder() async {
    if (_titleController.text.trim().isEmpty) return;

    print('Creating new reminder with title: ${_titleController.text}');
    final now = DateTime.now();
    // Set due date to today at 23:59
    final dueDateTime = DateTime(now.year, now.month, now.day, 23, 59);
    
    final reminder = Reminder.create(
      title: _titleController.text,
      dueDate: dueDateTime,
      dueTime: dueDateTime,
    );
    
    final savedId = await NeuronDatabase.saveReminder(reminder);
    print('Saved new reminder to database with id: $savedId');
    _titleController.clear();
    
    final updatedReminders = await NeuronDatabase.getAllReminders();
    print('Retrieved ${updatedReminders.length} reminders from database');
    setState(() {
      _reminders.clear();
      _reminders.addAll(updatedReminders);
      _sortReminders(); // Ensure reminders are sorted after loading from database
      print('Updated local list with ${_reminders.length} reminders');
    });
    widget.onRemindersUpdated(_reminders);
    print('Notified parent of reminders update');
  }

  void _toggleReminder(Reminder reminder) async {
    print('Toggling reminder with id: ${reminder.id}, title: ${reminder.title}');
    final updatedReminder = reminder.copyWith(
      isCompleted: !reminder.isCompleted,
    );
    print('Created updated reminder with isCompleted: ${updatedReminder.isCompleted}');
    await NeuronDatabase.saveReminder(updatedReminder);
    print('Saved updated reminder to database');
    
    setState(() {
      // Remove the reminder from its current position
      _reminders.removeWhere((r) => r.id == reminder.id);
      
      // Separate the reminders into completed and not completed
      final notCompletedReminders = _reminders.where((r) => !r.isCompleted).toList();
      final completedReminders = _reminders.where((r) => r.isCompleted).toList();
      
      // Add the updated reminder to the appropriate list
      if (updatedReminder.isCompleted) {
        completedReminders.add(updatedReminder); // Add to completed list
      } else {
        notCompletedReminders.add(updatedReminder); // Add to not completed list
      }
      
      // Rebuild the reminders list with not completed items first, then completed items
      _reminders = [...notCompletedReminders, ...completedReminders];
    });
    
    // Update all reminders in database to persist the new order
    for (final r in _reminders) {
      await NeuronDatabase.saveReminder(r);
    }
    
    widget.onRemindersUpdated(_reminders);
    print('Notified parent of reminders update');
  }

  void _deleteReminder(Reminder reminder) async {
    await NeuronDatabase.deleteReminder(reminder.id);
    setState(() {
      _reminders.remove(reminder);
    });
    widget.onRemindersUpdated(_reminders);
  }

  Future<void> _selectDate(Reminder reminder) async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const RadialGradient(
                center: Alignment(1.0, 1.0),
                radius: 2,
                colors: [
                  Color(0xFF0F0F17),
                  Color.fromARGB(255, 30, 30, 46),
                  Color.fromARGB(255, 35, 36, 58),
                ],
                stops: [0.1, 0.6, 0.9],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    center: Alignment(1.0, -1.0),
                    radius: 1.8,
                    colors: [
                      Color.fromARGB(255, 99, 99, 143),
                      Color.fromARGB(255, 65, 65, 77),
                    ],
                    stops: [0.1, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  constraints: const BoxConstraints(
                    maxHeight: 460,
                    maxWidth: 350,
                    minHeight: 400,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.5),
                    gradient: const RadialGradient(
                      center: Alignment(1.0, 1.0),
                      radius: 2,
                      colors: [
                        Color(0xFF0F0F17),
                        Color.fromARGB(255, 30, 30, 46),
                        Color.fromARGB(255, 35, 36, 58),
                      ],
                      stops: [0.1, 0.6, 0.9],
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: Colors.transparent,
                        hourMinuteShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white24, width: 1),
                        ),
                        dayPeriodShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white24, width: 1),
                        ),
                        dayPeriodColor: Colors.transparent,
                        dayPeriodTextColor: Colors.white70,
                        dayPeriodBorderSide: const BorderSide(color: Colors.white24),
                        hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                          states.contains(MaterialState.selected)
                              ? Colors.white24
                              : Colors.transparent),
                        hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                          states.contains(MaterialState.selected)
                              ? Colors.white
                              : Colors.white70),
                        dialHandColor: Colors.white70,
                        dialBackgroundColor: Colors.white10,
                        dialTextColor: MaterialStateColor.resolveWith((states) =>
                          states.contains(MaterialState.selected)
                              ? Colors.black
                              : Colors.white70),
                        entryModeIconColor: Colors.transparent,
                        helpTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                      ),
                      iconTheme: const IconThemeData(
                        color: Colors.transparent,
                        opacity: 0,
                        size: 0,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: reminder.dueDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onDateChanged: (date) {
                        Navigator.of(context).pop(date);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        reminder.dueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          reminder.dueTime?.hour ?? reminder.dueDate.hour,
          reminder.dueTime?.minute ?? reminder.dueDate.minute,
        );
        widget.onRemindersUpdated(_reminders);
      });
    }
  }

  Future<void> _selectTime(Reminder reminder) async {
    // Get current time values
    final initialTime = TimeOfDay(
      hour: reminder.dueTime?.hour ?? 23,
      minute: reminder.dueTime?.minute ?? 59,
    );
    
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const RadialGradient(
                center: Alignment(1.0, 1.0),
                radius: 2,
                colors: [
                  Color(0xFF0F0F17),
                  Color.fromARGB(255, 30, 30, 46),
                  Color.fromARGB(255, 35, 36, 58),
                ],
                stops: [0.1, 0.6, 0.9],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    center: Alignment(1.0, -1.0),
                    radius: 1.8,
                    colors: [
                      Color.fromARGB(255, 99, 99, 143),
                      Color.fromARGB(255, 65, 65, 77),
                    ],
                    stops: [0.1, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  constraints: const BoxConstraints(
                    maxHeight: 460,
                    maxWidth: 400,
                    minHeight: 400,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.5),
                    gradient: const RadialGradient(
                      center: Alignment(1.0, 1.0),
                      radius: 2,
                      colors: [
                        Color(0xFF0F0F17),
                        Color.fromARGB(255, 30, 30, 46),
                        Color.fromARGB(255, 35, 36, 58),
                      ],
                      stops: [0.1, 0.6, 0.9],
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: Colors.transparent,
                        hourMinuteShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white24, width: 1),
                        ),
                        dayPeriodShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white24, width: 1),
                        ),
                        dayPeriodColor: Colors.transparent,
                        dayPeriodTextColor: Colors.white70,
                        dayPeriodBorderSide: const BorderSide(color: Colors.white24),
                        hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                          states.contains(MaterialState.selected)
                              ? Colors.white24
                              : Colors.transparent),
                        hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                          states.contains(MaterialState.selected)
                              ? Colors.white
                              : Colors.white70),
                        dialHandColor: Colors.white70,
                        dialBackgroundColor: Colors.white10,
                        dialTextColor: MaterialStateColor.resolveWith((states) =>
                          states.contains(MaterialState.selected)
                              ? Colors.black
                              : Colors.white70),
                        entryModeIconColor: Colors.transparent,
                        helpTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                      ),
                      iconTheme: const IconThemeData(
                        color: Colors.transparent,
                        opacity: 0,
                        size: 0,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                      ),
                    ),
                    child: TimePickerDialog(
                      initialTime: initialTime,
                      initialEntryMode: TimePickerEntryMode.dial,
                      cancelText: 'Cancel',
                      confirmText: 'OK',
                      helpText: '',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        reminder.dueTime = DateTime(
          reminder.dueDate.year,
          reminder.dueDate.month,
          reminder.dueDate.day,
          picked.hour,
          picked.minute,
        );
        widget.onRemindersUpdated(_reminders);
      });
    }
  }

  // Helper method to convert DateTime to 12-hour display format
  String _formatTimeForDisplay(DateTime? dateTime) {
    if (dateTime == null) return '11:59p';
    
    final TimeOfDay timeOfDay = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    final String period = timeOfDay.hour >= 12 ? 'p' : 'a';
    final int hour = timeOfDay.hour > 12 ? timeOfDay.hour - 12 : (timeOfDay.hour == 0 ? 12 : timeOfDay.hour);
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute$period';
  }

  void _startEditing(Reminder reminder) {
    setState(() {
      _editingReminderId = reminder.id;
      _editingController.text = reminder.title ?? '';
    });
    _editingFocusNode.requestFocus();
  }

  void _saveEdit(Reminder reminder) async {
    if (_editingController.text.trim().isEmpty) {
      _cancelEdit();
      return;
    }
    
    final updatedReminder = reminder.copyWith(
      title: _editingController.text.trim(),
    );
    await NeuronDatabase.saveReminder(updatedReminder);
    
    setState(() {
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = updatedReminder;
      }
      _editingReminderId = null;
    });
    widget.onRemindersUpdated(_reminders);
  }

  void _cancelEdit() {
    setState(() {
      _editingReminderId = null;
      _editingController.clear();
    });
  }

  // Helper method to sort reminders with completed ones at the bottom
  void _sortReminders() {
    final notCompletedReminders = _reminders.where((r) => !r.isCompleted).toList();
    final completedReminders = _reminders.where((r) => r.isCompleted).toList();
    _reminders = [...notCompletedReminders, ...completedReminders];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF080810),
            Color(0xFF16161F),
            Color(0xFF1F1F2D),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              _startX = details.globalPosition.dx;
              if (details.globalPosition.dx < 50) {
                _isEdgeSwipe = true;
              } else {
                _isEdgeSwipe = false;
              }
            },
            onHorizontalDragEnd: (details) {
              final endX = details.globalPosition.dx;
              final distance = _startX - endX;
              
              if (_isEdgeSwipe && distance < -100) { // Swipe right from left edge - Exit to Home
                Navigator.of(context).pop();
              }
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reminders',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white70),
                        onPressed: () {
                          if (_titleController.text.trim().isNotEmpty) {
                            _addReminder();
                          } else {
                            _focusNode.requestFocus();
                            // Ensure keyboard is shown
                            Future.delayed(const Duration(milliseconds: 50), () {
                              if (mounted) {
                                FocusScope.of(context).requestFocus(_focusNode);
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.transparent,
                            primaryColor: Colors.white70,
                          ),
                          child: ReorderableListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: _reminders.length,
                            buildDefaultDragHandles: true,
                            onReorderStart: (index) {
                              HapticFeedback.mediumImpact();
                            },
                            proxyDecorator: (child, index, animation) {
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (BuildContext context, Widget? child) {
                                  final double animValue = Curves.easeInOut.transform(animation.value);
                                  final double elevation = lerpDouble(0, 6, animValue)!;
                                  return Material(
                                    elevation: elevation,
                                    color: const Color(0xFF1F1F2D),
                                    shadowColor: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    child: child,
                                  );
                                },
                                child: child,
                              );
                            },
                            onReorder: (oldIndex, newIndex) async {
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final reminder = _reminders.removeAt(oldIndex);
                                _reminders.insert(newIndex, reminder);
                              });
                              
                              // Update all reminders in database to persist the new order
                              for (final reminder in _reminders) {
                                await NeuronDatabase.saveReminder(reminder);
                              }
                              
                              widget.onRemindersUpdated(_reminders);
                            },
                            itemBuilder: (context, index) {
                              final reminder = _reminders[index];
                              return Dismissible(
                                key: Key(reminder.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red.withAlpha(50),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24.0),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white70,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  _deleteReminder(reminder);
                                },
                                child: Container(
                                  key: Key(reminder.id.toString()),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Transform.scale(
                                      scale: 0.8,
                                      child: Checkbox(
                                        value: reminder.isCompleted,
                                        onChanged: (bool? value) {
                                          _toggleReminder(reminder);
                                        },
                                        shape: const CircleBorder(),
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 1.5,
                                        ),
                                        checkColor: Colors.white,
                                        fillColor: MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.selected)) {
                                              return Colors.white.withOpacity(0.2);
                                            }
                                            return Colors.transparent;
                                          },
                                        ),
                                      ),
                                    ),
                                    title: _editingReminderId == reminder.id
                                      ? KeyboardListener(
                                          focusNode: FocusNode(),
                                          onKeyEvent: (event) {
                                            if (event.logicalKey == LogicalKeyboardKey.escape) {
                                              _cancelEdit();
                                            }
                                          },
                                          child: TextField(
                                            controller: _editingController,
                                            focusNode: _editingFocusNode,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: reminder.title ?? 'Untitled Reminder',
                                              hintStyle: const TextStyle(color: Colors.white54),
                                            ),
                                            onSubmitted: (_) => _saveEdit(reminder),
                                            onEditingComplete: () => _saveEdit(reminder),
                                            onTapOutside: (_) => _cancelEdit(),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () => _startEditing(reminder),
                                          child: Text(
                                            reminder.title ?? 'Untitled Reminder',
                                            style: TextStyle(
                                              color: reminder.isCompleted ? Colors.white54 : Colors.white,
                                              fontStyle: reminder.isCompleted ? FontStyle.italic : FontStyle.normal,
                                            ),
                                          ),
                                        ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!reminder.isCompleted) ...[
                                          GestureDetector(
                                            onTap: () => _selectDate(reminder),
                                            child: Text(
                                              '${reminder.dueDate.day}/${reminder.dueDate.month}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: GestureDetector(
                                              onTap: () => _selectTime(reminder),
                                              child: Text(
                                                _formatTimeForDisplay(reminder.dueTime),
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Icon(
                                          Icons.drag_handle,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        key: const Key('new_reminder'),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: TextField(
                          controller: _titleController,
                          focusNode: _focusNode,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Add a new reminder...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _addReminder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
