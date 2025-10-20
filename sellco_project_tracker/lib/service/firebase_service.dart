import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/expense_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected sign in error: $e');
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Create user error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected create user error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected password reset error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get user display name
  String? get userDisplayName => _auth.currentUser?.displayName;

  // Get user email
  String? get userEmail => _auth.currentUser?.email;

  // ========== EXPENSE MANAGEMENT METHODS ==========

  // Create a new expense
  Future<String> createExpense(ExpenseModel expense) async {
    try {
      final docRef = await _firestore.collection('expenses').add(expense.toMap());
      debugPrint('Expense created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Create expense error: $e');
      rethrow;
    }
  }

  // Update an existing expense
  Future<void> updateExpense(String expenseId, ExpenseModel expense) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).update(expense.toMap());
      debugPrint('Expense updated: $expenseId');
    } catch (e) {
      debugPrint('Update expense error: $e');
      rethrow;
    }
  }

  // Delete an expense (soft delete)
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).update({
        'is_deleted': true,
        'deleted_at': FieldValue.serverTimestamp(),
        'deleted_by': currentUser?.uid,
      });
      debugPrint('Expense soft deleted: $expenseId');
    } catch (e) {
      debugPrint('Delete expense error: $e');
      rethrow;
    }
  }

  // Permanently delete an expense
  Future<void> permanentlyDeleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).delete();
      debugPrint('Expense permanently deleted: $expenseId');
    } catch (e) {
      debugPrint('Permanent delete expense error: $e');
      rethrow;
    }
  }

  // Get a single expense by ID
  Future<ExpenseModel?> getExpenseById(String expenseId) async {
    try {
      final doc = await _firestore.collection('expenses').doc(expenseId).get();
      if (doc.exists && doc.data() != null) {
        return ExpenseModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Get expense error: $e');
      rethrow;
    }
  }

  // Get expenses with optional filters
  Future<List<ExpenseModel>> getExpenses({
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRecurring,
    String? projectId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('expenses').where('is_deleted', isEqualTo: false);

      // Apply filters
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (isRecurring != null) {
        query = query.where('is_recurring', isEqualTo: isRecurring);
      }
      if (projectId != null) {
        query = query.where('project_id', isEqualTo: projectId);
      }
      if (startDate != null) {
        query = query.where('expense_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('expense_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      // Order and limit
      query = query.orderBy('expense_date', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Get expenses error: $e');
      rethrow;
    }
  }

  // Get expenses stream (real-time updates)
  Stream<List<ExpenseModel>> getExpensesStream({
    String? category,
    String? status,
    int limit = 20,
  }) {
    try {
      Query query = _firestore.collection('expenses').where('is_deleted', isEqualTo: false);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('expense_date', descending: true).limit(limit);

      return query.snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>)).toList(),
          );
    } catch (e) {
      debugPrint('Get expenses stream error: $e');
      rethrow;
    }
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('is_deleted', isEqualTo: false)
          .where('expense_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('expense_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('expense_date', descending: true)
          .get();

      return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Get expenses by date range error: $e');
      rethrow;
    }
  }

  // Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String category, {DateTime? startDate, DateTime? endDate}) async {
    try {
      Query query = _firestore.collection('expenses').where('is_deleted', isEqualTo: false).where('category', isEqualTo: category);

      if (startDate != null) {
        query = query.where('expense_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('expense_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('expense_date', descending: true);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Get expenses by category error: $e');
      rethrow;
    }
  }

  // Get recurring expenses
  Future<List<ExpenseModel>> getRecurringExpenses() async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('is_deleted', isEqualTo: false)
          .where('is_recurring', isEqualTo: true)
          .orderBy('next_recurrence_date')
          .get();

      return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Get recurring expenses error: $e');
      rethrow;
    }
  }

  // Get total expenses for a period
  Future<double> getTotalExpensesByPeriod(DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('is_deleted', isEqualTo: false)
          .where('expense_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('expense_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final expense = ExpenseModel.fromMap(doc.data());
        total += expense.amount;
      }

      return total;
    } catch (e) {
      debugPrint('Get total expenses error: $e');
      rethrow;
    }
  }

  // Get expense statistics by category
  Future<Map<String, double>> getExpenseStatsByCategory(DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('is_deleted', isEqualTo: false)
          .where('expense_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('expense_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<String, double> stats = {};
      for (var doc in snapshot.docs) {
        final expense = ExpenseModel.fromMap(doc.data());
        stats[expense.category] = (stats[expense.category] ?? 0) + expense.amount;
      }

      return stats;
    } catch (e) {
      debugPrint('Get expense stats error: $e');
      rethrow;
    }
  }

  // Search expenses
  Future<List<ExpenseModel>> searchExpenses(String searchTerm) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('is_deleted', isEqualTo: false)
          .orderBy('expense_date', descending: true)
          .limit(100)
          .get();

      // Filter results client-side (Firestore doesn't support full-text search)
      final searchLower = searchTerm.toLowerCase();
      final results = snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data())).where((expense) {
        return expense.title.toLowerCase().contains(searchLower) ||
            expense.description.toLowerCase().contains(searchLower) ||
            expense.vendorName.toLowerCase().contains(searchLower) ||
            expense.tags.any((tag) => tag.toLowerCase().contains(searchLower));
      }).toList();

      return results;
    } catch (e) {
      debugPrint('Search expenses error: $e');
      rethrow;
    }
  }

  // Upload receipt image
  Future<String> uploadReceipt(String expenseId, File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child('expenses/receipts/$expenseId/$fileName');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      debugPrint('Receipt uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload receipt error: $e');
      rethrow;
    }
  }

  // Delete receipt image
  Future<void> deleteReceipt(String receiptUrl) async {
    try {
      final ref = _storage.refFromURL(receiptUrl);
      await ref.delete();
      debugPrint('Receipt deleted: $receiptUrl');
    } catch (e) {
      debugPrint('Delete receipt error: $e');
      rethrow;
    }
  }

  // Approve expense
  Future<void> approveExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).update({
        'status': 'approved',
        'approved_by': currentUser?.uid,
        'approved_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Expense approved: $expenseId');
    } catch (e) {
      debugPrint('Approve expense error: $e');
      rethrow;
    }
  }

  // Mark expense as paid
  Future<void> markExpenseAsPaid(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).update({
        'status': 'paid',
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Expense marked as paid: $expenseId');
    } catch (e) {
      debugPrint('Mark expense as paid error: $e');
      rethrow;
    }
  }

  // Reject expense
  Future<void> rejectExpense(String expenseId, String reason) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).update({
        'status': 'rejected',
        'notes': reason,
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Expense rejected: $expenseId');
    } catch (e) {
      debugPrint('Reject expense error: $e');
      rethrow;
    }
  }
}
