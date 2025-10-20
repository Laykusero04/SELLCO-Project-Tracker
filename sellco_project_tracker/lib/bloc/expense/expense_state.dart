import '../../models/expense_model.dart';

abstract class ExpenseState {}

// Initial state
class ExpenseInitial extends ExpenseState {}

// Loading state
class ExpenseLoading extends ExpenseState {}

// Expenses loaded successfully
class ExpensesLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String? appliedFilter;

  ExpensesLoaded(this.expenses, {this.appliedFilter});
}

// Single expense loaded
class ExpenseDetailsLoaded extends ExpenseState {
  final ExpenseModel expense;

  ExpenseDetailsLoaded(this.expense);
}

// Expense operation successful
class ExpenseOperationSuccess extends ExpenseState {
  final String message;
  final String? expenseId;

  ExpenseOperationSuccess(this.message, {this.expenseId});
}

// Error state
class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError(this.message);
}

// Statistics loaded
class ExpenseStatisticsLoaded extends ExpenseState {
  final Map<String, double> categoryStats;
  final double totalExpenses;
  final DateTime startDate;
  final DateTime endDate;

  ExpenseStatisticsLoaded({
    required this.categoryStats,
    required this.totalExpenses,
    required this.startDate,
    required this.endDate,
  });
}

// Receipt uploaded
class ReceiptUploaded extends ExpenseState {
  final String receiptUrl;

  ReceiptUploaded(this.receiptUrl);
}

// Receipt deleted
class ReceiptDeleted extends ExpenseState {
  final String message;

  ReceiptDeleted(this.message);
}

// Export completed
class ExportCompleted extends ExpenseState {
  final String filePath;
  final String format;

  ExportCompleted(this.filePath, this.format);
}

// Search results
class ExpenseSearchResults extends ExpenseState {
  final List<ExpenseModel> results;
  final String searchTerm;

  ExpenseSearchResults(this.results, this.searchTerm);
}

// Recurring expenses loaded
class RecurringExpensesLoaded extends ExpenseState {
  final List<ExpenseModel> recurringExpenses;

  RecurringExpensesLoaded(this.recurringExpenses);
}
