import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/expense/expense_bloc.dart';
import '../bloc/expense/expense_event.dart';
import '../bloc/expense/expense_state.dart';
import '../models/expense_model.dart';
import '../components/constant/expense_categories.dart';
import '../components/custom_app_bar.dart';
import 'expense_form_screen.dart';
import 'expense_detail_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Load initial expenses
    context.read<ExpenseBloc>().add(LoadExpenses());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<ExpenseBloc>().add(
          FilterExpenses(
            category: _selectedCategory,
            status: _selectedStatus,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
    context.read<ExpenseBloc>().add(LoadExpenses());
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filter Expenses'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('All Categories'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...ExpenseCategories.getAllCategories().map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(ExpenseCategories.getCategoryName(category)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status filter
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('All Statuses'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Statuses')),
                      ...ExpenseCategories.getAllStatuses().map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(ExpenseCategories.getStatusName(status)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date range
                  const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                _startDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _startDate != null
                                ? DateFormat('MMM d, y').format(_startDate!)
                                : 'Start Date',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: _startDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                _endDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _endDate != null
                                ? DateFormat('MMM d, y').format(_endDate!)
                                : 'End Date',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setDialogState(() {
                    _selectedCategory = null;
                    _selectedStatus = null;
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                  _applyFilters();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Expense Management'),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search expenses...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<ExpenseBloc>().add(LoadExpenses());
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            context.read<ExpenseBloc>().add(SearchExpenses(value));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Badge(
                        isLabelVisible: _selectedCategory != null ||
                            _selectedStatus != null ||
                            _startDate != null ||
                            _endDate != null,
                        child: const Icon(Icons.filter_list),
                      ),
                      onPressed: _showFilterDialog,
                      tooltip: 'Filter',
                    ),
                  ],
                ),
                if (_selectedCategory != null ||
                    _selectedStatus != null ||
                    _startDate != null ||
                    _endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: [
                              if (_selectedCategory != null)
                                Chip(
                                  label: Text(ExpenseCategories.getCategoryName(_selectedCategory!)),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedCategory = null;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              if (_selectedStatus != null)
                                Chip(
                                  label: Text(ExpenseCategories.getStatusName(_selectedStatus!)),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedStatus = null;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              if (_startDate != null || _endDate != null)
                                Chip(
                                  label: Text(
                                    '${_startDate != null ? DateFormat('MMM d').format(_startDate!) : ''} - ${_endDate != null ? DateFormat('MMM d').format(_endDate!) : ''}',
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _startDate = null;
                                      _endDate = null;
                                    });
                                    _applyFilters();
                                  },
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Expense list
          Expanded(
            child: BlocConsumer<ExpenseBloc, ExpenseState>(
              listener: (context, state) {
                if (state is ExpenseError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is ExpenseOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload expenses after operation
                  context.read<ExpenseBloc>().add(LoadExpenses());
                }
              },
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ExpensesLoaded || state is ExpenseSearchResults) {
                  final expenses = state is ExpensesLoaded
                      ? state.expenses
                      : (state as ExpenseSearchResults).results;

                  if (expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first expense to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ExpenseBloc>().add(LoadExpenses());
                    },
                    child: ListView.builder(
                      itemCount: expenses.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        return _ExpenseCard(
                          expense: expenses[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpenseDetailScreen(
                                  expenseId: expenses[index].expenseId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const Center(child: Text('Start by loading expenses'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExpenseFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;

  const _ExpenseCard({
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = ExpenseCategories.getCategoryColor(expense.category);
    final statusColor = ExpenseCategories.getStatusColor(expense.status);
    final categoryIcon = ExpenseCategories.getCategoryIcon(expense.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Expense details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            expense.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ExpenseCategories.getCategoryName(expense.category),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (expense.vendorName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.store, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            expense.vendorName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            ExpenseCategories.getStatusName(expense.status),
                            style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(expense.expenseDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (expense.isRecurring) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.repeat, size: 12, color: Colors.grey[600]),
                        ],
                        if (expense.receiptUrls.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.attach_file, size: 12, color: Colors.grey[600]),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
