import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_editable_textinput/markdown_editable_textinput.dart';

class NotesRenderScreen extends StatefulWidget {
  final String initialContent;

  const NotesRenderScreen({
    Key? key,
    required this.initialContent,
  }) : super(key: key);

  @override
  State<NotesRenderScreen> createState() => _NotesRenderScreenState();
}

class _NotesRenderScreenState extends State<NotesRenderScreen> {
  late TextEditingController _controller;
  bool _isEditing = false;
  double _startX = 0.0;
  bool _isEdgeSwipe = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
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
              if (details.globalPosition.dx < 50) {
                _isEdgeSwipe = true;
              } else {
                _isEdgeSwipe = false;
              }
            },
            onHorizontalDragEnd: (details) {
              final endX = details.globalPosition.dx;
              final distance = _startX - endX;
              
              if (_isEdgeSwipe && distance < -100) { // Swipe right from left edge - Exit to Home
                Navigator.of(context).pop();
              }
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Note',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: Icon(
                          _isEditing ? Icons.visibility : Icons.edit,
                          color: Colors.white70,
                        ),
                        onPressed: _toggleEditMode,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _isEditing
                        ? MarkdownEditableTextInput(
                            controller: _controller,
                            maxLines: null,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Start typing your note...',
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : Markdown(
                            data: _controller.text,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                              h1: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              h3: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              code: const TextStyle(
                                color: Colors.white,
                                backgroundColor: Color(0xFF2D2D3D),
                              ),
                              blockquote: const TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
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
} 