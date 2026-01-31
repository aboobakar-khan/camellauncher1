import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/widget_card.dart';

/// To-Do widget for dashboard
class TodoWidget extends ConsumerStatefulWidget {
  final VoidCallback? onExpand;

  const TodoWidget({super.key, this.onExpand});

  @override
  ConsumerState<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends ConsumerState<TodoWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTodo() {
    if (_controller.text.trim().isEmpty) return;

    ref.read(todoListProvider.notifier).addTodo(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoListProvider);
    final activeTodos = todos.where((t) => !t.isCompleted).take(3).toList();
    final themeColor = ref.watch(themeColorProvider);

    return WidgetCard(
      title: 'To-Do',
      height: 240,
      onTap: widget.onExpand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add todo input with button
          _buildAddInput(themeColor),
          const SizedBox(height: 12),

          // Todo list
          Expanded(
            child: activeTodos.isEmpty
                ? EmptyCardState(
                    message: 'No tasks yet',
                    icon: Icons.check_circle_outline,
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: activeTodos.length,
                    itemBuilder: (context, index) {
                      return _buildTodoItem(activeTodos[index], themeColor);
                    },
                  ),
          ),

          // View all hint
          if (activeTodos.length >= 3) _buildViewAllHint(themeColor),
        ],
      ),
    );
  }

  Widget _buildAddInput(AppThemeColor themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(
                color: themeColor.color.withValues(alpha: 0.7),
                fontSize: 13,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: 'Add task...',
                hintStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.3),
                  fontSize: 13,
                ),
                border: InputBorder.none,

                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: (_) => _addTodo(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _addTodo,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todo, AppThemeColor themeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(todoListProvider.notifier).toggleTodo(todo.id);
            },
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: todo.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                color: themeColor.color.withValues(alpha: 0.6),
                fontSize: 14,
                letterSpacing: 0.5,
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(todoListProvider.notifier).deleteTodo(todo.id);
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllHint(AppThemeColor themeColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextButton(
        onPressed: widget.onExpand,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Tap to view all',
          style: TextStyle(
            color: themeColor.color.withValues(alpha: 0.5),
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
