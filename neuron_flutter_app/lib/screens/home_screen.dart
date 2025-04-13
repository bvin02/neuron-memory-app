import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/neuron_card.dart';
import 'reminders_screen.dart';
import 'calendar_screen.dart';
import 'dart:math';
import '../models/reminder.dart';
import '../models/note.dart';
import 'notes_render_screen.dart';
import 'note_organization_screen.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/audio_recorder_service.dart';
import '../services/db.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isEdgeSwipe = false;
  bool _isRecording = false;
  double _startX = 0;
  final List<Reminder> _reminders = [];
  final List<Note> _notes = [];
  final _audioService = AudioRecorderService();
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadReminders();
    _loadNotes();
  }

  @override
  void dispose() {
    _audioService.dispose(); // Dispose AudioService
    super.dispose();
  }

  Future<void> _initRecorder() async {
    await _audioService.initRecorder();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
      });
      
      if (path != null) {
        _recordedFilePath = path;
        print('Recording saved to: $path');
        
        // Extract just the filename for display
        final fileName = path.split('/').last;
        
        // Show a snackbar with the file path
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recording saved as: $fileName'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
        
        // Here you could add code to handle the recording (transcribe, etc.)
      } else {
        print('Recording stopped but no file path returned');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording stopped but file not saved'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      final success = await _audioService.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
        });
        
        // Show a snackbar to indicate recording has started
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording started'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start recording'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadReminders() async {
    final reminders = await NeuronDatabase.getAllReminders();
    print('Loaded ${reminders.length} reminders from database');
    setState(() {
      _reminders.clear();
      _reminders.addAll(reminders);
      print('Updated reminders list, now contains ${_reminders.length} items');
    });
  }

  Future<void> _loadNotes() async {
    final notes = await NeuronDatabase.getAllNotes();
    setState(() {
      _notes.clear();
      _notes.addAll(notes);
    });
  }

  void _addReminder(Reminder reminder) async {
    await NeuronDatabase.saveReminder(reminder);
    await _loadReminders();
  }

  void _updateReminder(Reminder reminder) async {
    await NeuronDatabase.saveReminder(reminder);
    await _loadReminders();
  }

  void _deleteReminder(Reminder reminder) async {
    await NeuronDatabase.deleteReminder(reminder.id);
    await _loadReminders();
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
                        subtitle: _reminders.isEmpty 
                          ? 'No reminders yet'
                          : '○  ${_reminders[0].title}\n' +
                            (_reminders.length > 1 ? '○  ${_reminders[1].title}\n' : '') +
                            (_reminders.length > 2 ? '○  ${_reminders[2].title}' : ''),
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
                        subtitle: _notes.isEmpty 
                          ? 'No notes yet'
                          : _notes.take(3).map((note) => note.title ?? 'Untitled Note').join('\n'),
                        blurBackground: true,
                        gradientOverlay: const RadialGradient(
                          center: Alignment(1.0, 0.8),
                          radius: 2,
                          colors: [
                            Color(0xFF192341), // Center
                            Color(0xFF14141E), // Mid
                            Color(0xFF2D142D), // Edge
                          ],
                          stops: [0.1, 0.5, 0.9],
                        ),
                        borderGradient: const RadialGradient(
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
                          iconColor: _isRecording ? const Color(0xFFE94545) : Colors.white70,
                          iconSizeMultiplier: 0.6,
                          onPressed: _toggleRecording, // Use our new method
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