import '../../models/expensesModels/expense_model.dart';

abstract class ExpenseEvent {}

// Load expenses
class LoadExpenses extends ExpenseEvent {
  final String? category;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isRecurring;
  final String? projectId;
  final int limit;

  LoadExpenses({
    this.category,
    this.status,
    this.startDate,
    this.endDate,
    this.isRecurring,
    this.projectId,
    this.limit = 20,
  });
}

// Load single expense
class LoadExpenseDetails extends ExpenseEvent {
  final String expenseId;

  LoadExpenseDetails(this.expenseId);
}

// Add new expense
class AddExpense extends ExpenseEvent {
  final ExpenseModel expense;

  AddExpense(this.expense);
}

// Update existing expense
class UpdateExpense extends ExpenseEvent {
  final String expenseId;
  final ExpenseModel expense;

  UpdateExpense(this.expenseId, this.expense);
}

// Delete expense
class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  DeleteExpense(this.expenseId);
}

// Permanently delete expense
class PermanentlyDeleteExpense extends ExpenseEvent {
  final String expenseId;

  PermanentlyDeleteExpense(this.expenseId);
}

// Search expenses
class SearchExpenses extends ExpenseEvent {
  final String searchTerm;

  SearchExpenses(this.searchTerm);
}

// Filter expenses
class FilterExpenses extends ExpenseEvent {
  final String? category;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isRecurring;

  FilterExpenses({
    this.category,
    this.status,
    this.startDate,
    this.endDate,
    this.isRecurring,
  });
}

// Approve expense
class ApproveExpense extends ExpenseEvent {
  final String expenseId;

  ApproveExpense(this.expenseId);
}

// Mark expense as paid
class MarkExpenseAsPaid extends ExpenseEvent {
  final String expenseId;

  MarkExpenseAsPaid(this.expenseId);
}

// Reject expense
class RejectExpense extends ExpenseEvent {
  final String expenseId;
  final String reason;

  RejectExpense(this.expenseId, this.reason);
}

// Load expense statistics
class LoadExpenseStatistics extends ExpenseEvent {
  final DateTime startDate;
  final DateTime endDate;

  LoadExpenseStatistics(this.startDate, this.endDate);
}

// Load recurring expenses
class LoadRecurringExpenses extends ExpenseEvent {}

// Export expenses
class ExportExpenses extends ExpenseEvent {
  final String format; // 'csv' or 'pdf'
  final DateTime? startDate;
  final DateTime? endDate;

  ExportExpenses(this.format, {this.startDate, this.endDate});
}
