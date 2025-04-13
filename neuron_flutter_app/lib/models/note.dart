import 'package:isar/isar.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  String? title;
  
  String? content;
  
  String? summary;
  
  @Index(type: IndexType.value, caseSensitive: false)
  List<String> tags = [];
  
  @Index(type: IndexType.value)
  List<double> embedding = [];
  
  @Index()
  DateTime createdAt = DateTime.now();
  
  @Backlink(to: 'backlinks')
  final links = IsarLinks<Note>();
  
  final backlinks = IsarLinks<Note>();
  
  // Helper method to create a new note
  static Note create({
    required String title,
    required String content,
    String? summary,
    List<String> tags = const [],
    List<double> embedding = const [],
  }) {
    return Note()
      ..title = title
      ..content = content
      ..summary = summary
      ..tags = tags
      ..embedding = embedding
      ..createdAt = DateTime.now();
  }
} 