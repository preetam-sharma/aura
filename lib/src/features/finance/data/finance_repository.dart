import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/finance_models.dart';
import '../../auth/data/auth_repository.dart';

class FinanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'aura');
  final String? _uid;

  FinanceRepository(this._uid);

  CollectionReference get _expensesRef => 
      _firestore.collection('users').doc(_uid).collection('expenses');
  
  CollectionReference get _goalsRef => 
      _firestore.collection('users').doc(_uid).collection('goals');

  CollectionReference get _incomeRef => 
      _firestore.collection('users').doc(_uid).collection('income');

  CollectionReference get _categoriesRef => 
      _firestore.collection('users').doc(_uid).collection('finance_categories');

  Stream<List<Expense>> watchExpenses({DateTime? month}) {
    if (_uid == null) return Stream.value([]);
    var query = _expensesRef.orderBy('date', descending: true);
    
    return query.snapshots().map((snapshot) {
      final all = snapshot.docs
          .map((doc) => Expense.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      if (month != null) {
        return all.where((e) => e.date.year == month.year && e.date.month == month.month).toList();
      }
      return all;
    });
  }

  Stream<List<SavingGoal>> watchGoals() {
    if (_uid == null) return Stream.value([]);
    return _goalsRef
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavingGoal.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<Income>> watchIncome({DateTime? month}) {
    if (_uid == null) return Stream.value([]);
    var query = _incomeRef.orderBy('date', descending: true);
    
    return query.snapshots().map((snapshot) {
      final all = snapshot.docs
          .map((doc) => Income.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      if (month != null) {
        return all.where((i) => i.date.year == month.year && i.date.month == month.month).toList();
      }
      return all;
    });
  }

  Future<void> addExpense(Expense expense) async {
    if (_uid == null) return;
    await _expensesRef.add(expense.toMap());
  }

  Future<void> addGoal(SavingGoal goal) async {
    if (_uid == null) return;
    await _goalsRef.add(goal.toMap());
  }

  Future<void> addIncome(Income income) async {
    if (_uid == null) return;
    await _incomeRef.add(income.toMap());
  }

  Future<void> updateGoalProgress(String goalId, double currentAmount) async {
    if (_uid == null) return;
    await _goalsRef.doc(goalId).update({'currentAmount': currentAmount});
  }

  Future<void> updateExpense(Expense expense) async {
    if (_uid == null) return;
    await _expensesRef.doc(expense.id).update(expense.toMap());
  }

  Future<void> updateIncome(Income income) async {
    if (_uid == null) return;
    await _incomeRef.doc(income.id).update(income.toMap());
  }

  Future<void> updateGoal(SavingGoal goal) async {
    if (_uid == null) return;
    await _goalsRef.doc(goal.id).update(goal.toMap());
  }

  Future<void> deleteExpense(String id) async {
    if (_uid == null) return;
    await _expensesRef.doc(id).delete();
  }

  Future<void> deleteIncome(String id) async {
    if (_uid == null) return;
    await _incomeRef.doc(id).delete();
  }

  Future<void> deleteGoal(String id) async {
    if (_uid == null) return;
    await _goalsRef.doc(id).delete();
  }

  Stream<List<String>> watchCustomCategories() {
    if (_uid == null) return Stream.value([]);
    return _categoriesRef.snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<void> addCustomCategory(String category) async {
    if (_uid == null) return;
    await _categoriesRef.doc(category).set({'createdAt': FieldValue.serverTimestamp()});
  }
}

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  return FinanceRepository(user?.uid);
});

class SelectedFinanceDate extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }
  
  void setDate(DateTime date) => state = date;
}

final selectedFinanceDateProvider = NotifierProvider<SelectedFinanceDate, DateTime>(SelectedFinanceDate.new);

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final date = ref.watch(selectedFinanceDateProvider);
  return ref.watch(financeRepositoryProvider).watchExpenses(month: date);
});

final goalsStreamProvider = StreamProvider<List<SavingGoal>>((ref) {
  return ref.watch(financeRepositoryProvider).watchGoals();
});

final incomeStreamProvider = StreamProvider<List<Income>>((ref) {
  final date = ref.watch(selectedFinanceDateProvider);
  return ref.watch(financeRepositoryProvider).watchIncome(month: date);
});

final customCategoriesStreamProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(financeRepositoryProvider).watchCustomCategories();
});
