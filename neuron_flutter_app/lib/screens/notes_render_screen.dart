import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:ui';
import '../services/db.dart';
import '../models/note.dart';
import 'graph_view.dart';

class NotesRenderScreen extends StatefulWidget {
  final int noteId;

  const NotesRenderScreen({
    super.key,
    required this.noteId,
  });

  @override
  State<NotesRenderScreen> createState() => _NotesRenderScreenState();
}

class _NotesRenderScreenState extends State<NotesRenderScreen> {
  late TextEditingController _controller;
  bool _isEditing = false;
  double _startX = 0.0;
  bool _isEdgeSwipe = false;
  final FocusNode _focusNode = FocusNode();
  Note? _note;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final note = await NeuronDatabase.getNote(widget.noteId);
    if (note != null) {
      setState(() {
        _note = note;
        _controller.text = note.content ?? '';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _saveNote() async {
    if (_note != null) {
      _note!.content = _controller.text;
      await NeuronDatabase.saveNote(_note!);
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
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white70,
                            size: 28,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(51),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(26),
                                      width: 1,
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 40),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(Icons.tag, size: 16, color: Colors.white.withAlpha(153)),
                                          const SizedBox(width: 8),
                                          Text(
                                            _note?.tags.join(' • ') ?? 'No tags',
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(204),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(51),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(26),
                                      width: 1,
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 40),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(Icons.article, size: 16, color: Colors.white.withAlpha(153)),
                                          const SizedBox(width: 8),
                                          Text(
                                            _note?.backlinks.map((note) => note.title).join(' • ') ?? 'No backlinks',
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(204),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isEditing ? Icons.visibility : Icons.edit,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            _toggleEditMode();
                            if (!_isEditing) {
                              _saveNote();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withAlpha(26),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: _isEditing
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextField(
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    maxLines: null,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Edit your note...',
                                      hintStyle: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 16,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Markdown(
                                    data: _controller.text,
                                    selectable: true,
                                    softLineBreak: true,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        height: 1.6,
                                      ),
                                      h1: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                      ),
                                      h2: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                      ),
                                      h3: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                      ),
                                      horizontalRuleDecoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.white.withAlpha(51),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
      ),
    );
  }
} 