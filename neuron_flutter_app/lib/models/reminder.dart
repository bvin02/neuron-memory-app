class Reminder {
  final String id;
  final String text;
  final DateTime dateTime;
  final bool isCompleted;
  final String? group;
  final String time; // Format: "hh:mm t" where t is 'a' or 'p'

  Reminder({
    required this.id,
    required this.text,
    required this.dateTime,
    this.isCompleted = false,
    this.group,
    this.time = "11:59p", // Default time
  });

  Reminder copyWith({
    String? id,
    String? text,
    DateTime? dateTime,
    bool? isCompleted,
    String? group,
    String? time,
  }) {
    return Reminder(
      id: id ?? this.id,
      text: text ?? this.text,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      group: group ?? this.group,
      time: time ?? this.time,
    );
  }
} 