import 'package:flutter/material.dart';
import '../services/db.dart';
import '../models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notes_render_screen.dart';

class NoteGroup {
  String header;
  List<Note> notes;
  bool isCustom;

  NoteGroup({
    required this.header,
    required this.notes,
    this.isCustom = false,
  });
}

class NoteOrganizationScreen extends StatefulWidget {
  const NoteOrganizationScreen({super.key});

  @override
  State<NoteOrganizationScreen> createState() => _NoteOrganizationScreenState();
}

class _NoteOrganizationScreenState extends State<NoteOrganizationScreen> {
  static const String _sortPreferenceKey = 'note_sort_preference';
  bool _isTimeBasedSorting = true;
  List<NoteGroup> _groups = [];
  Set<String> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadPreferences();
    await _loadNotes();
    // Initialize with expanded groups only if in time-based sorting
    setState(() {
      if (_isTimeBasedSorting) {
        _expandedGroups = _groups.map((group) => group.header).toSet();
      } else {
        _expandedGroups.clear();
      }
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final hasVisitedBefore = prefs.getBool('has_visited_notes') ?? false;
    
    if (!hasVisitedBefore) {
      await prefs.setBool('has_visited_notes', true);
      setState(() {
        _isTimeBasedSorting = true;
      });
    } else {
      setState(() {
        _isTimeBasedSorting = prefs.getBool(_sortPreferenceKey) ?? true;
      });
    }
  }

  Future<void> _loadNotes() async {
    final notes = await NeuronDatabase.getAllNotes();
    _organizeNotes(notes);
  }

  void _organizeNotes(List<Note> notes) {
    if (_isTimeBasedSorting) {
      _organizeByDate(notes);
    } else {
      _organizeByTags(notes);
    }
  }

  void _organizeByDate(List<Note> notes) {
    final groupedNotes = <String, List<Note>>{};
    
    for (final note in notes) {
      final dateStr = _formatDate(note.createdAt);
      groupedNotes.putIfAbsent(dateStr, () => []).add(note);
    }

    setState(() {
      _groups = groupedNotes.entries
          .map((e) => NoteGroup(header: e.key, notes: e.value))
          .toList()
        ..sort((a, b) => b.notes.first.createdAt.compareTo(a.notes.first.createdAt));
    });
  }

  void _organizeByTags(List<Note> notes) {
    final groupedNotes = <String, List<Note>>{};
    
    // Group by tags
    for (final note in notes) {
      if (note.tags.isEmpty) {
        groupedNotes.putIfAbsent('Untagged', () => []).add(note);
      } else {
        for (final tag in note.tags) {
          groupedNotes.putIfAbsent(tag, () => []).add(note);
        }
      }
    }

    setState(() {
      _groups = groupedNotes.entries
          .map((e) => NoteGroup(
                header: e.key,
                notes: e.value,
                isCustom: e.key != 'Untagged',
              ))
          .toList()
        ..sort((a, b) {
          // Always put 'Untagged' at the end
          if (a.header == 'Untagged') return 1;
          if (b.header == 'Untagged') return -1;
          // Case-insensitive alphabetical sort for other tags
          return a.header.toLowerCase().compareTo(b.header.toLowerCase());
        });
    });
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _toggleSortingMode() async {
    setState(() {
      _isTimeBasedSorting = !_isTimeBasedSorting;
      // When switching modes, set expand state based on the mode
      if (_isTimeBasedSorting) {
        _expandedGroups = _groups.map((group) => group.header).toSet();
      } else {
        _expandedGroups.clear();
      }
    });
    
    final notes = await NeuronDatabase.getAllNotes();
    _organizeNotes(notes);
    
    // Save the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sortPreferenceKey, _isTimeBasedSorting);
  }

  void _toggleGroup(String header) {
    setState(() {
      if (_expandedGroups.contains(header)) {
        _expandedGroups.remove(header);
      } else {
        _expandedGroups.add(header);
      }
    });
  }

  void _expandAll() {
    setState(() {
      _expandedGroups = _groups.map((group) => group.header).toSet();
    });
  }

  void _collapseAll() {
    setState(() {
      _expandedGroups.clear();
    });
  }

  Future<void> _deleteNote(Note note) async {
    await NeuronDatabase.deleteNote(note.id);
    await _loadNotes(); // This will reorganize groups and remove empty ones
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F2D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Notes',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTimeBasedSorting ? Icons.access_time : Icons.local_offer,
              color: Colors.white70,
            ),
            onPressed: _toggleSortingMode,
            tooltip: _isTimeBasedSorting ? 'Switch to Tags' : 'Switch to Time-Based',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _expandAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Expand All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _collapseAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Collapse All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _groups.length,
              itemBuilder: (context, groupIndex) {
                final group = _groups[groupIndex];
                final isExpanded = _expandedGroups.contains(group.header);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _toggleGroup(group.header),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.header,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFFE0E7FF),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: const Color(0xFFE0E7FF),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      ...group.notes.map((note) => Dismissible(
                        key: Key('note-${note.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.shade800,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          _deleteNote(note);
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 2.0),
                          title: Text(
                            note.title ?? 'Untitled Note',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotesRenderScreen(
                                  noteId: note.id,
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 