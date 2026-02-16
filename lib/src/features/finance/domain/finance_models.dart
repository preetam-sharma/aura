import 'package:flutter/material.dart';

enum ExpenseCategory {
  rent,
  wifi,
  groceries,
  subscriptions,
  shopping,
  food,
  transport,
  entertainment,
  other,
  custom,
}

// Extension to help with display names
extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    if (this == ExpenseCategory.custom) return 'Add New Category';
    final name = this.name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }
}

class Income {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  Income({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Income.fromMap(String id, Map<String, dynamic> map) {
    return Income(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;

  final String? customCategory;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.customCategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'customCategory': customCategory,
    };
  }

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: ExpenseCategory.values.byName(map['category'] ?? 'other'),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      customCategory: map['customCategory'],
    );
  }
}

class SavingGoal {
  final String id;
  final String title;
  final double currentAmount;
  final double targetAmount;
  final int colorValue;
  final DateTime targetDate;

  SavingGoal({
    required this.id,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.colorValue,
    required this.targetDate,
  });

  double get progress => currentAmount / targetAmount;
  double get remaining => targetAmount - currentAmount;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'colorValue': colorValue,
      'targetDate': targetDate.toIso8601String(),
    };
  }

  factory SavingGoal.fromMap(String id, Map<String, dynamic> map) {
    return SavingGoal(
      id: id,
      title: map['title'] ?? '',
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      colorValue: map['colorValue'] ?? Colors.blue.toARGB32(),
      targetDate: DateTime.parse(map['targetDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class FinanceStats {
  final double totalBalance;
  final double monthlySpending;
  final double budgetProgress;
  final double percentageChange;

  FinanceStats({
    required this.totalBalance,
    required this.monthlySpending,
    required this.budgetProgress,
    required this.percentageChange,
  });

  factory FinanceStats.initial() {
    return FinanceStats(
      totalBalance: 0,
      monthlySpending: 0,
      budgetProgress: 0,
      percentageChange: 0,
    );
  }
}
