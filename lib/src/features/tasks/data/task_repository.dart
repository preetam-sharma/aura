import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/task_model.dart';
import '../../auth/data/auth_repository.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'aura');
  final String? _uid;

  TaskRepository(this._uid);

  CollectionReference get _tasksRef => 
      _firestore.collection('users').doc(_uid).collection('tasks');

  Stream<List<TaskItem>> watchTasks({DateTime? date}) {
    if (_uid == null) return Stream.value([]);
    var query = _tasksRef.orderBy('createdAt', descending: true);
    
    return query.snapshots().map((snapshot) {
      final all = snapshot.docs
          .map((doc) => TaskItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      if (date != null) {
        final targetDate = DateTime(date.year, date.month, date.day);
        return all.where((task) {
          final created = task.createdAt ?? DateTime.now();
          final createdDate = DateTime(created.year, created.month, created.day);
          
          // Logic:
          // 1. Task created on this date
          if (createdDate.isAtSameMomentAs(targetDate)) return true;
          
          // 2. Task is carry forward:
          if (task.carryForward) {
            // If not completed, and created before or on targetDate, show it
            if (!task.isCompleted && createdDate.isBefore(targetDate)) return true;
            
            // If completed, show it on the day it was completed
            if (task.isCompleted && task.completedAt != null) {
              final comp = task.completedAt!;
              final compDate = DateTime(comp.year, comp.month, comp.day);
              if (compDate.isAtSameMomentAs(targetDate)) return true;
            }
          }
          
          return false;
        }).toList();
      }
      return all;
    });
  }

  Future<void> addTask(TaskItem task) async {
    if (_uid == null) return;
    await _tasksRef.add(task.toMap());
  }

  Future<void> updateTask(TaskItem task) async {
    if (_uid == null) return;
    await _tasksRef.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    if (_uid == null) return;
    await _tasksRef.doc(id).delete();
  }

  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    if (_uid == null) return;
    final updates = {
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? DateTime.now().toIso8601String() : null,
    };
    await _tasksRef.doc(id).update(updates);
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  return TaskRepository(user?.uid);
});

class SelectedTaskDate extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  void setDate(DateTime date) => state = DateTime(date.year, date.month, date.day);
}

final selectedTaskDateProvider = NotifierProvider<SelectedTaskDate, DateTime>(SelectedTaskDate.new);

final tasksStreamProvider = StreamProvider<List<TaskItem>>((ref) {
  final date = ref.watch(selectedTaskDateProvider);
  return ref.watch(taskRepositoryProvider).watchTasks(date: date);
});
