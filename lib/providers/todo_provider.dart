import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart';

const _uuid = Uuid();

/// Provider for the Hive box containing todos
final todoBoxProvider = FutureProvider<Box<TodoItem>>((ref) async {
  return await Hive.openBox<TodoItem>('todos');
});

/// Provider for the list of todos
final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<TodoItem>>((ref) {
      return TodoListNotifier(ref);
    });

class TodoListNotifier extends StateNotifier<List<TodoItem>> {
  final Ref ref;
  Box<TodoItem>? _box;

  TodoListNotifier(this.ref) : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<TodoItem>('todos');
      state = _box!.values.toList();
    } catch (e) {
      // Handle error
      state = [];
    }
  }

  Future<void> addTodo(String title) async {
    // Wait for box to be initialized if not ready
    _box ??= await Hive.openBox<TodoItem>('todos');

    final todo = TodoItem(
      id: _uuid.v4(),
      title: title.trim(),
      createdAt: DateTime.now(),
    );

    await _box!.put(todo.id, todo);
    state = [...state, todo];
  }

  Future<void> toggleTodo(String id) async {
    if (_box == null) return;

    final todo = _box!.get(id);
    if (todo != null) {
      final updated = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
      );
      await _box!.put(id, updated);
      state = _box!.values.toList();
    }
  }

  Future<void> deleteTodo(String id) async {
    if (_box == null) return;

    await _box!.delete(id);
    state = state.where((todo) => todo.id != id).toList();
  }

  Future<void> updateTodo(String id, String newTitle) async {
    if (_box == null) return;

    final todo = _box!.get(id);
    if (todo != null) {
      final updated = todo.copyWith(title: newTitle.trim());
      await _box!.put(id, updated);
      state = _box!.values.toList();
    }
  }

  List<TodoItem> get activeTodos =>
      state.where((todo) => !todo.isCompleted).toList();

  List<TodoItem> get completedTodos =>
      state.where((todo) => todo.isCompleted).toList();
}
