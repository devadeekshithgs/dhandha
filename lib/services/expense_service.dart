import 'package:dhandha/models/expense.dart';
import 'package:dhandha/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ExpenseService {
  static const _uuid = Uuid();

  static Future<void> initializeSampleData() async {
    final existing = getAllExpenses();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final sampleExpenses = [
      Expense(
        id: _uuid.v4(), category: 'Rent', amount: 10000,
        date: DateTime(now.year, now.month, 1), notes: 'Monthly shop rent',
        createdAt: now,
      ),
      Expense(
        id: _uuid.v4(), category: 'Electricity', amount: 1200,
        date: now.subtract(const Duration(days: 15)),
        notes: 'Electricity bill', createdAt: now,
      ),
      Expense(
        id: _uuid.v4(), category: 'Transportation', amount: 500,
        date: now.subtract(const Duration(days: 3)),
        notes: 'Stock delivery charges', createdAt: now,
      ),
      Expense(
        id: _uuid.v4(), category: 'Miscellaneous', amount: 350,
        date: now.subtract(const Duration(days: 1)),
        notes: 'Packing materials', createdAt: now,
      ),
    ];

    for (var expense in sampleExpenses) {
      await saveExpense(expense);
    }
  }

  static Future<void> saveExpense(Expense expense) async {
    await StorageService.saveToBox(StorageService.expensesBox, expense.id, expense.toJson());
  }

  static Expense? getExpenseById(String id) {
    final data = StorageService.getFromBox(StorageService.expensesBox, id);
    return data != null ? Expense.fromJson(data) : null;
  }

  static List<Expense> getAllExpenses() {
    final data = StorageService.getAllFromBox(StorageService.expensesBox);
    return data.map((json) => Expense.fromJson(json)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<Expense> getExpensesForDate(DateTime date) {
    return getAllExpenses().where((exp) =>
      exp.date.year == date.year &&
      exp.date.month == date.month &&
      exp.date.day == date.day
    ).toList();
  }

  static List<Expense> getExpensesForMonth(int year, int month) {
    return getAllExpenses().where((exp) =>
      exp.date.year == year && exp.date.month == month
    ).toList();
  }

  static double getTodayExpenses() {
    final today = getExpensesForDate(DateTime.now());
    return today.fold<double>(0, (sum, exp) => sum + exp.amount);
  }

  static double getMonthExpenses(int year, int month) {
    final expenses = getExpensesForMonth(year, month);
    return expenses.fold<double>(0, (sum, exp) => sum + exp.amount);
  }

  static Future<void> deleteExpense(String id) async {
    await StorageService.deleteFromBox(StorageService.expensesBox, id);
  }
}
