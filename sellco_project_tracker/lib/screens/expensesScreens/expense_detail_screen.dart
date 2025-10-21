import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../bloc/expense/expense_state.dart';
import '../../models/expensesModels/expense_model.dart';
import '../../components/constant/expense_categories.dart';
import 'expense_form_screen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailScreen({
    super.key,
    required this.expenseId,
  });

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  ExpenseModel? _lastLoadedExpense;

  @override
  void initState() {
    super.initState();
    // Load expense details
    context.read<ExpenseBloc>().add(LoadExpenseDetails(widget.expenseId));
  }

  void _showDeleteConfirmation(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this expense?'),
            const SizedBox(height: 16),
            Text(
              expense.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('\$${expense.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ExpenseBloc>().add(DeleteExpense(widget.expenseId));
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showStatusChangeMenu(ExpenseModel expense) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                ExpenseCategories.getStatusIcon(ExpenseCategories.approved),
                color: ExpenseCategories.getStatusColor(ExpenseCategories.approved),
              ),
              title: const Text('Approve'),
              onTap: () {
                context.read<ExpenseBloc>().add(ApproveExpense(widget.expenseId));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                ExpenseCategories.getStatusIcon(ExpenseCategories.paid),
                color: ExpenseCategories.getStatusColor(ExpenseCategories.paid),
              ),
              title: const Text('Mark as Paid'),
              onTap: () {
                context.read<ExpenseBloc>().add(MarkExpenseAsPaid(widget.expenseId));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                ExpenseCategories.getStatusIcon(ExpenseCategories.rejected),
                color: ExpenseCategories.getStatusColor(ExpenseCategories.rejected),
              ),
              title: const Text('Reject'),
              onTap: () {
                Navigator.pop(context);
                _showRejectDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Expense'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Enter reason...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                context.read<ExpenseBloc>().add(
                      RejectExpense(widget.expenseId, reasonController.text.trim()),
                    );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              if (state is ExpenseDetailsLoaded) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExpenseFormScreen(
                              expense: state.expense,
                              isEdit: true,
                            ),
                          ),
                        );
                        break;
                      case 'delete':
                        _showDeleteConfirmation(state.expense);
                        break;
                      case 'status':
                        _showStatusChangeMenu(state.expense);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'status',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline),
                          SizedBox(width: 8),
                          Text('Change Status'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // No need to reload - the BLoC handles it automatically
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseDetailsLoaded) {
            // Cache the expense for display during operation success states
            _lastLoadedExpense = state.expense;
            return _buildExpenseDetails(state.expense);
          } else if (state is ExpenseOperationSuccess) {
            // Keep showing the last loaded expense while success message displays
            if (_lastLoadedExpense != null) {
              return _buildExpenseDetails(_lastLoadedExpense!);
            }
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ExpenseBloc>().add(LoadExpenseDetails(widget.expenseId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Loading expense details...'));
        },
      ),
    );
  }

  Widget _buildExpenseDetails(ExpenseModel expense) {
    final categoryColor = ExpenseCategories.getCategoryColor(expense.category);
    final statusColor = ExpenseCategories.getStatusColor(expense.status);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: categoryColor, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        ExpenseCategories.getCategoryIcon(expense.category),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ExpenseCategories.getCategoryName(expense.category),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ExpenseCategories.getStatusIcon(expense.status),
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ExpenseCategories.getStatusName(expense.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection(
                  'Basic Information',
                  [
                    _buildDetailRow('Category', ExpenseCategories.getCategoryName(expense.category)),
                    _buildDetailRow('Subcategory', ExpenseCategories.getSubcategoryName(expense.subcategory)),
                    _buildDetailRow('Expense Date', DateFormat('MMMM d, yyyy').format(expense.expenseDate)),
                    _buildDetailRow('Currency', expense.currency),
                  ],
                ),
                const SizedBox(height: 24),

                _buildDetailSection(
                  'Payment Information',
                  [
                    _buildDetailRow('Payment Method', ExpenseCategories.getPaymentMethodName(expense.paymentMethod)),
                    if (expense.vendorName.isNotEmpty)
                      _buildDetailRow('Vendor', expense.vendorName),
                    if (expense.vendorContact.isNotEmpty)
                      _buildDetailRow('Vendor Contact', expense.vendorContact),
                  ],
                ),
                const SizedBox(height: 24),

                if (expense.description.isNotEmpty) ...[
                  _buildDetailSection(
                    'Description',
                    [
                      Text(
                        expense.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                if (expense.tags.isNotEmpty) ...[
                  _buildDetailSection(
                    'Tags',
                    [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: expense.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey[200],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                if (expense.isRecurring) ...[
                  _buildDetailSection(
                    'Recurring Information',
                    [
                      _buildDetailRow(
                        'Frequency',
                        ExpenseCategories.getRecurrencePeriodName(expense.recurrencePeriod ?? ''),
                      ),
                      if (expense.nextRecurrenceDate != null)
                        _buildDetailRow(
                          'Next Occurrence',
                          DateFormat('MMMM d, yyyy').format(expense.nextRecurrenceDate!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                if (expense.notes.isNotEmpty) ...[
                  _buildDetailSection(
                    'Notes',
                    [
                      Text(
                        expense.notes,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                _buildDetailSection(
                  'Audit Trail',
                  [
                    _buildDetailRow('Created', DateFormat('MMM d, yyyy h:mm a').format(expense.createdAt)),
                    _buildDetailRow('Last Updated', DateFormat('MMM d, yyyy h:mm a').format(expense.updatedAt)),
                    if (expense.approvedAt != null)
                      _buildDetailRow('Approved', DateFormat('MMM d, yyyy h:mm a').format(expense.approvedAt!)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
