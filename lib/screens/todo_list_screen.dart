import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';

/// Full Todo List Screen
class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
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
    final activeTodos = todos.where((t) => !t.isCompleted).toList();
    final completedTodos = todos.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('To-Do List'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Add todo input
          _buildAddInput(),

          // Todo list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (activeTodos.isNotEmpty) ...[
                  _buildSectionHeader('Active Tasks', activeTodos.length),
                  ...activeTodos.map((todo) => _buildTodoItem(todo)),
                ],
                if (completedTodos.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('Completed', completedTodos.length),
                  ...completedTodos.map((todo) => _buildTodoItem(todo)),
                ],
                if (todos.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddInput() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: false,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Add a new task...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _addTodo(),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _addTodo,
            icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(todoListProvider.notifier).toggleTodo(todo.id);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: todo.isCompleted
                      ? Colors.green.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: todo.isCompleted
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: todo.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.green.withValues(alpha: 0.8),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                color: todo.isCompleted
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(todoListProvider.notifier).deleteTodo(todo.id);
            },
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
