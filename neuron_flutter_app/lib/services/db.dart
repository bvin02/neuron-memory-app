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
  static Future<void> initialize({bool forceRecreate = false}) async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NoteSchema, EventSchema, ReminderSchema, GraphDataSchema],
      directory: dir.path,
    );

    // Clear and recreate sample notes if forced or if there are no notes
    final noteCount = await isar.notes.count();
    if (forceRecreate || noteCount == 0) {
      await clearAllNotes(); // Clear existing notes
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
    // First clear all existing notes
    await clearAllNotes();
    print('Cleared all existing notes');
    
    final now = DateTime.now();
    final sampleNotes = [
      // Original 8 notes with enhanced embeddings and tags
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
3. Documentation updates

## Success Metrics
* Sprint velocity
* Code quality metrics
* Team satisfaction""",
        tags: ["project-management", "agile", "team-coordination"],
        embedding: [0.82, 0.15, -0.23, 0.45, 0.67, -0.12, 0.34, 0.91, -0.56, 0.78],
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
- Consider mobile deployment

### Research Papers
1. "Attention Is All You Need"
2. "BERT: Pre-training of Deep Bidirectional Transformers"
3. "Mobile-Former: Bridging MobileNet and Transformer" """,
        tags: ["machine-learning", "deep-learning", "research-papers"],
        embedding: [0.95, 0.23, 0.67, -0.34, 0.12, 0.89, -0.45, 0.56, 0.78, -0.91],
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
3. Navigation elements

## Accessibility
- WCAG 2.1 compliance
- Color contrast ratios
- Screen reader support""",
        tags: ["design-system", "accessibility", "ui-components"],
        embedding: [0.34, 0.78, -0.56, 0.91, 0.23, -0.67, 0.45, 0.12, -0.89, 0.01],
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
- Security

## Technical Stack
- Flutter for cross-platform UI
- Node.js microservices
- PostgreSQL for data persistence
- Redis for caching""",
        tags: ["system-design", "architecture", "tech-stack"],
        embedding: [0.67, -0.45, 0.89, 0.12, 0.34, -0.78, 0.56, 0.23, -0.91, 0.04],
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
- [ ] Schedule follow-up

### Decisions Made
1. Adopt new code review process
2. Implement automated testing
3. Weekly architecture reviews""",
        tags: ["meetings", "sprint-planning", "team-collaboration"],
        embedding: [0.56, 0.91, -0.23, 0.78, 0.34, -0.67, 0.12, 0.45, -0.89, 0.01],
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
* Export options

## Market Research
- Competitor analysis
- User feedback synthesis
- Usage metrics""",
        tags: ["product-roadmap", "user-experience", "feature-planning"],
        embedding: [0.78, -0.34, 0.91, 0.23, 0.56, -0.67, 0.12, 0.45, -0.89, 0.01],
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
* Duplicate code

## Best Practices
1. Small, focused changes
2. Clear commit messages
3. Documentation updates""",
        tags: ["code-quality", "development-process", "best-practices"],
        embedding: [0.89, 0.12, -0.45, 0.67, 0.34, -0.78, 0.23, 0.56, -0.91, 0.04],
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
* GitHub Blog

## Learning Paths
1. Mobile Development
2. Cloud Architecture
3. AI/ML Integration""",
        tags: ["education", "professional-development", "resources"],
        embedding: [0.45, 0.91, -0.23, 0.67, 0.34, -0.78, 0.12, 0.56, -0.89, 0.01],
        createdAt: now.subtract(const Duration(hours: 5)),
      ),

      // Additional 10 new notes with diverse topics and meaningful content
      Note.create(
        title: "API Security Best Practices",
        content: """# API Security Guidelines

## Authentication
1. JWT implementation
2. OAuth2 flow
3. API key management

## Security Measures
- Rate limiting
- Input validation
- Request sanitization

## Monitoring
* Access logs
* Error tracking
* Performance metrics

## Common Vulnerabilities
1. SQL injection
2. XSS attacks
3. CSRF protection""",
        tags: ["security", "api-design", "best-practices"],
        embedding: [0.78, 0.34, -0.56, 0.91, 0.23, -0.67, 0.45, 0.12, -0.89, 0.01],
        createdAt: now.subtract(const Duration(days: 8, hours: 2)),
      ),

      Note.create(
        title: "Mobile App Performance Optimization",
        content: """# Performance Optimization

## Key Metrics
1. Launch time
2. Frame rate
3. Memory usage

## Optimization Techniques
- Image caching
- Lazy loading
- Memory management

## Monitoring Tools
* Firebase Performance
* XCode Instruments
* Android Profiler

## Best Practices
1. Minimize main thread work
2. Optimize asset loading
3. Implement proper state management""",
        tags: ["mobile-development", "performance", "optimization"],
        embedding: [0.67, 0.91, -0.34, 0.56, 0.23, -0.78, 0.12, 0.45, -0.89, 0.01],
        createdAt: now.subtract(const Duration(days: 9, hours: 4)),
      ),

      Note.create(
        title: "State Management Patterns",
        content: """# State Management

## Popular Solutions
1. Provider
2. Bloc
3. Riverpod

## Key Concepts
- State immutability
- Unidirectional data flow
- Dependency injection

## Implementation Patterns
* Repository pattern
* Service locator
* Factory methods

## Testing Strategies
1. Unit tests
2. Widget tests
3. Integration tests""",
        tags: ["flutter", "state-management", "architecture"],
        embedding: [0.89, 0.23, -0.45, 0.67, 0.34, -0.91, 0.12, 0.56, -0.78, 0.01],
        createdAt: now.subtract(const Duration(days: 10, hours: 6)),
      ),

      Note.create(
        title: "Database Schema Design",
        content: """# Database Architecture

## Schema Design
1. Normalization rules
2. Index optimization
3. Relationship mapping

## Performance
- Query optimization
- Caching strategies
- Connection pooling

## Data Types
* Numeric types
* Text and BLOB
* Temporal types

## Backup Strategies
1. Full backups
2. Incremental backups
3. Point-in-time recovery""",
        tags: ["database", "schema-design", "optimization"],
        embedding: [0.56, 0.78, -0.23, 0.91, 0.45, -0.67, 0.34, 0.12, -0.89, 0.01],
        createdAt: now.subtract(const Duration(days: 11, hours: 3)),
      ),

      Note.create(
        title: "CI/CD Pipeline Setup",
        content: """# Continuous Integration/Deployment

## Pipeline Stages
1. Build
2. Test
3. Deploy

## Tools
- Jenkins
- GitHub Actions
- Docker

## Automation
* Automated testing
* Code quality checks
* Deployment scripts

## Best Practices
1. Fast feedback
2. Parallel execution
3. Environment parity""",
        tags: ["devops", "automation", "deployment"],
        embedding: [0.45, 0.91, -0.34, 0.67, 0.23, -0.78, 0.12, 0.56, -0.89, 0.01],
        createdAt: now.subtract(const Duration(days: 12, hours: 5)),
      ),

      Note.create(
        title: "User Authentication Flow",
        content: """# Authentication System

## Login Methods
1. Email/Password
2. Social auth
3. Biometric

## Security Measures
- Password hashing
- Session management
- 2FA implementation

## User Experience
* Smooth onboarding
* Password recovery
* Account management

## Technical Implementation
1. Token management
2. Secure storage
3. API integration""",
        tags: ["authentication", "security", "user-experience"],
        embedding: [0.78, 0.23, -0.56, 0.91, 0.34, -0.67, 0.12, 0.45, -0.89, 0.01],
        createdAt: now.subtract(const Duration(days: 13, hours: 7)),
      ),

      Note.create(
        title: "Error Handling Strategies",
        content: """# Error Management

## Error Types
1. Network errors
2. User input errors
3. System errors

## Handling Approaches
- Try-catch blocks
- Error boundaries
- Graceful degradation

## User Communication
* Clear messages
* Recovery options
* Error tracking

## Monitoring
1. Error logging
2. Analytics
3. User feedback""",
        tags: ["error-handling", "user-experience", "monitoring"],
        embedding: [0.67, 0.91, -0.23, 0.56, 0.34, -0.78, 0.12, 0.45, -0.89, 0.01],
        createdAt: now.subtract(const Duration(days: 14, hours: 4)),
      ),

      Note.create(
        title: "Responsive Design Principles",
        content: """# Responsive UI

## Layout Principles
1. Fluid grids
2. Flexible images
3. Media queries

## Breakpoints
- Mobile
- Tablet
- Desktop

## Testing
* Cross-device testing
* Accessibility checks
* Performance metrics

## Best Practices
1. Mobile-first approach
2. Progressive enhancement
3. Content prioritization""",
        tags: ["responsive-design", "ui-development", "mobile-first"],
        embedding: [0.89, 0.34, -0.45, 0.67, 0.23, -0.91, 0.12, 0.56, -0.78, 0.01],
        createdAt: now.subtract(const Duration(days: 15, hours: 6)),
      ),

      Note.create(
        title: "Data Analytics Implementation",
        content: """# Analytics System

## Tracking Points
1. User actions
2. Performance metrics
3. Error events

## Tools
- Google Analytics
- Mixpanel
- Custom solutions

## Data Processing
* Event filtering
* Data aggregation
* Visualization

## Insights
1. User behavior
2. Feature usage
3. Performance trends""",
        tags: ["analytics", "data-analysis", "monitoring"],
        embedding: [0.56, 0.78, -0.34, 0.91, 0.23, -0.67, 0.45, 0.12, -0.89, 0.01],
        createdAt: now.subtract(const Duration(days: 16, hours: 3)),
      ),

      Note.create(
        title: "App Localization Guide",
        content: """# Localization

## Implementation Steps
1. String extraction
2. Translation management
3. RTL support

## Best Practices
- Context provision
- Placeholder handling
- Number formatting

## Testing
* String verification
* Layout testing
* Cultural appropriateness

## Tools
1. Flutter intl
2. Translation management
3. Automated testing""",
        tags: ["localization", "internationalization", "flutter"],
        embedding: [0.45, 0.91, -0.23, 0.67, 0.34, -0.78, 0.12, 0.56, -0.89, 0.01],
        createdAt: now.subtract(const Duration(days: 17, hours: 5)),
      ),
    ];

    // Step 1: First save all notes to get their IDs
    final savedNoteIds = <int>[];
    await isar.writeTxn(() async {
      for (final note in sampleNotes) {
        final id = await isar.notes.put(note);
        savedNoteIds.add(id);
        print('Saved note with ID: $id, Title: ${note.title}');
      }
    });

    // Step 2: Retrieve all saved notes to work with their IDs
    final savedNotes = await Future.wait(
      savedNoteIds.map((id) => isar.notes.get(id))
    );
    print('Retrieved ${savedNotes.length} notes for linking');

    // Step 3: Create backlinks based on embedding similarity and content relevance
    await isar.writeTxn(() async {
      for (int i = 0; i < savedNotes.length; i++) {
        final currentNote = savedNotes[i]!;
        print('\nProcessing links for note: ${currentNote.title}');
        
        // Calculate similarities with other notes
        List<MapEntry<Note, double>> similarities = [];
        for (int j = 0; j < savedNotes.length; j++) {
          if (i == j) continue;
          final otherNote = savedNotes[j]!;
          
          // Calculate embedding similarity
          double embeddingSimilarity = _cosineSimilarity(
            currentNote.embedding,
            otherNote.embedding
          );
          
          // Calculate tag similarity (number of shared tags / total unique tags)
          Set<String> currentTags = currentNote.tags.toSet();
          Set<String> otherTags = otherNote.tags.toSet();
          double tagSimilarity = currentTags.intersection(otherTags).length /
              currentTags.union(otherTags).length;
          
          // Combined similarity score (70% embedding, 30% tags)
          double combinedSimilarity = (embeddingSimilarity * 0.7) + (tagSimilarity * 0.3);
          
          similarities.add(MapEntry(otherNote, combinedSimilarity));
          print('Similarity with ${otherNote.title}: $combinedSimilarity');
        }
        
        // Sort by similarity and take top 2 most relevant notes
        similarities.sort((a, b) => b.value.compareTo(a.value));
        final mostSimilar = similarities.take(2).map((e) => e.key).toList();
        print('Most similar notes: ${mostSimilar.map((n) => n.title).join(', ')}');
        
        // Clear existing links
        await currentNote.links.load();
        currentNote.links.clear();
        print('Cleared existing links');
        
        // Add new links and save
        for (final similarNote in mostSimilar) {
          // Load the links collection for the similar note
          await similarNote.links.load();
          
          // Add bidirectional links
          currentNote.links.add(similarNote);
          print('Added link from ${currentNote.title} to ${similarNote.title}');
          
          // Save both notes
          await isar.notes.put(similarNote);
        }
        await isar.notes.put(currentNote);
        
        // Verify links were saved for this note
        final verifiedNote = await isar.notes.get(currentNote.id!);
        await verifiedNote?.links.load();
        print('Verified links for ${verifiedNote?.title}: ${verifiedNote?.links.length ?? 0} links');
      }
    });

    // Step 4: Final verification of all links
    print('\nFinal verification of all notes and their links:');
    final allNotes = await getAllNotes();
    for (final note in allNotes) {
      await note.links.load();
      final linkedTitles = note.links.map((n) => n.title).join(', ');
      print('''
Note: ${note.title}
ID: ${note.id}
Number of links: ${note.links.length}
Linked to: $linkedTitles
''');
    }
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