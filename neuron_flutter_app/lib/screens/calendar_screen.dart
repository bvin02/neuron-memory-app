import 'package:flutter/material.dart';
import 'dart:ui';
import 'graph_view.dart';

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
              BottomSwipeDetector(
                onSwipeUp: () {
                  Navigator.of(context).push(
                    BottomSlideRoute(
                      page: const GraphViewScreen(),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 28),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$dayOfWeek, $month ${now.day}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
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
                                  onSave: () {
                                    _addEvent();
                                    Navigator.pop(context);
                                  },
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

  // Helper method to group overlapping events
  List<List<CalendarEvent>> _groupOverlappingEvents() {
    if (events.isEmpty) return [];

    // Sort events by start time
    final sortedEvents = List<CalendarEvent>.from(events)
      ..sort((a, b) {
        final aStartMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bStartMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aStartMinutes.compareTo(bStartMinutes);
      });

    List<List<CalendarEvent>> groups = [];

    for (var event in sortedEvents) {
      final eventStartMinutes = event.startTime.hour * 60 + event.startTime.minute;
      final eventEndMinutes = event.endTime.hour * 60 + event.endTime.minute;
      
      // Try to find an existing group where this event doesn't overlap with any event
      bool addedToGroup = false;
      
      for (var group in groups) {
        bool hasOverlap = false;
        
        for (var groupEvent in group) {
          final groupEventStartMinutes = groupEvent.startTime.hour * 60 + groupEvent.startTime.minute;
          final groupEventEndMinutes = groupEvent.endTime.hour * 60 + groupEvent.endTime.minute;
          
          // Check if events overlap in time
          if (!(eventStartMinutes >= groupEventEndMinutes || eventEndMinutes <= groupEventStartMinutes)) {
            hasOverlap = true;
            break;
          }
        }
        
        // If no overlap with any event in this group, add to group
        if (!hasOverlap) {
          group.add(event);
          addedToGroup = true;
          break;
        }
      }
      
      // If not added to any existing group, create a new group
      if (!addedToGroup) {
        groups.add([event]);
      }
    }
    
    return groups;
  }
  
  // Create column groups for overlapping events
  List<List<CalendarEvent>> _createOverlapColumns(List<CalendarEvent> events) {
    if (events.isEmpty) return [];
    
    List<List<CalendarEvent>> columns = [[]];
    
    for (var event in events) {
      bool placed = false;
      
      // Try to place in existing column
      for (var column in columns) {
        bool canPlace = true;
        
        for (var columnEvent in column) {
          final eventStart = event.startTime.hour * 60 + event.startTime.minute;
          final eventEnd = event.endTime.hour * 60 + event.endTime.minute;
          final columnEventStart = columnEvent.startTime.hour * 60 + columnEvent.startTime.minute;
          final columnEventEnd = columnEvent.endTime.hour * 60 + columnEvent.endTime.minute;
          
          // Check for time overlap
          if (!(eventStart >= columnEventEnd || eventEnd <= columnEventStart)) {
            canPlace = false;
          break;
        }
      }
      
        if (canPlace) {
          column.add(event);
          placed = true;
          break;
        }
      }
      
      // Create new column if couldn't place in existing ones
      if (!placed) {
        columns.add([event]);
      }
    }
    
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hourHeight = constraints.maxHeight / 24;
        final leftPadding = 50.0; // Time labels width
        final rightPadding = 10.0; // New right padding
        final fullWidth = constraints.maxWidth - leftPadding - rightPadding; // Account for time labels and right padding
        
        // Group events that don't overlap in time
        final eventGroups = _groupOverlappingEvents();
        
        return Stack(
          children: [
            // Time labels and hour lines
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
                    child: Row(
                      children: [
                        // Time label
                        SizedBox(
                          width: leftPadding,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '${hour % 12 == 0 ? 12 : hour % 12} ${hour < 12 ? 'a' : 'p'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        // Empty space for events
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                );
              }),
            ),
            
            // Render all events with proper overlapping
            ...eventGroups.expand((group) {
              if (group.length == 1) {
                // For single events in a group (no overlaps), use full width
                final event = group[0];
                final startHour = event.startTime.hour;
                final startMinute = event.startTime.minute;
                final endHour = event.endTime.hour;
                final endMinute = event.endTime.minute;
                
                final startPosition = startHour + (startMinute / 60);
                final endPosition = endHour + (endMinute / 60);
                final duration = endPosition - startPosition;

                return [
                  Positioned(
                    top: startPosition * hourHeight,
                    height: duration * hourHeight,
                    left: leftPadding, // Start after time labels
                    width: fullWidth, // Take full width minus padding
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
                          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
                  )
                ];
              } else {
                // Multiple events in a group - these might overlap
                // Find truly overlapping events by time
                final overlapGroups = <List<CalendarEvent>>[];
                for (var event in group) {
                  bool addedToGroup = false;
                  
                  for (var overlapGroup in overlapGroups) {
                    bool overlapsWithAny = false;
                    
                    for (var groupEvent in overlapGroup) {
                      final eventStart = event.startTime.hour * 60 + event.startTime.minute;
                      final eventEnd = event.endTime.hour * 60 + event.endTime.minute;
                      final groupEventStart = groupEvent.startTime.hour * 60 + groupEvent.startTime.minute;
                      final groupEventEnd = groupEvent.endTime.hour * 60 + groupEvent.endTime.minute;
                      
                      // Check for time overlap
                      if (!(eventStart >= groupEventEnd || eventEnd <= groupEventStart)) {
                        overlapsWithAny = true;
                        break;
                      }
                    }
                    
                    if (overlapsWithAny) {
                      overlapGroup.add(event);
                      addedToGroup = true;
                      break;
                    }
                  }
                  
                  if (!addedToGroup) {
                    overlapGroups.add([event]);
                  }
                }
                
                // Render each overlap group
                List<Widget> allPositionedEvents = [];
                
                for (var overlapGroup in overlapGroups) {
                  if (overlapGroup.length == 1) {
                    // Single event in this overlap group - full width
                    final event = overlapGroup[0];
                    final startHour = event.startTime.hour;
                    final startMinute = event.startTime.minute;
                    final endHour = event.endTime.hour;
                    final endMinute = event.endTime.minute;
                    
                    final startPosition = startHour + (startMinute / 60);
                    final endPosition = endHour + (endMinute / 60);
                    final duration = endPosition - startPosition;
                    
                    allPositionedEvents.add(
                      Positioned(
                        top: startPosition * hourHeight,
                        height: duration * hourHeight,
                        left: leftPadding,
                        width: fullWidth,
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
                              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          event.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
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
                      )
                    );
                  } else {
                    // Multiple events - divide width
                    final eventWidth = fullWidth / overlapGroup.length;
                    
                    for (int i = 0; i < overlapGroup.length; i++) {
                      final event = overlapGroup[i];
                      final startHour = event.startTime.hour;
                      final startMinute = event.startTime.minute;
                      final endHour = event.endTime.hour;
                      final endMinute = event.endTime.minute;
                      
                      final startPosition = startHour + (startMinute / 60);
                      final endPosition = endHour + (endMinute / 60);
                      final duration = endPosition - startPosition;
                      
                      allPositionedEvents.add(
                        Positioned(
                          top: startPosition * hourHeight,
                          height: duration * hourHeight,
                          left: leftPadding + (i * eventWidth),
                          width: eventWidth - 4, // 4px gap between events
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
                                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${_formatTime(event.startTime)}-${_formatTime(event.endTime)}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (event.description.isNotEmpty && eventWidth > 100)
                                      Text(
                                        event.description,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      );
                    }
                  }
                }
                
                return allPositionedEvents;
              }
            }).toList(),
          ],
        );
      },
    );
  }
  
  // Format time for display
  String _formatTime(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'am' : 'pm';
    return '$hour:$minute $period';
  }
}

class _EventDialog extends StatefulWidget {
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
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
  }

  bool _isEndTimeValid(TimeOfDay endTime) {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes > startMinutes;
  }

  void _showInvalidTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Invalid Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'End time must be after start time',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Color.fromARGB(255, 187, 178, 255),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<TimeOfDay?> _showStyledTimePicker(BuildContext context, TimeOfDay initialTime) async {
    return showDialog<TimeOfDay>(
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
                        hourMinuteTextColor: Colors.white,
                        hourMinuteShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        dayPeriodShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide.none,
                        ),
                        dayPeriodBorderSide: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        dialHandColor: Colors.white70,
                        dialBackgroundColor: Colors.black12,
                        dialTextColor: Colors.white,
                        entryModeIconColor: Colors.white70,
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
                        initialTime: initialTime,
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
  }

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
                    controller: widget.titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Event Title',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: widget.descriptionController,
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
                            final time = await _showStyledTimePicker(context, _startTime);
                            if (time != null) {
                              if (_endTime != null && !_isEndTimeValid(_endTime)) {
                                // If changing start time makes current end time invalid,
                                // automatically adjust end time to start time + 1 hour
                                final newEndHour = (time.hour + 1) % 24;
                                final newEndTime = TimeOfDay(hour: newEndHour, minute: time.minute);
                                setState(() {
                                  _startTime = time;
                                  _endTime = newEndTime;
                                });
                                widget.onStartTimeChanged(time);
                                widget.onEndTimeChanged(newEndTime);
                              } else {
                                setState(() {
                                  _startTime = time;
                                });
                                widget.onStartTimeChanged(time);
                              }
                            }
                          },
                          child: Text(
                            'Start: ${_startTime.format(context)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final time = await _showStyledTimePicker(context, _endTime);
                            if (time != null) {
                              if (!_isEndTimeValid(time)) {
                                _showInvalidTimeDialog();
                              } else {
                                setState(() {
                                  _endTime = time;
                                });
                                widget.onEndTimeChanged(time);
                              }
                            }
                          },
                          child: Text(
                            'End: ${_endTime.format(context)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.onSave,
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
