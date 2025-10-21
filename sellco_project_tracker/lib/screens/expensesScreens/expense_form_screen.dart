import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../bloc/expense/expense_state.dart';
import '../../models/expensesModels/expense_model.dart';
import '../../components/constant/expense_categories.dart';
import '../../service/firebase_service.dart';

class ExpenseFormScreen extends StatefulWidget {
  final ExpenseModel? expense;
  final bool isEdit;

  const ExpenseFormScreen({
    super.key,
    this.expense,
    this.isEdit = false,
  });

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _vendorContactController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedCategory = ExpenseCategories.equipment;
  String _selectedSubcategory = ExpenseCategories.computerHardware;
  String _selectedPaymentMethod = ExpenseCategories.companyCard;
  String _selectedStatus = ExpenseCategories.pending;
  DateTime _expenseDate = DateTime.now();
  bool _isRecurring = false;
  String? _recurrencePeriod;
  DateTime? _nextRecurrenceDate;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _populateForm(widget.expense!);
    }
  }

  void _populateForm(ExpenseModel expense) {
    _titleController.text = expense.title;
    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toString();
    _vendorNameController.text = expense.vendorName;
    _vendorContactController.text = expense.vendorContact;
    _notesController.text = expense.notes;
    _tagsController.text = expense.tags.join(', ');
    _selectedCategory = expense.category;
    _selectedSubcategory = expense.subcategory;
    _selectedPaymentMethod = expense.paymentMethod;
    _selectedStatus = expense.status;
    _expenseDate = expense.expenseDate;
    _isRecurring = expense.isRecurring;
    _recurrencePeriod = expense.recurrencePeriod;
    _nextRecurrenceDate = expense.nextRecurrenceDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _vendorNameController.dispose();
    _vendorContactController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = FirebaseService().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    // Parse tags
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final expense = ExpenseModel(
      expenseId: widget.expense?.expenseId ?? '',
      category: _selectedCategory,
      subcategory: _selectedSubcategory,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      currency: 'USD',
      expenseDate: _expenseDate,
      paymentMethod: _selectedPaymentMethod,
      vendorName: _vendorNameController.text.trim(),
      vendorContact: _vendorContactController.text.trim(),
      isRecurring: _isRecurring,
      recurrencePeriod: _isRecurring ? _recurrencePeriod : null,
      nextRecurrenceDate: _isRecurring ? _nextRecurrenceDate : null,
      tags: tags,
      status: _selectedStatus,
      notes: _notesController.text.trim(),
      createdBy: widget.expense?.createdBy ?? currentUser.uid,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.isEdit && widget.expense != null) {
      context.read<ExpenseBloc>().add(
            UpdateExpense(
              widget.expense!.expenseId,
              expense,
            ),
          );
    } else {
      context.read<ExpenseBloc>().add(
            AddExpense(expense),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Expense' : 'Add Expense'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text(
              'SAVE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Expense Title *',
                  hintText: 'e.g., New laptop for development',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an expense title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category and Subcategory
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                      ),
                      items: ExpenseCategories.getAllCategories().map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                ExpenseCategories.getCategoryIcon(category),
                                size: 20,
                                color: ExpenseCategories.getCategoryColor(category),
                              ),
                              const SizedBox(width: 8),
                              Text(ExpenseCategories.getCategoryName(category)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                          // Reset subcategory to first available
                          final subcategories = ExpenseCategories.getSubcategoriesForCategory(value);
                          _selectedSubcategory = subcategories.isNotEmpty
                              ? subcategories.first
                              : '';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubcategory,
                      decoration: const InputDecoration(
                        labelText: 'Subcategory *',
                        border: OutlineInputBorder(),
                      ),
                      items: ExpenseCategories.getSubcategoriesForCategory(_selectedCategory)
                          .map((subcategory) {
                        return DropdownMenuItem(
                          value: subcategory,
                          child: Text(
                            ExpenseCategories.getSubcategoryName(subcategory),
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubcategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount and Date
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        hintText: '0.00',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expenseDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 7)),
                        );
                        if (date != null) {
                          setState(() {
                            _expenseDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Expense Date *',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('MMM d, yyyy').format(_expenseDate)),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Payment Details Section
              _buildSectionHeader('Payment Details'),
              const SizedBox(height: 16),

              // Payment Method
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method *',
                  border: OutlineInputBorder(),
                ),
                items: ExpenseCategories.getAllPaymentMethods().map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(ExpenseCategories.getPaymentMethodName(method)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Vendor Name
              TextFormField(
                controller: _vendorNameController,
                decoration: const InputDecoration(
                  labelText: 'Vendor Name',
                  hintText: 'e.g., Amazon, Best Buy',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),

              // Vendor Contact
              TextFormField(
                controller: _vendorContactController,
                decoration: const InputDecoration(
                  labelText: 'Vendor Contact',
                  hintText: 'Email or phone number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_mail),
                ),
              ),
              const SizedBox(height: 24),

              // Additional Details Section
              _buildSectionHeader('Additional Details'),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Provide more details about this expense',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'e.g., urgent, project-alpha (comma-separated)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any additional notes',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                ),
                items: ExpenseCategories.getAllStatuses().map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          ExpenseCategories.getStatusIcon(status),
                          size: 20,
                          color: ExpenseCategories.getStatusColor(status),
                        ),
                        const SizedBox(width: 8),
                        Text(ExpenseCategories.getStatusName(status)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Recurring Settings Section
              _buildSectionHeader('Recurring Settings'),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('This is a recurring expense'),
                subtitle: const Text('Automatically create this expense periodically'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    if (value) {
                      _recurrencePeriod = ExpenseCategories.monthly;
                      _nextRecurrenceDate = DateTime.now().add(const Duration(days: 30));
                    }
                  });
                },
              ),

              if (_isRecurring) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _recurrencePeriod,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence Period *',
                    border: OutlineInputBorder(),
                  ),
                  items: ExpenseCategories.getAllRecurrencePeriods().map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(ExpenseCategories.getRecurrencePeriodName(period)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _recurrencePeriod = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _nextRecurrenceDate ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null) {
                      setState(() {
                        _nextRecurrenceDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Next Recurrence Date *',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _nextRecurrenceDate != null
                              ? DateFormat('MMM d, yyyy').format(_nextRecurrenceDate!)
                              : 'Select date',
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.isEdit ? 'Update Expense' : 'Add Expense',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
