import 'package:flutter/material.dart';
import 'dart:ui';

class CalendarEvent {
  final String id;
  String title;
  String description;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Color color;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.color = const Color(0xFF978BF3),
  });
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isEdgeSwipe = false;
  double _startX = 0;
  final List<CalendarEvent> _events = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addEvent() {
    if (_titleController.text.trim().isEmpty) return;

    setState(() {
      _events.add(
        CalendarEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          startTime: _startTime,
          endTime: _endTime,
        ),
      );
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  void _deleteEvent(CalendarEvent event) {
    setState(() {
      _events.remove(event);
    });
  }

  void _editEvent(CalendarEvent event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _startTime = event.startTime;
    _endTime = event.endTime;

    showDialog(
      context: context,
      builder: (context) => _EventDialog(
        titleController: _titleController,
        descriptionController: _descriptionController,
        startTime: _startTime,
        endTime: _endTime,
        onStartTimeChanged: (time) => _startTime = time,
        onEndTimeChanged: (time) => _endTime = time,
        onSave: () {
          setState(() {
            event.title = _titleController.text;
            event.description = _descriptionController.text;
            event.startTime = _startTime;
            event.endTime = _endTime;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][now.weekday - 1];
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month - 1];

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
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (details) {
                  _startX = details.globalPosition.dx;
                  if (details.globalPosition.dx > MediaQuery.of(context).size.width - 50) {
                    _isEdgeSwipe = true;
                  } else {
                    _isEdgeSwipe = false;
                  }
                },
                onHorizontalDragEnd: (details) {
                  final endX = details.globalPosition.dx;
                  final distance = _startX - endX;
                  
                  if (_isEdgeSwipe && distance > 100) { // Swipe left from right edge - Exit to Home
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
                            '$dayOfWeek, $month ${now.day}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white70),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => _EventDialog(
                                  titleController: _titleController,
                                  descriptionController: _descriptionController,
                                  startTime: _startTime,
                                  endTime: _endTime,
                                  onStartTimeChanged: (time) => _startTime = time,
                                  onEndTimeChanged: (time) => _endTime = time,
                                  onSave: _addEvent,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _DayView(events: _events, onEventTap: _editEvent, onEventDelete: _deleteEvent),
                    ),
                  ],
                ),
              ),
              // Add a transparent gesture detector on the right edge
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 50,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (details) {
                    _startX = details.globalPosition.dx;
                    _isEdgeSwipe = true;
                  },
                  onHorizontalDragEnd: (details) {
                    final endX = details.globalPosition.dx;
                    final distance = _startX - endX;
                    
                    if (_isEdgeSwipe && distance > 100) { // Swipe left from right edge - Exit to Home
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  final List<CalendarEvent> events;
  final Function(CalendarEvent) onEventTap;
  final Function(CalendarEvent) onEventDelete;

  const _DayView({
    required this.events,
    required this.onEventTap,
    required this.onEventDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
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
                  tileMode: TileMode.clamp,
                ),
              ),
              child: _TimeGrid(events: events, onEventTap: onEventTap, onEventDelete: onEventDelete),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeGrid extends StatelessWidget {
  final List<CalendarEvent> events;
  final Function(CalendarEvent) onEventTap;
  final Function(CalendarEvent) onEventDelete;

  const _TimeGrid({
    required this.events,
    required this.onEventTap,
    required this.onEventDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Time labels
        Column(
          children: List.generate(24, (hour) {
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${hour % 12 == 0 ? 12 : hour % 12} ${hour < 12 ? 'a' : 'p'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        // Events
        ...events.map((event) {
          final startHour = event.startTime.hour;
          final startMinute = event.startTime.minute;
          final endHour = event.endTime.hour;
          final endMinute = event.endTime.minute;
          
          final startPosition = startHour + (startMinute / 60);
          final endPosition = endHour + (endMinute / 60);
          final duration = endPosition - startPosition;

          return Positioned(
            top: (startPosition / 24) * MediaQuery.of(context).size.height,
            height: (duration / 24) * MediaQuery.of(context).size.height,
            left: 50,
            right: 8,
            child: GestureDetector(
              onTap: () => onEventTap(event),
              child: Dismissible(
                key: Key(event.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => onEventDelete(event),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: event.color.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event.description.isNotEmpty)
                        Text(
                          event.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _EventDialog extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(TimeOfDay) onEndTimeChanged;
  final VoidCallback onSave;

  const _EventDialog({
    required this.titleController,
    required this.descriptionController,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(24),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Event Title',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Description (optional)',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (time != null) onStartTimeChanged(time);
                          },
                          child: Text(
                            'Start: ${startTime.format(context)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (time != null) onEndTimeChanged(time);
                          },
                          child: Text(
                            'End: ${endTime.format(context)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF978BF3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
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
