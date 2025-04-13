import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/db.dart';
import '../models/graph_data.dart';

class GraphViewScreen extends StatefulWidget {
  const GraphViewScreen({super.key});

  @override
  State<GraphViewScreen> createState() => _GraphViewScreenState();
}

class _GraphViewScreenState extends State<GraphViewScreen> {
  GraphData? _graphData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGraphData();
  }

  Future<void> _loadGraphData() async {
    try {
      final graphDataList = await NeuronDatabase.getLatestGraphData();
      setState(() {
        _graphData = graphDataList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading graph data: $e');
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(width: 8),
                    Text(
                      'Knowledge Graph',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white70,
                        ),
                      )
                    : _graphData == null
                        ? const Center(
                            child: Text(
                              'No graph data available',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : Center(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Graph visualization will be displayed here',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A route that slides in from the bottom
class BottomSlideRoute extends PageRouteBuilder {
  final Widget page;
  
  BottomSlideRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
}

/// Widget to detect bottom edge swipe up
class BottomSwipeDetector extends StatefulWidget {
  final Widget child;
  final Function onSwipeUp;
  
  const BottomSwipeDetector({
    super.key,
    required this.child,
    required this.onSwipeUp,
  });
  
  @override
  State<BottomSwipeDetector> createState() => _BottomSwipeDetectorState();
}

class _BottomSwipeDetectorState extends State<BottomSwipeDetector> {
  double _startY = 0.0;
  bool _isBottomEdge = false;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 50, // Detection area at bottom edge
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: (details) {
              _startY = details.globalPosition.dy;
              final screenHeight = MediaQuery.of(context).size.height;
              if (_startY > screenHeight - 50) {
                _isBottomEdge = true;
              } else {
                _isBottomEdge = false;
              }
            },
            onVerticalDragEnd: (details) {
              if (_isBottomEdge && details.primaryVelocity != null && details.primaryVelocity! < -500) {
                // Swipe up from bottom edge with sufficient velocity
                widget.onSwipeUp();
              }
            },
            child: Container(
              // Invisible container
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
} 