import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NoteModel {
  static const String _storageKey = 'notes';
  static const String _groupsKey = 'note_groups';

  List<Note> notes = [];
  Map<String, NoteGroup> customGroups = {};

  // Singleton pattern
  static final NoteModel _instance = NoteModel._internal();
  factory NoteModel() => _instance;
  NoteModel._internal();

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load notes
    final notesJson = prefs.getStringList(_storageKey) ?? [];
    
    if (notesJson.isEmpty) {
      // Add sample notes if no notes exist
      notes = [
        Note(
          id: '1',
          title: 'Meeting Summary',
          content: 'Team meeting discussion points...',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          modifiedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Note(
          id: '2',
          title: 'Project Ideas',
          content: 'New project brainstorming...',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          modifiedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Note(
          id: '3',
          title: 'Interview Notes',
          content: 'Candidate evaluation...',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
      ];
      await saveNotes(); // Save the sample notes
    } else {
      notes = notesJson.map((json) => Note.fromJson(jsonDecode(json))).toList();
    }
    
    // Load custom groups
    final groupsJson = prefs.getStringList(_groupsKey) ?? [];
    customGroups = {
      for (final json in groupsJson)
        (jsonDecode(json) as Map<String, dynamic>)['id'] as String:
        NoteGroup.fromJson(jsonDecode(json))
    };
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save notes
    final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList(_storageKey, notesJson);
    
    // Save custom groups
    final groupsJson = customGroups.values
        .map((group) => jsonEncode(group.toJson()))
        .toList();
    await prefs.setStringList(_groupsKey, groupsJson);
  }

  void addNote(Note note) {
    notes.add(note);
    saveNotes();
  }

  void updateNote(Note note) {
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      saveNotes();
    }
  }

  void deleteNote(String noteId) {
    notes.removeWhere((note) => note.id == noteId);
    saveNotes();
  }

  void createCustomGroup(String groupId, String header, List<Note> groupNotes) {
    customGroups[groupId] = NoteGroup(
      header: header,
      notes: groupNotes,
      isCustom: true,
    );
    for (final note in groupNotes) {
      note.customGroupId = groupId;
    }
    saveNotes();
  }

  void updateCustomGroup(String groupId, String newHeader) {
    if (customGroups.containsKey(groupId)) {
      customGroups[groupId]!.header = newHeader;
      saveNotes();
    }
  }

  void deleteCustomGroup(String groupId) {
    if (customGroups.containsKey(groupId)) {
      for (final note in customGroups[groupId]!.notes) {
        note.customGroupId = null;
      }
      customGroups.remove(groupId);
      saveNotes();
    }
  }
}

class Note {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime modifiedAt;
  String? customGroupId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    this.customGroupId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'customGroupId': customGroupId,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    customGroupId: json['customGroupId'] as String?,
  );
}

class NoteGroup {
  String header;
  List<Note> notes;
  bool isCustom;

  NoteGroup({
    required this.header,
    required this.notes,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'header': header,
    'notes': notes.map((note) => note.id).toList(),
    'isCustom': isCustom,
  };

  factory NoteGroup.fromJson(Map<String, dynamic> json) => NoteGroup(
    header: json['header'] as String,
    notes: [], // Notes will be populated after loading
    isCustom: json['isCustom'] as bool? ?? false,
  );
} 