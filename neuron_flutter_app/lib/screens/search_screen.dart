import 'package:flutter/material.dart';
import 'dart:ui';
import 'graph_view.dart';
import '../services/db.dart';
import '../models/note.dart';
import 'dart:math';
import 'notes_render_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  double _startX = 0.0;
  bool _isEdgeSwipe = false;
  bool _isSemanticSearch = false;
  List<Note> _searchResults = [];
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    // Auto focus on the search field when screen opens
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      if (_isSemanticSearch) {
        // Convert query to embedding using semantic features
        final words = query.toLowerCase().split(RegExp(r'\s+'));
        final embedding = List.filled(10, 0.0);
        
        // Define semantic categories and their base vectors
        final semanticCategories = {
          'development': [0.8, 0.2, 0.1, 0.3, 0.1, 0.2, 0.1, 0.1, 0.1, 0.1],
          'design': [0.2, 0.8, 0.2, 0.1, 0.3, 0.1, 0.1, 0.1, 0.1, 0.1],
          'planning': [0.1, 0.2, 0.8, 0.2, 0.1, 0.3, 0.1, 0.1, 0.1, 0.1],
          'research': [0.3, 0.1, 0.2, 0.8, 0.2, 0.1, 0.2, 0.1, 0.1, 0.1],
          'meeting': [0.1, 0.3, 0.2, 0.1, 0.8, 0.2, 0.1, 0.1, 0.1, 0.1],
          'code': [0.2, 0.1, 0.1, 0.2, 0.1, 0.8, 0.3, 0.1, 0.1, 0.1],
          'learning': [0.3, 0.2, 0.1, 0.7, 0.1, 0.2, 0.8, 0.1, 0.1, 0.1],
          'ai': [0.2, 0.1, 0.1, 0.8, 0.1, 0.2, 0.7, 0.1, 0.1, 0.1],
          'team': [0.1, 0.2, 0.7, 0.1, 0.8, 0.1, 0.2, 0.1, 0.1, 0.1],
          'feature': [0.7, 0.3, 0.6, 0.1, 0.2, 0.2, 0.1, 0.1, 0.1, 0.1],
        };
        
        // Process each word
        for (int i = 0; i < words.length; i++) {
          final word = words[i];
          double wordWeight = 1.0 + (i / words.length); // Later words slightly more important
          
          // Check for semantic category matches
          semanticCategories.forEach((category, vector) {
            if (category.contains(word) || word.contains(category)) {
              for (int j = 0; j < embedding.length; j++) {
                embedding[j] += vector[j] * wordWeight;
              }
            }
          });
          
          // Add character-based features for unknown words
          if (!semanticCategories.keys.any((cat) => cat.contains(word) || word.contains(cat))) {
            for (int j = 0; j < word.length && j < embedding.length; j++) {
              final charCode = word.codeUnitAt(j);
              embedding[j] += (charCode / 128) * wordWeight * 0.3; // Reduced weight for character-based features
            }
          }
        }
        
        // Normalize the embedding vector
        final magnitude = sqrt(embedding.map((x) => x * x).reduce((a, b) => a + b));
        if (magnitude > 0) {
          for (int i = 0; i < embedding.length; i++) {
            embedding[i] = embedding[i] / magnitude;
          }
        }
        
        print('Query: $query');
        print('Generated embedding: $embedding');
        
        // Find similar notes using the embedding
        final results = await NeuronDatabase.findSimilarNotes(embedding, limit: 5);
        
        // Debug print results
        for (final note in results) {
          print('Note found: ${note.title}');
        }
        
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } else {
        // Exact string search
        final titleResults = await NeuronDatabase.searchNotesByTitle(query);
        final allNotes = await NeuronDatabase.getAllNotes();
        final contentResults = allNotes.where(
          (note) => note.content?.toLowerCase().contains(query.toLowerCase()) ?? false
        ).toList();
        
        // Combine results, remove duplicates, and limit to 5
        final combinedResults = {...titleResults, ...contentResults}.toList();
        setState(() {
          _searchResults = combinedResults.take(5).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF080810),
            Color(0xFF16161F),
            Color(0xFF1F1F2D),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              _startX = details.globalPosition.dx;
              if (details.globalPosition.dx > MediaQuery.of(context).size.width - 50) {
                _isEdgeSwipe = true;
              } else {
                _isEdgeSwipe = false;
              }
            },
            onHorizontalDragEnd: (details) {
              final endX = details.globalPosition.dx;
              final distance = _startX - endX;
              
              if (_isEdgeSwipe && distance > 100) { // Swipe left from right edge - Exit to Home
                Navigator.of(context).pop();
              }
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.white70,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 40,
                                  ),
                                ),
                                onChanged: (value) {
                                  _performSearch(value);
                                },
                                textInputAction: TextInputAction.search,
                                onSubmitted: (value) {
                                  _performSearch(value);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SearchModeButton(
                        title: 'Exact String',
                        isSelected: !_isSemanticSearch,
                        onTap: () {
                          setState(() {
                            _isSemanticSearch = false;
                            _performSearch(_searchController.text);
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      _SearchModeButton(
                        title: 'Smart Semantic',
                        isSelected: _isSemanticSearch,
                        onTap: () {
                          setState(() {
                            _isSemanticSearch = true;
                            _performSearch(_searchController.text);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isSearching
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemBuilder: (context, index) {
                            final note = _searchResults[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  note.title ?? 'Untitled Note',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  note.content?.split('\n').first ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotesRenderScreen(
                                        noteId: note.id!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchModeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SearchModeButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(isSelected ? 1 : 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 