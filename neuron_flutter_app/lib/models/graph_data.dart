import 'package:isar/isar.dart';

part 'graph_data.g.dart';

@collection
class GraphData {
  Id id = Isar.autoIncrement;
  
  String? jsonData;
  
  DateTime updatedAt = DateTime.now();
} 