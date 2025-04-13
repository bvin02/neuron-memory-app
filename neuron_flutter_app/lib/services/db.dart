import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import '../models/event.dart';
import '../models/reminder.dart';
import '../models/graph_data.dart';
import 'dart:math';

class NeuronDatabase {
  static late Isar isar;
  
  /// Initialize the database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NoteSchema, EventSchema, ReminderSchema, GraphDataSchema],
      directory: dir.path,
    );

    // Only create sample notes if the database is completely empty
    final existingNotes = await getAllNotes();
    if (existingNotes.isEmpty) {
      await createSampleNotes();
      print('Created initial sample notes');
    }
    
    // Only create sample reminders if there are no reminders
    final existingReminders = await getAllReminders();
    if (existingReminders.isEmpty) {
      await createSampleReminders();
      print('Created initial sample reminders');
    }
  }
  
  // ================ Note Operations ================
  
  /// Clear all notes from the database
  static Future<void> clearAllNotes() async {
    await isar.writeTxn(() async {
      await isar.notes.clear();
    });
  }
  
  /// Create sample notes for testing
  static Future<void> createSampleNotes() async {
    final now = DateTime.now();
    final sampleNotes = [
      Note.create(
        title: "Weekly Planning",
        content: """# Week Overview

## Key Objectives
- [ ] Complete project milestones
- [ ] Team sync meetings
- [ ] Code review sessions

## Focus Areas
1. Performance optimization
2. User interface improvements
3. Documentation updates""",
        tags: ["planning", "weekly"],
        createdAt: now.subtract(const Duration(days: 7, hours: 3)),
      ),
      
      Note.create(
        title: "Neural Networks Research",
        content: """## Deep Learning Concepts

Key areas to explore:
1. Attention mechanisms
2. Transformer architectures
3. Self-supervised learning

### Implementation Notes
- Use PyTorch for prototypes
- Focus on efficiency
- Consider mobile deployment""",
        tags: ["research", "AI", "technical"],
        createdAt: now.subtract(const Duration(days: 6, hours: 5)),
      ),
      
      Note.create(
        title: "Design System Guidelines",
        content: """# UI/UX Guidelines

## Color Palette
- Primary: #1F1F2D
- Secondary: #282837
- Accent: #41414D

## Typography
- Headlines: SF Pro Display
- Body: SF Pro Text
- Code: SF Mono

## Components
1. Buttons
2. Cards
3. Navigation elements""",
        tags: ["design", "UI", "guidelines"],
        createdAt: now.subtract(const Duration(days: 5, hours: 8)),
      ),
      
      Note.create(
        title: "Project Architecture",
        content: """# System Architecture

## Components
1. Frontend (Flutter)
2. Backend Services
3. Database Layer

## Data Flow
```
User -> UI -> Service Layer -> Database
```

## Considerations
- Scalability
- Performance
- Security""",
        tags: ["architecture", "technical", "planning"],
        createdAt: now.subtract(const Duration(days: 4, hours: 2)),
      ),
      
      Note.create(
        title: "Meeting Notes: Team Sync",
        content: """## Team Sync - Sprint Planning

**Attendees**: Alex, Sarah, Mike

### Discussion Points
1. Current sprint progress
2. Blockers and solutions
3. Next sprint goals

### Action Items
- [ ] Update documentation
- [ ] Review pull requests
- [ ] Schedule follow-up""",
        tags: ["meeting", "team", "planning"],
        createdAt: now.subtract(const Duration(days: 3, hours: 6)),
      ),
      
      Note.create(
        title: "Feature Ideas",
        content: """# Future Features

## High Priority
1. Dark mode support
2. Offline synchronization
3. Cloud backup

## Nice to Have
- Custom themes
- Advanced search
- Data visualization

## User Requests
* Better navigation
* More keyboard shortcuts
* Export options""",
        tags: ["features", "planning", "product"],
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
      ),
      
      Note.create(
        title: "Code Review Guidelines",
        content: """# Code Review Best Practices

## Before Submitting
1. Run all tests
2. Check formatting
3. Update documentation

## Review Process
- Check logic
- Verify error handling
- Consider edge cases

## Common Issues
* Missing tests
* Poor naming
* Duplicate code""",
        tags: ["coding", "guidelines", "team"],
        createdAt: now.subtract(const Duration(days: 1, hours: 7)),
      ),
      
      Note.create(
        title: "Learning Resources",
        content: """# Development Resources

## Online Courses
1. Flutter Advanced
2. System Design
3. Machine Learning

## Books
- Clean Code
- Design Patterns
- Refactoring

## Blogs & Websites
* Flutter Dev
* Medium
* GitHub Blog""",
        tags: ["learning", "resources", "development"],
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ];

    await isar.writeTxn(() async {
      for (final note in sampleNotes) {
        await isar.notes.put(note);
      }
    });
  }
  
  /// Save a note to the database
  static Future<int> saveNote(Note note) async {
    return await isar.writeTxn(() async {
      return await isar.notes.put(note);
    });
  }
  
  /// Get a note by id
  static Future<Note?> getNote(int id) async {
    return await isar.notes.get(id);
  }
  
  /// Get all notes
  static Future<List<Note>> getAllNotes() async {
    return await isar.notes.where().findAll();
  }
  
  /// Get the most recent notes
  static Future<List<Note>> getMostRecentNotes({int limit = 3}) async {
    return await isar.notes
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }
  
  /// Delete a note
  static Future<bool> deleteNote(int id) async {
    return await isar.writeTxn(() async {
      return await isar.notes.delete(id);
    });
  }
  
  /// Search notes by title
  static Future<List<Note>> searchNotesByTitle(String query) async {
    return await isar.notes
        .filter()
        .titleContains(query, caseSensitive: false)
        .findAll();
  }
  
  /// Get notes by tag
  static Future<List<Note>> getNotesByTag(String tag) async {
    return await isar.notes
        .filter()
        .tagsElementContains(tag, caseSensitive: false)
        .findAll();
  }
  
  /// Find similar notes by embedding (cosine similarity)
  static Future<List<Note>> findSimilarNotes(List<double> embedding, {int limit = 5}) async {
    final allNotes = await getAllNotes();
    
    // Calculate cosine similarity
    List<MapEntry<Note, double>> notesWithSimilarity = [];
    
    for (var note in allNotes) {
      if (note.embedding.isEmpty) continue;
      
      double similarity = _cosineSimilarity(embedding, note.embedding);
      notesWithSimilarity.add(MapEntry(note, similarity));
    }
    
    // Sort by similarity (highest first)
    notesWithSimilarity.sort((a, b) => b.value.compareTo(a.value));
    
    // Return the top 'limit' notes
    return notesWithSimilarity
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Calculate cosine similarity between two embeddings
  static double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0;
    
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    if (normA == 0 || normB == 0) return 0;
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
  
  // ================ Event Operations ================
  
  /// Save an event to the database
  static Future<int> saveEvent(Event event) async {
    return await isar.writeTxn(() async {
      return await isar.events.put(event);
    });
  }
  
  /// Get an event by id
  static Future<Event?> getEvent(int id) async {
    return await isar.events.get(id);
  }
  
  /// Get all events
  static Future<List<Event>> getAllEvents() async {
    return await isar.events.where().findAll();
  }
  
  /// Get events for a specific date
  static Future<List<Event>> getEventsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return await isar.events
        .filter()
        .dateBetween(startOfDay, endOfDay, includeLower: true, includeUpper: true)
        .findAll();
  }
  
  /// Delete an event
  static Future<bool> deleteEvent(int id) async {
    return await isar.writeTxn(() async {
      return await isar.events.delete(id);
    });
  }
  
  // ================ Reminder Operations ================
  
  /// Save a reminder to the database
  static Future<int> saveReminder(Reminder reminder) async {
    print('DB: Saving reminder - id: ${reminder.id}, title: ${reminder.title}, completed: ${reminder.isCompleted}');
    final id = await isar.writeTxn(() async {
      final savedId = await isar.reminders.put(reminder);
      print('DB: Saved reminder with id: $savedId');
      return savedId;
    });
    return id;
  }
  
  /// Get a reminder by id
  static Future<Reminder?> getReminder(int id) async {
    print('DB: Fetching reminder with id: $id');
    final reminder = await isar.reminders.get(id);
    print('DB: ${reminder != null ? 'Found' : 'Did not find'} reminder with id: $id');
    return reminder;
  }
  
  /// Get all reminders
  static Future<List<Reminder>> getAllReminders() async {
    print('DB: Fetching all reminders');
    final reminders = await isar.reminders.where().findAll();
    print('DB: Found ${reminders.length} reminders');
    return reminders;
  }
  
  /// Get reminders for a specific date
  static Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return await isar.reminders
        .filter()
        .dueDateBetween(startOfDay, endOfDay, includeLower: true, includeUpper: true)
        .findAll();
  }
  
  /// Get incomplete reminders
  static Future<List<Reminder>> getIncompleteReminders() async {
    return await isar.reminders
        .where()
        .filter()
        .isCompletedEqualTo(false)
        .findAll();
  }
  
  /// Delete a reminder
  static Future<bool> deleteReminder(int id) async {
    print('DB: Deleting reminder with id: $id');
    final success = await isar.writeTxn(() async {
      final deleted = await isar.reminders.delete(id);
      print('DB: ${deleted ? 'Successfully deleted' : 'Failed to delete'} reminder with id: $id');
      return deleted;
    });
    return success;
  }
  
  // ================ Graph Data Operations ================
  
  /// Save graph data to the database
  static Future<int> saveGraphData(GraphData graphData) async {
    return await isar.writeTxn(() async {
      return await isar.graphDatas.put(graphData);
    });
  }
  
  /// Get the latest graph data
  static Future<GraphData?> getLatestGraphData() async {
    return await isar.graphDatas
        .where()
        .sortByUpdatedAtDesc()
        .findFirst();
  }
  
  /// Create sample reminders for testing
  static Future<void> createSampleReminders() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));
    
    final sampleReminders = [
      Reminder.create(
        title: "Complete project brief",
        description: "Finalize the project requirements document",
        dueDate: today,
        dueTime: DateTime(now.year, now.month, now.day, 17, 0), // 5:00 PM
      ),
      
      Reminder.create(
        title: "Team meeting",
        description: "Weekly sprint planning",
        dueDate: tomorrow,
        dueTime: DateTime(now.year, now.month, now.day + 1, 10, 0), // 10:00 AM
      ),
      
      Reminder.create(
        title: "Submit expense report",
        description: "Include all receipts from business trip",
        dueDate: tomorrow,
        dueTime: DateTime(now.year, now.month, now.day + 1, 15, 30), // 3:30 PM
      ),
      
      Reminder.create(
        title: "Prepare presentation",
        description: "Create slides for quarterly review",
        dueDate: today.add(const Duration(days: 3)),
        dueTime: DateTime(now.year, now.month, now.day + 3, 12, 0), // 12:00 PM
      ),
      
      Reminder.create(
        title: "Call client",
        description: "Discuss project timeline adjustments",
        dueDate: today.add(const Duration(days: 2)),
        dueTime: DateTime(now.year, now.month, now.day + 2, 14, 0), // 2:00 PM
      ),
      
      Reminder.create(
        title: "Review code pull requests",
        description: "Check the team's latest submissions",
        dueDate: today,
        dueTime: DateTime(now.year, now.month, now.day, 16, 0), // 4:00 PM
      ),
      
      Reminder.create(
        title: "Schedule interviews",
        description: "Coordinate with HR for new position candidates",
        dueDate: nextWeek,
        dueTime: DateTime(now.year, now.month, now.day + 7, 11, 0), // 11:00 AM
      ),
      
      Reminder.create(
        title: "Update documentation",
        description: "Revise API documentation with recent changes",
        dueDate: today.add(const Duration(days: 4)),
        dueTime: DateTime(now.year, now.month, now.day + 4, 13, 0), // 1:00 PM
      ),
    ];

    await isar.writeTxn(() async {
      for (final reminder in sampleReminders) {
        await isar.reminders.put(reminder);
      }
    });
  }
} 