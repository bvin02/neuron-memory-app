import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DragTarget {
  final Note note;
  final bool isHeader;
  _DragTarget(this.note, {this.isHeader = false});
}

class NoteOrganizationScreen extends StatefulWidget {
  const NoteOrganizationScreen({super.key});

  @override
  State<NoteOrganizationScreen> createState() => _NoteOrganizationScreenState();
}

class _NoteOrganizationScreenState extends State<NoteOrganizationScreen> {
  static const String _sortPreferenceKey = 'note_sort_preference';
  bool _isTimeBasedSorting = true;
  final _noteModel = NoteModel();
  List<NoteGroup> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _updateGroups(); // Add immediate update while preferences load
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final hasVisitedBefore = prefs.getBool('has_visited_notes') ?? false;
    
    if (!hasVisitedBefore) {
      // First visit - set to time view
      await prefs.setBool('has_visited_notes', true);
      setState(() {
        _isTimeBasedSorting = true;
      });
    } else {
      // Subsequent visits - load last preference
      setState(() {
        _isTimeBasedSorting = prefs.getBool(_sortPreferenceKey) ?? true;
      });
    }
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await _noteModel.loadNotes();
    _updateGroups();
  }

  void _updateGroups() {
    if (_isTimeBasedSorting) {
      _organizeByDate();
    } else {
      _organizeByCustomGroups();
    }
  }

  void _organizeByDate() {
    final groupedNotes = <String, List<Note>>{};
    
    // Get all notes from both the main list and custom groups
    final allNotes = [..._noteModel.notes];
    for (final group in _noteModel.customGroups.values) {
      allNotes.addAll(group.notes);
    }
    
    // Remove duplicates based on note ID
    final uniqueNotes = allNotes.fold<Map<String, Note>>({}, (map, note) {
      map[note.id] = note;
      return map;
    }).values.toList();

    // Group by date
    for (final note in uniqueNotes) {
      final dateStr = _formatDate(note.modifiedAt);
      groupedNotes.putIfAbsent(dateStr, () => []).add(note);
    }

    setState(() {
      _groups = groupedNotes.entries
          .map((e) => NoteGroup(header: e.key, notes: e.value))
          .toList()
        ..sort((a, b) => b.notes.first.modifiedAt.compareTo(a.notes.first.modifiedAt));
    });
  }

  void _organizeByCustomGroups() {
    // Get all notes that aren't in custom groups
    final allNotes = [..._noteModel.notes];
    final groupedNoteIds = _noteModel.customGroups.values
        .expand((group) => group.notes)
        .map((note) => note.id)
        .toSet();
    
    final ungroupedNotes = allNotes.where((note) => !groupedNoteIds.contains(note.id)).toList();
    
    setState(() {
      _groups = [
        ..._noteModel.customGroups.values,
        if (ungroupedNotes.isNotEmpty)
          NoteGroup(header: 'Ungrouped', notes: ungroupedNotes),
      ];
    });
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _toggleSortingMode() async {
    setState(() {
      _isTimeBasedSorting = !_isTimeBasedSorting;
      _updateGroups();
    });
    // Save the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sortPreferenceKey, _isTimeBasedSorting);
  }

  Future<void> _createCustomGroup(Note sourceNote, Note targetNote) async {
    final groupName = await showDialog<String>(
      context: context,
      builder: (context) => _CreateGroupDialog(),
    );

    if (groupName != null && groupName.isNotEmpty) {
      final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
      _noteModel.createCustomGroup(groupId, groupName, [sourceNote, targetNote]);
      _updateGroups();
    }
  }

  void _addToGroup(Note note, String groupId) {
    if (_noteModel.customGroups.containsKey(groupId)) {
      note.customGroupId = groupId;
      _noteModel.customGroups[groupId]!.notes.add(note);
      _noteModel.saveNotes();
      _updateGroups();
    }
  }

  void _removeFromGroup(Note note) {
    final groupId = note.customGroupId;
    if (groupId != null) {
      note.customGroupId = null;
      _noteModel.customGroups[groupId]?.notes.remove(note);
      if (_noteModel.customGroups[groupId]?.notes.isEmpty ?? false) {
        _noteModel.customGroups.remove(groupId);
      }
      _noteModel.saveNotes();
      _updateGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(_isTimeBasedSorting ? Icons.access_time : Icons.drag_handle),
            onPressed: _toggleSortingMode,
            tooltip: _isTimeBasedSorting ? 'Switch to Custom Order' : 'Switch to Time-Based',
          ),
        ],
      ),
      body: _isTimeBasedSorting ? _buildTimeBasedList() : _buildDraggableList(),
    );
  }

  Widget _buildTimeBasedList() {
    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, groupIndex) {
        final group = _groups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                group.header,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ...group.notes.map((note) => _buildNoteButton(note)),
          ],
        );
      },
    );
  }

  Widget _buildDraggableList() {
    return ReorderableListView.builder(
      itemCount: _groups.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final group = _groups.removeAt(oldIndex);
        _groups.insert(newIndex, group);
        _noteModel.saveNotes();
      },
      itemBuilder: (context, groupIndex) {
        final group = _groups[groupIndex];
        return Column(
          key: ValueKey('group_$groupIndex'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.isCustom)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.header,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (context) => _CreateGroupDialog(initialName: group.header),
                        );
                        if (newName != null && newName.isNotEmpty) {
                          setState(() {
                            group.header = newName;
                            _noteModel.saveNotes();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ...group.notes.asMap().entries.map((entry) {
              final noteIndex = entry.key;
              final note = entry.value;
              return _buildDraggableNote(note, group, groupIndex, noteIndex);
            }),
          ],
        );
      },
    );
  }

  Widget _buildNoteButton(Note note) {
    return ListTile(
      key: ValueKey(note.id),
      title: Text(
        note.title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () {
        // TODO: Navigate to note detail view
      },
    );
  }

  Widget _buildDraggableNote(Note note, NoteGroup group, int groupIndex, int noteIndex) {
    return LongPressDraggable<_DragTarget>(
      key: ValueKey('${group.header}_${note.id}'),
      data: _DragTarget(note),
      feedback: Material(
        elevation: 4.0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).colorScheme.surface,
          child: Text(
            note.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
      child: DragTarget<_DragTarget>(
        onWillAccept: (data) => data?.note.id != note.id,
        onAccept: (data) {
          final sourceNote = data.note;
          if (sourceNote.customGroupId == null && note.customGroupId == null) {
            _createCustomGroup(sourceNote, note);
          } else if (note.customGroupId != null) {
            _addToGroup(sourceNote, note.customGroupId!);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Draggable<Note>(
            data: note,
            feedback: Material(
              elevation: 4.0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).colorScheme.surface,
                child: Text(
                  note.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            child: DragTarget<Note>(
              onWillAccept: (draggedNote) => draggedNote?.id != note.id,
              onAccept: (draggedNote) {
                setState(() {
                  // Handle reordering within the same group
                  if (draggedNote.customGroupId == note.customGroupId) {
                    final sourceGroup = _groups.firstWhere(
                      (g) => g.notes.any((n) => n.id == draggedNote.id)
                    );
                    final sourceIndex = sourceGroup.notes.indexWhere((n) => n.id == draggedNote.id);
                    final targetIndex = group.notes.indexWhere((n) => n.id == note.id);
                    
                    sourceGroup.notes.removeAt(sourceIndex);
                    group.notes.insert(targetIndex, draggedNote);
                  } else {
                    // Handle moving between groups
                    if (draggedNote.customGroupId != null) {
                      _removeFromGroup(draggedNote);
                    }
                    if (note.customGroupId != null) {
                      _addToGroup(draggedNote, note.customGroupId!);
                    } else {
                      _createCustomGroup(draggedNote, note);
                    }
                  }
                  _noteModel.saveNotes();
                });
              },
              builder: (context, candidateData, rejectedData) {
                return ListTile(
                  title: Text(
                    note.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  leading: const Icon(Icons.drag_indicator),
                  trailing: note.customGroupId != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeFromGroup(note),
                      )
                    : null,
                  onTap: () {
                    // TODO: Navigate to note detail view
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CreateGroupDialog extends StatefulWidget {
  final String? initialName;

  const _CreateGroupDialog({this.initialName});

  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName != null ? 'Rename Group' : 'Create Group'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Group Name',
          hintText: 'Enter a name for this group',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
} 