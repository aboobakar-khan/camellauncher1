import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/note_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/widget_card.dart';

/// Notes widget for dashboard
class NotesWidget extends ConsumerStatefulWidget {
  final VoidCallback? onExpand;

  const NotesWidget({super.key, this.onExpand});

  @override
  ConsumerState<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends ConsumerState<NotesWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_controller.text.trim().isEmpty) return;

    final latestNote = ref.read(noteListProvider.notifier).latestNote;

    if (latestNote != null && _isEditing) {
      ref
          .read(noteListProvider.notifier)
          .updateNote(latestNote.id, _controller.text);
    } else {
      ref.read(noteListProvider.notifier).addNote(_controller.text);
    }

    setState(() {
      _isEditing = false;
    });
    _controller.clear();
  }

  void _startEditing() {
    final latestNote = ref.read(noteListProvider.notifier).latestNote;
    if (latestNote != null) {
      _controller.text = latestNote.content;
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _deleteNote() {
    final latestNote = ref.read(noteListProvider.notifier).latestNote;
    if (latestNote != null) {
      ref.read(noteListProvider.notifier).deleteNote(latestNote.id);
      _controller.clear();
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteListProvider);
    final latestNote = notes.isEmpty ? null : notes.first;
    final themeColor = ref.watch(themeColorProvider);

    return WidgetCard(
      title: 'Quick Note',
      height: 220,
      onTap: widget.onExpand,
      onEdit: latestNote != null && !_isEditing ? _startEditing : null,
      onDelete: latestNote != null && !_isEditing ? _deleteNote : null,
      child: _isEditing || latestNote == null
          ? _buildNoteInput(themeColor)
          : _buildNoteDisplay(latestNote.content, themeColor),
    );
  }

  Widget _buildNoteInput(AppThemeColor themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: false,
            maxLines: null,
            expands: true,
            style: TextStyle(
              color: themeColor.color.withValues(alpha: 0.9),
              fontSize: 14,
              letterSpacing: 0.5,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Write something...',
              hintStyle: TextStyle(
                color: themeColor.color.withValues(alpha: 0.4),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isEditing)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditing = false;
                    _controller.clear();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: themeColor.color.withValues(alpha: 0.4),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            GestureDetector(
              onTap: _saveNote,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: themeColor.color.withValues(alpha: 0.7),
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteDisplay(String content, AppThemeColor themeColor) {
    return SingleChildScrollView(
      child: Text(
        content,
        style: TextStyle(
          color: themeColor.color.withValues(alpha: 0.6),
          fontSize: 14,
          letterSpacing: 0.5,
          height: 1.6,
        ),
      ),
    );
  }
}
