import 'package:flutter/material.dart';
import 'dart:ui';
import 'graph_view.dart';

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
          child: BottomSwipeDetector(
            onSwipeUp: () {
              Navigator.of(context).push(
                BottomSlideRoute(
                  page: const GraphViewScreen(),
                ),
              );
            },
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
                                    // Will implement search functionality later
                                  },
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (value) {
                                    // Will implement search functionality later
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 