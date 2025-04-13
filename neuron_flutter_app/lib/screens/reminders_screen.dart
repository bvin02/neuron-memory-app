import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/reminder.dart';
import 'dart:math';

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
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _dateController = TextEditingController();
  final FocusNode _dateFocusNode = FocusNode();
  String? _editingReminderId;
  String? _originalDate;
  double _startX = 0.0;
  bool _isEdgeSwipe = false;

  @override
  void initState() {
    super.initState();
    _reminders = List.from(widget.reminders);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _dateController.dispose();
    _dateFocusNode.dispose();
    super.dispose();
  }

  void _addReminder() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _reminders.add(
        Reminder(
          id: Random().nextInt(1000000).toString(),
          text: _textController.text,
          dateTime: DateTime.now(),
          time: '23:59', // Store in 24-hour format
        ),
      );
      _textController.clear();
      widget.onRemindersUpdated(_reminders);
    });
  }

  void _toggleReminder(Reminder reminder) {
    setState(() {
      final index = _reminders.indexOf(reminder);
      _reminders[index] = reminder.copyWith(isCompleted: !reminder.isCompleted);
      widget.onRemindersUpdated(_reminders);
    });
  }

  void _deleteReminder(Reminder reminder) {
    setState(() {
      _reminders.remove(reminder);
      widget.onRemindersUpdated(_reminders);
    });
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
                  padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  constraints: const BoxConstraints(
                    maxHeight: 500,
                    maxWidth: 350,
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
                  child: CalendarDatePicker(
                    initialDate: reminder.dateTime,
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
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        final index = _reminders.indexOf(reminder);
        _reminders[index] = reminder.copyWith(
          dateTime: DateTime(
            picked.year,
            picked.month,
            picked.day,
            reminder.dateTime.hour,
            reminder.dateTime.minute,
          ),
        );
        widget.onRemindersUpdated(_reminders);
      });
    }
  }

  Future<void> _selectTime(Reminder reminder) async {
    // Parse the current time from 24-hour format
    final currentTime = reminder.time.split(':');
    final hour = int.parse(currentTime[0]);
    final minute = int.parse(currentTime[1].split(' ')[0]);
    
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
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
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    maxHeight: 500,
                    maxWidth: 380,
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
                      colorScheme: ColorScheme.dark(
                        primary: const Color.fromARGB(255, 27, 27, 39),
                        onPrimary: const Color.fromARGB(255, 151, 139, 243),
                        surface: const Color.fromARGB(255, 27, 27, 39),
                        onSurface: Colors.white,
                      ),
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                        dayPeriodTextColor: const Color.fromARGB(255, 41, 40, 55),
                        dayPeriodColor: const Color.fromARGB(223, 99, 99, 143),
                        hourMinuteColor: const Color(0xFF32324b),
                        hourMinuteShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        dayPeriodShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide.none,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        dialHandColor: Colors.white70,
                        dialBackgroundColor: Colors.transparent,
                        dialTextColor: Colors.white,
                        hourMinuteTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.2,
                          leadingDistribution: TextLeadingDistribution.even,
                          textBaseline: TextBaseline.ideographic,
                        ),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 187, 178, 255),
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: 380,
                      height: 500,
                      child: TimePickerDialog(
                        initialTime: TimeOfDay(hour: hour, minute: minute),
                        initialEntryMode: TimePickerEntryMode.dialOnly,
                        helpText: '',
                        cancelText: 'Cancel',
                        confirmText: 'OK',
                      ),
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
        final index = _reminders.indexOf(reminder);
        // Store in 24-hour format
        _reminders[index] = reminder.copyWith(
          time: '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
        );
        widget.onRemindersUpdated(_reminders);
      });
    }
  }

  // Helper method to convert 24-hour format to 12-hour display format
  String _formatTimeForDisplay(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'p' : 'a';
    final hour12 = hour % 12;
    return '${hour12 == 0 ? 12 : hour12}:$minute $period';
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
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white70),
                        onPressed: () {
                          if (_textController.text.trim().isNotEmpty) {
                            _addReminder();
                          } else {
                            _focusNode.requestFocus();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: _reminders.length + 1,
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex < _reminders.length && newIndex < _reminders.length) {
                        setState(() {
                          final item = _reminders.removeAt(oldIndex);
                          _reminders.insert(newIndex, item);
                        });
                      }
                    },
                    itemBuilder: (context, index) {
                      if (index == _reminders.length) {
                        return Padding(
                          key: const Key('new_reminder'),
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Add a new reminder...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _addReminder(),
                          ),
                        );
                      }

                      final reminder = _reminders[index];
                      return Dismissible(
                        key: Key(reminder.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteReminder(reminder),
                        child: ListTile(
                          leading: Checkbox(
                            value: reminder.isCompleted,
                            onChanged: (_) => _toggleReminder(reminder),
                            activeColor: Colors.white70,
                            checkColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(
                              color: Colors.white70,
                              width: 1.5,
                            ),
                          ),
                          title: Text(
                            reminder.text,
                            style: TextStyle(
                              color: reminder.isCompleted ? Colors.white54 : Colors.white,
                              fontStyle: reminder.isCompleted ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                          trailing: reminder.isCompleted 
                              ? null 
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _selectDate(reminder),
                                      child: Text(
                                        '${reminder.dateTime.day}/${reminder.dateTime.month}',
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
                                          _formatTimeForDisplay(reminder.time),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
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
