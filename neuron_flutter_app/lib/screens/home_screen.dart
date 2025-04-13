import 'package:flutter/material.dart';
import '../widgets/neuron_card.dart';
import 'reminders_screen.dart';
import 'calendar_screen.dart';
import 'dart:math';
import '../models/reminder.dart';
import 'notes_render_screen.dart';
import 'note_organization_screen.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

const String _sampleNote = '''# Meeting Notes: Arbitrage Model for Index Basket Trading

## I. Introduction and Overview

The meeting began with a discussion on implementing an arbitrage trading model based on pricing inefficiencies
between index baskets and their underlying assets.

The objective is to exploit price discrepancies between an index (e.g., S&P-like basket) and its component
stocks, creating arbitrage opportunities.

## II. Key Concepts

* **Arbitrage**: Exploiting price discrepancies between an index and its component stocks
* **Pricing Inefficiencies**: Sum of individual stock prices may not match the index price due to supply-demand dynamics
* **Strategy**:
  * If index price > sum of components → Short index, Long components
  * If index price < sum of components → Long index, Short components

## III. Structure and Positions

Three assets and two baskets:
* Basket A (all 3 assets)
* Basket B (2 of the 3)

### Types of Arbitrage:
1. Arbitrage between Basket A and all 3 products
2. Arbitrage between Basket B and the 2 products
3. Arbitrage using Basket A = Basket B + Product 3

## IV. Current Progress

Entry logic for trades has been implemented

### Remaining Tasks:
* Implement position liquidation logic when prices converge
* Ensure no position limits are exceeded when using overlapping products across multiple baskets

## V. Conclusion and Next Steps

* Review of the implementation progress and any challenges encountered
* Confirmation of the current status and plans for implementing position liquidation logic and ensuring no position limits exceedances''';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isEdgeSwipe = false;
  bool _isRecording = false;
  double _startX = 0;
  final List<Reminder> _reminders = [
    Reminder(
      id: Random().nextInt(1000000).toString(),
      text: 'Buy groceries',
      dateTime: DateTime.now(),
      time: '10:00', // 10:00 AM
    ),
    Reminder(
      id: Random().nextInt(1000000).toString(),
      text: 'Call Alice',
      dateTime: DateTime.now(),
      time: '11:00', // 11:00 AM
    ),
    Reminder(
      id: Random().nextInt(1000000).toString(),
      text: 'Finish report',
      dateTime: DateTime.now(),
      time: '14:00', // 2:00 PM
    ),
  ];
  final _audioRecorder = Record();
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        print('Microphone permission not granted');
      }
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Get the temporary directory
        final directory = await getTemporaryDirectory();
        _recordedFilePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        // Start recording with minimal parameters for version 3.0.4
        await _audioRecorder.start(
          path: _recordedFilePath!,
          encoder: AudioEncoder.AAC,
          bitRate: 128000,
          samplingRate: 44100,
        );
        
        setState(() {
          _isRecording = true;
        });
        
        print('Started recording to: $_recordedFilePath');
      } else {
        print('Microphone permission not granted');
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
        });
        
        if (path != null) {
          print('Recording saved to: $path');
        } else {
          print('Recording stopped but no file path returned');
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
      });
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
            Color(0xFF080810), // Dark shadow
            Color(0xFF16161F), // Base color
            Color(0xFF1F1F2D), // Light area
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false, // Don't pad the bottom
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              _startX = details.globalPosition.dx;
              if (details.globalPosition.dx < 50) {
                _isEdgeSwipe = true;
              } else if (details.globalPosition.dx > MediaQuery.of(context).size.width - 50) {
                _isEdgeSwipe = true;
              } else {
                _isEdgeSwipe = false;
              }
            },
            onHorizontalDragEnd: (details) {
              final endX = details.globalPosition.dx;
              final distance = _startX - endX;
              
              if (_isEdgeSwipe) {
                if (distance < -100) { // Swipe right from left edge - Enter Calendar
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const CalendarScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                    ),
                  );
                } else if (distance > 100) { // Swipe left from right edge - Enter Reminders
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => RemindersScreen(
                        reminders: _reminders,
                        onRemindersUpdated: (updatedReminders) {
                          setState(() {
                            _reminders.clear();
                            _reminders.addAll(updatedReminders);
                          });
                        },
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                    ),
                  );
                }
              }
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: 24.0,
                    bottom: 120.0, // Adjusted bottom padding
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Neuron',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 4, right: 8),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF080810),
                                        blurRadius: 24,
                                        spreadRadius: -4,
                                        offset: Offset(-8, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(1.5),
                                      decoration: BoxDecoration(
                                        gradient: const RadialGradient(
                                          center: Alignment(1.0, -1.0),
                                          radius: 1.8,
                                          colors: [
                                            Color(0xFF41414D),
                                            Color(0xFF32324b),
                                          ],
                                          stops: [0.1, 1.0],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.5),
                                          color: const Color(0xFF282837),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.note_add, color: Colors.white70),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) => NotesRenderScreen(
                                                  initialContent: _sampleNote,
                                                ),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(0.0, 1.0);
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeInOut;
                                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                  var offsetAnimation = animation.drive(tween);
                                                  return SlideTransition(position: offsetAnimation, child: child);
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF080810),
                                        blurRadius: 24,
                                        spreadRadius: -4,
                                        offset: Offset(-8, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(1.5),
                                      decoration: BoxDecoration(
                                        gradient: const RadialGradient(
                                          center: Alignment(1.0, -1.0),
                                          radius: 1.8,
                                          colors: [
                                            Color(0xFF41414D),
                                            Color(0xFF32324b),
                                          ],
                                          stops: [0.1, 1.0],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.5),
                                          color: const Color(0xFF282837),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.menu, color: Colors.white70),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      NeuronCard(
                        title: 'Calendar',
                        subtitle: '10:00  —  Team Meeting\n11:00  —  Project Update\n2:00   —  Client Call',
                        blurBackground: true,
                        onTap: (context) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const CalendarScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                return SlideTransition(position: offsetAnimation, child: child);
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      NeuronCard(
                        title: 'Reminders',
                        subtitle: '○  Buy groceries\n○  Call Alice\n○  Finish report',
                        blurBackground: true,
                        onTap: (context) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RemindersScreen(
                                reminders: _reminders,
                                onRemindersUpdated: (updatedReminders) {
                                  setState(() {
                                    _reminders.clear();
                                    _reminders.addAll(updatedReminders);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      NeuronCard(
                        title: 'Notes',
                        subtitle: 'Meeting Summary\nProject Ideas\nInterview Notes',
                        blurBackground: true,
                        gradientOverlay: RadialGradient(
                          center: Alignment(1.0, 0.8),
                          radius: 2,
                          colors: [
                            Color(0xFF192341), // Center
                            Color(0xFF14141E), // Mid
                            Color(0xFF2D142D), // Edge
                          ],
                          stops: [0.1, 0.5, 0.9],
                        ),
                        borderGradient: RadialGradient(
                          center: Alignment(1.0, 0),
                          radius: 1.8,
                          colors: [
                            Color(0xFF283750), // blue
                            Color(0xFF462D41), // purple
                          ],
                        ),
                        onTap: (context) {
                          Navigator.pushNamed(context, '/notes');
                        },
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.calendar_today,
                          size: 50,
                          iconSizeMultiplier: 0.5,
                          onPressed: () {},
                        ),
                        _buildActionButton(
                          icon: _isRecording ? Icons.stop_circle : Icons.mic,
                          size: 70,
                          iconColor: const Color(0xFFE94545),
                          iconSizeMultiplier: 0.6,
                          onPressed: () async {
                            if (_isRecording) {
                              await _stopRecording();
                            } else {
                              await _startRecording();
                            }
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.map_outlined,
                          size: 50,
                          iconSizeMultiplier: 0.55,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required double size,
    Color? iconColor,
    double iconSizeMultiplier = 0.5, // Default multiplier
    VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF080810),
              blurRadius: 24,
              spreadRadius: -4,
              offset: Offset(-8, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 4),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(1.0, -1.0),
                radius: 1.8,
                colors: [
                  Color(0xFF41414D),
                  Color(0xFF32324b),
                ],
                stops: [0.1, 1.0],
              ),
              borderRadius: BorderRadius.circular(size / 4),
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular((size / 4) - 1.5),
                color: const Color(0xFF282837),
              ),
              child: IconButton(
                icon: Icon(
                  icon,
                  color: iconColor ?? Colors.white70,
                  size: size * iconSizeMultiplier,
                ),
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}