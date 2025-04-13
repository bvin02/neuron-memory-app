import 'package:isar/isar.dart';
import 'note.dart';

part 'event.g.dart';

@collection
class Event {
  Id id = Isar.autoIncrement;
  
  String? title;
  
  String? description;
  
  @Index()
  DateTime date = DateTime.now();
  
  DateTime? startTime;
  
  DateTime? endTime;
  
  final notes = IsarLinks<Note>();
  
  // Helper method to create a new event
  static Event create({
    required String title,
    String? description,
    required DateTime date,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return Event()
      ..title = title
      ..description = description
      ..date = date
      ..startTime = startTime
      ..endTime = endTime;
  }
} 