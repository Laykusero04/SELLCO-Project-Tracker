import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../service/firebase_service.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final FirebaseService _firebaseService;

  ExpenseBloc({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService(),
        super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadExpenseDetails>(_onLoadExpenseDetails);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<PermanentlyDeleteExpense>(_onPermanentlyDeleteExpense);
    on<SearchExpenses>(_onSearchExpenses);
    on<FilterExpenses>(_onFilterExpenses);
    on<UploadReceipt>(_onUploadReceipt);
    on<DeleteReceipt>(_onDeleteReceipt);
    on<ApproveExpense>(_onApproveExpense);
    on<MarkExpenseAsPaid>(_onMarkExpenseAsPaid);
    on<RejectExpense>(_onRejectExpense);
    on<LoadExpenseStatistics>(_onLoadExpenseStatistics);
    on<LoadRecurringExpenses>(_onLoadRecurringExpenses);
    on<ExportExpenses>(_onExportExpenses);
  }

  // Load expenses
  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final expenses = await _firebaseService.getExpenses(
        category: event.category,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        isRecurring: event.isRecurring,
        projectId: event.projectId,
        limit: event.limit,
      );
      emit(ExpensesLoaded(expenses));
    } catch (e) {
      debugPrint('Load expenses error: $e');
      emit(ExpenseError('Failed to load expenses: ${e.toString()}'));
    }
  }

  // Load single expense details
  Future<void> _onLoadExpenseDetails(
    LoadExpenseDetails event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final expense = await _firebaseService.getExpenseById(event.expenseId);
      if (expense != null) {
        emit(ExpenseDetailsLoaded(expense));
      } else {
        emit(ExpenseError('Expense not found'));
      }
    } catch (e) {
      debugPrint('Load expense details error: $e');
      emit(ExpenseError('Failed to load expense details: ${e.toString()}'));
    }
  }

  // Add new expense
  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());

      // Create expense in Firestore
      final expenseId = await _firebaseService.createExpense(event.expense);

      // Upload receipts if provided
      List<String> receiptUrls = [];
      if (event.receiptFiles != null && event.receiptFiles!.isNotEmpty) {
        for (var file in event.receiptFiles!) {
          final url = await _firebaseService.uploadReceipt(expenseId, file);
          receiptUrls.add(url);
        }

        // Update expense with receipt URLs
        final updatedExpense = event.expense.copyWith(
          expenseId: expenseId,
          receiptUrls: receiptUrls,
        );
        await _firebaseService.updateExpense(expenseId, updatedExpense);
      }

      emit(ExpenseOperationSuccess('Expense added successfully', expenseId: expenseId));
    } catch (e) {
      debugPrint('Add expense error: $e');
      emit(ExpenseError('Failed to add expense: ${e.toString()}'));
    }
  }

  // Update existing expense
  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());

      // Upload new receipts if provided
      List<String> newReceiptUrls = List.from(event.expense.receiptUrls);
      if (event.newReceiptFiles != null && event.newReceiptFiles!.isNotEmpty) {
        for (var file in event.newReceiptFiles!) {
          final url = await _firebaseService.uploadReceipt(event.expenseId, file);
          newReceiptUrls.add(url);
        }
      }

      // Update expense with new receipt URLs
      final updatedExpense = event.expense.copyWith(
        receiptUrls: newReceiptUrls,
        updatedAt: DateTime.now(),
      );

      await _firebaseService.updateExpense(event.expenseId, updatedExpense);
      emit(ExpenseOperationSuccess('Expense updated successfully', expenseId: event.expenseId));
    } catch (e) {
      debugPrint('Update expense error: $e');
      emit(ExpenseError('Failed to update expense: ${e.toString()}'));
    }
  }

  // Delete expense (soft delete)
  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      await _firebaseService.deleteExpense(event.expenseId);
      emit(ExpenseOperationSuccess('Expense deleted successfully'));
    } catch (e) {
      debugPrint('Delete expense error: $e');
      emit(ExpenseError('Failed to delete expense: ${e.toString()}'));
    }
  }

  // Permanently delete expense
  Future<void> _onPermanentlyDeleteExpense(
    PermanentlyDeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      await _firebaseService.permanentlyDeleteExpense(event.expenseId);
      emit(ExpenseOperationSuccess('Expense permanently deleted'));
    } catch (e) {
      debugPrint('Permanent delete error: $e');
      emit(ExpenseError('Failed to permanently delete expense: ${e.toString()}'));
    }
  }

  // Search expenses
  Future<void> _onSearchExpenses(
    SearchExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final results = await _firebaseService.searchExpenses(event.searchTerm);
      emit(ExpenseSearchResults(results, event.searchTerm));
    } catch (e) {
      debugPrint('Search expenses error: $e');
      emit(ExpenseError('Failed to search expenses: ${e.toString()}'));
    }
  }

  // Filter expenses
  Future<void> _onFilterExpenses(
    FilterExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final expenses = await _firebaseService.getExpenses(
        category: event.category,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        isRecurring: event.isRecurring,
      );

      String? filterDescription;
      if (event.category != null || event.status != null || event.startDate != null) {
        filterDescription = 'Filtered';
      }

      emit(ExpensesLoaded(expenses, appliedFilter: filterDescription));
    } catch (e) {
      debugPrint('Filter expenses error: $e');
      emit(ExpenseError('Failed to filter expenses: ${e.toString()}'));
    }
  }

  // Upload receipt
  Future<void> _onUploadReceipt(
    UploadReceipt event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final url = await _firebaseService.uploadReceipt(event.expenseId, event.imageFile);

      // Get the expense and add the new receipt URL
      final expense = await _firebaseService.getExpenseById(event.expenseId);
      if (expense != null) {
        final updatedReceiptUrls = List<String>.from(expense.receiptUrls)..add(url);
        final updatedExpense = expense.copyWith(receiptUrls: updatedReceiptUrls);
        await _firebaseService.updateExpense(event.expenseId, updatedExpense);
      }

      emit(ReceiptUploaded(url));
    } catch (e) {
      debugPrint('Upload receipt error: $e');
      emit(ExpenseError('Failed to upload receipt: ${e.toString()}'));
    }
  }

  // Delete receipt
  Future<void> _onDeleteReceipt(
    DeleteReceipt event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());

      // Delete from storage
      await _firebaseService.deleteReceipt(event.receiptUrl);

      // Update expense to remove receipt URL
      final expense = await _firebaseService.getExpenseById(event.expenseId);
      if (expense != null) {
        final updatedReceiptUrls = expense.receiptUrls.where((url) => url != event.receiptUrl).toList();
        final updatedExpense = expense.copyWith(receiptUrls: updatedReceiptUrls);
        await _firebaseService.updateExpense(event.expenseId, updatedExpense);
      }

      emit(ReceiptDeleted('Receipt deleted successfully'));
    } catch (e) {
      debugPrint('Delete receipt error: $e');
      emit(ExpenseError('Failed to delete receipt: ${e.toString()}'));
    }
  }

  // Approve expense
  Future<void> _onApproveExpense(
    ApproveExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      await _firebaseService.approveExpense(event.expenseId);
      emit(ExpenseOperationSuccess('Expense approved successfully'));
    } catch (e) {
      debugPrint('Approve expense error: $e');
      emit(ExpenseError('Failed to approve expense: ${e.toString()}'));
    }
  }

  // Mark expense as paid
  Future<void> _onMarkExpenseAsPaid(
    MarkExpenseAsPaid event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      await _firebaseService.markExpenseAsPaid(event.expenseId);
      emit(ExpenseOperationSuccess('Expense marked as paid'));
    } catch (e) {
      debugPrint('Mark expense as paid error: $e');
      emit(ExpenseError('Failed to mark expense as paid: ${e.toString()}'));
    }
  }

  // Reject expense
  Future<void> _onRejectExpense(
    RejectExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      await _firebaseService.rejectExpense(event.expenseId, event.reason);
      emit(ExpenseOperationSuccess('Expense rejected'));
    } catch (e) {
      debugPrint('Reject expense error: $e');
      emit(ExpenseError('Failed to reject expense: ${e.toString()}'));
    }
  }

  // Load expense statistics
  Future<void> _onLoadExpenseStatistics(
    LoadExpenseStatistics event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final categoryStats = await _firebaseService.getExpenseStatsByCategory(
        event.startDate,
        event.endDate,
      );
      final totalExpenses = await _firebaseService.getTotalExpensesByPeriod(
        event.startDate,
        event.endDate,
      );

      emit(ExpenseStatisticsLoaded(
        categoryStats: categoryStats,
        totalExpenses: totalExpenses,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      debugPrint('Load statistics error: $e');
      emit(ExpenseError('Failed to load statistics: ${e.toString()}'));
    }
  }

  // Load recurring expenses
  Future<void> _onLoadRecurringExpenses(
    LoadRecurringExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final recurringExpenses = await _firebaseService.getRecurringExpenses();
      emit(RecurringExpensesLoaded(recurringExpenses));
    } catch (e) {
      debugPrint('Load recurring expenses error: $e');
      emit(ExpenseError('Failed to load recurring expenses: ${e.toString()}'));
    }
  }

  // Export expenses
  Future<void> _onExportExpenses(
    ExportExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());

      // Get expenses for the specified date range
      final expenses = await _firebaseService.getExpenses(
        startDate: event.startDate,
        endDate: event.endDate,
        limit: 1000, // Get all expenses for export
      );

      // Export logic will be implemented when creating export screens
      // For now, verify we have data to export
      if (expenses.isEmpty) {
        emit(ExpenseError('No expenses found for the selected date range'));
        return;
      }

      emit(ExportCompleted('/path/to/export', event.format));
    } catch (e) {
      debugPrint('Export expenses error: $e');
      emit(ExpenseError('Failed to export expenses: ${e.toString()}'));
    }
  }
}
