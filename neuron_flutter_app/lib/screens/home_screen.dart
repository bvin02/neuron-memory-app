import 'package:flutter/material.dart';
import '../widgets/neuron_card.dart';
import 'reminders_screen.dart';
import 'calendar_screen.dart';
import 'dart:math';
import '../models/reminder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isEdgeSwipe = false;
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
                      const NeuronCard(
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
                        ),
                        _buildActionButton(
                          icon: Icons.mic,
                          size: 70,
                          iconColor: const Color(0xFFE94545),
                          iconSizeMultiplier: 0.6,
                        ),
                        _buildActionButton(
                          icon: Icons.map_outlined,
                          size: 50,
                          iconSizeMultiplier: 0.55,
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
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}