import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String expenseId;
  final String category;
  final String subcategory;
  final String title;
  final String description;
  final double amount;
  final String currency;
  final DateTime expenseDate;
  final String paymentMethod;
  final String vendorName;
  final String vendorContact;
  final List<String> receiptUrls;
  final bool isRecurring;
  final String? recurrencePeriod;
  final DateTime? nextRecurrenceDate;
  final String? projectId;
  final List<String> tags;
  final String status;
  final String notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;

  ExpenseModel({
    required this.expenseId,
    required this.category,
    required this.subcategory,
    required this.title,
    required this.description,
    required this.amount,
    this.currency = 'USD',
    required this.expenseDate,
    required this.paymentMethod,
    this.vendorName = '',
    this.vendorContact = '',
    this.receiptUrls = const [],
    this.isRecurring = false,
    this.recurrencePeriod,
    this.nextRecurrenceDate,
    this.projectId,
    this.tags = const [],
    this.status = 'pending',
    this.notes = '',
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.approvedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
  });

  // Convert ExpenseModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'expense_id': expenseId,
      'category': category,
      'subcategory': subcategory,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'expense_date': Timestamp.fromDate(expenseDate),
      'payment_method': paymentMethod,
      'vendor_name': vendorName,
      'vendor_contact': vendorContact,
      'receipt_urls': receiptUrls,
      'is_recurring': isRecurring,
      'recurrence_period': recurrencePeriod,
      'next_recurrence_date': nextRecurrenceDate != null
          ? Timestamp.fromDate(nextRecurrenceDate!)
          : null,
      'project_id': projectId,
      'tags': tags,
      'status': status,
      'notes': notes,
      'created_by': createdBy,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'approved_by': approvedBy,
      'approved_at':
          approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'deleted_by': deletedBy,
    };
  }

  // Create ExpenseModel from Firestore document
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      expenseId: map['expense_id'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      expenseDate: (map['expense_date'] as Timestamp).toDate(),
      paymentMethod: map['payment_method'] ?? '',
      vendorName: map['vendor_name'] ?? '',
      vendorContact: map['vendor_contact'] ?? '',
      receiptUrls: List<String>.from(map['receipt_urls'] ?? []),
      isRecurring: map['is_recurring'] ?? false,
      recurrencePeriod: map['recurrence_period'],
      nextRecurrenceDate: map['next_recurrence_date'] != null
          ? (map['next_recurrence_date'] as Timestamp).toDate()
          : null,
      projectId: map['project_id'],
      tags: List<String>.from(map['tags'] ?? []),
      status: map['status'] ?? 'pending',
      notes: map['notes'] ?? '',
      createdBy: map['created_by'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
      approvedBy: map['approved_by'],
      approvedAt: map['approved_at'] != null
          ? (map['approved_at'] as Timestamp).toDate()
          : null,
      isDeleted: map['is_deleted'] ?? false,
      deletedAt: map['deleted_at'] != null
          ? (map['deleted_at'] as Timestamp).toDate()
          : null,
      deletedBy: map['deleted_by'],
    );
  }

  // Create a copy with modified fields
  ExpenseModel copyWith({
    String? expenseId,
    String? category,
    String? subcategory,
    String? title,
    String? description,
    double? amount,
    String? currency,
    DateTime? expenseDate,
    String? paymentMethod,
    String? vendorName,
    String? vendorContact,
    List<String>? receiptUrls,
    bool? isRecurring,
    String? recurrencePeriod,
    DateTime? nextRecurrenceDate,
    String? projectId,
    List<String>? tags,
    String? status,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedBy,
    DateTime? approvedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
  }) {
    return ExpenseModel(
      expenseId: expenseId ?? this.expenseId,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vendorName: vendorName ?? this.vendorName,
      vendorContact: vendorContact ?? this.vendorContact,
      receiptUrls: receiptUrls ?? this.receiptUrls,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePeriod: recurrencePeriod ?? this.recurrencePeriod,
      nextRecurrenceDate: nextRecurrenceDate ?? this.nextRecurrenceDate,
      projectId: projectId ?? this.projectId,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }
}
