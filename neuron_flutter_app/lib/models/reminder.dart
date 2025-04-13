import 'package:isar/isar.dart';
import 'note.dart';

part 'reminder.g.dart';

@collection
class Reminder {
  Id id = Isar.autoIncrement;
  
  String? title;
  
  String? description;
  
  @Index()
  DateTime dueDate = DateTime.now();
  
  DateTime? dueTime;
  
  @Index()
  bool isCompleted = false;
  
  final notes = IsarLinks<Note>();
  
  // Helper method to create a new reminder
  static Reminder create({
    required String title,
    String? description,
    required DateTime dueDate,
    DateTime? dueTime,
    bool isCompleted = false,
  }) {
    return Reminder()
      ..title = title
      ..description = description
      ..dueDate = dueDate
      ..dueTime = dueTime
      ..isCompleted = isCompleted;
  }

  Reminder copyWith({
    String? title,
    DateTime? dueDate,
    DateTime? dueTime,
    bool? isCompleted,
  }) {
    return Reminder()
      ..id = id
      ..title = title ?? this.title
      ..description = description
      ..dueDate = dueDate ?? this.dueDate
      ..dueTime = dueTime ?? this.dueTime
      ..isCompleted = isCompleted ?? this.isCompleted;
  }
} 