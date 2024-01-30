// expenses.dart
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/Total/total.dart';
import 'package:expense_tracker/widgets/settings/settings.dart';
import 'package:expense_tracker/widgets/Total/daily.dart';
import 'package:expense_tracker/widgets/Total/monthly.dart';
import 'package:expense_tracker/widgets/Total/yearly.dart';
import 'package:expense_tracker/widgets/Total/category.dart';
import 'package:expense_tracker/main_tab/main_tab.dart';

class Expenses extends StatefulWidget {
  final Function(_ExpensesState)? onExpensesStateChange;
  final Function(Transaction) onTransactionAdded;
  final double initialIncome;
  final Function(double) onUpdateCurrentIncome;

  const Expenses({
    Key? key,
    this.onExpensesStateChange,
    required this.onTransactionAdded,
    required List<Transaction> transactions,
    required this.initialIncome,
    required this.onUpdateCurrentIncome,
  }) : super(key: key);

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> with TickerProviderStateMixin {
  final List<Transaction> _registeredTransactions = [];
  List<Transaction> _displayedTransactions = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController;
  double currentIncome = 0.0;

  void _openAddTransactionOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddTransaction: _addTransaction,
      ),
    );
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      _registeredTransactions.add(transaction);
      _displayedTransactions = _registeredTransactions
          .where((transaction) => transaction.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });

    widget.onTransactionAdded(transaction);
    currentIncome -= transaction.amount;

    widget.onUpdateCurrentIncome(currentIncome);

    _notifyStateChange();
  }

  void _removeTransaction(Transaction transaction) {
    setState(() {
      _registeredTransactions.remove(transaction);
      _displayedTransactions = _registeredTransactions
          .where((transaction) => transaction.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: const Text('Transaction Deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredTransactions.add(transaction);
              _displayedTransactions = _registeredTransactions
                  .where((transaction) => transaction.title
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .toList();
            });

            widget.onTransactionAdded(transaction);
            currentIncome += transaction.amount;

            widget.onUpdateCurrentIncome(currentIncome);
            _notifyStateChange();
          },
        ),
      ),
    );
  }

  void _navigateToTotalTransactions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TotalExpenses(transactions: _registeredTransactions),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _notifyStateChange() {
    widget.onExpensesStateChange?.call(this);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 7);
    _displayedTransactions = List.from(_registeredTransactions);
    currentIncome = widget.initialIncome;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search Transactions',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _displayedTransactions = _registeredTransactions
                        .where((transaction) => transaction.title
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              )
            : const Text('Expense Tracker'),
        actions: [
          if (!_isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              icon: const Icon(Icons.search),
            ),
          if (_isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _displayedTransactions = List.from(_registeredTransactions);
                });
              },
              icon: const Icon(Icons.close),
            ),
          IconButton(
            onPressed: _openAddTransactionOverlay,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _navigateToSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
        bottom: _isSearching
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: TabBar(
                    controller: _tabController!,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Main'),
                      Tab(text: 'Transactions'),
                      Tab(text: 'Daily'),
                      Tab(text: 'Monthly'),
                      Tab(text: 'Yearly'),
                      Tab(text: 'Category'),
                      Tab(text: 'Total'),
                    ],
                  ),
                ),
              ),
      ),
      body: _isSearching
          ? width < 600
              ? ExpensesList(
                  transactions: _displayedTransactions,
                  onRemoveTransaction: _removeTransaction,
                )
              : Row(
                  children: [
                    Expanded(
                      child: ExpensesList(
                        transactions: _displayedTransactions,
                        onRemoveTransaction: _removeTransaction,
                      ),
                    ),
                  ],
                )
          : TabBarView(
              controller: _tabController,
              children: [
                MainTab(
                  transactions: _registeredTransactions,
                  onTransactionAdded: (amount) {
                    currentIncome -= amount as double;
                  },
                ),
                ExpensesList(
                  transactions: _registeredTransactions,
                  onRemoveTransaction: _removeTransaction,
                ),
                DailyExpenses(transactions: _registeredTransactions),
                MonthlyExpenses(transactions: _registeredTransactions),
                YearlyExpenses(transactions: _registeredTransactions),
                CategorySelection(
                  onCategorySelected: (selectedCategory) {
                    double totalExpenses =
                        _expensesForCategory(selectedCategory);
                    _showTotalExpensesSnackBar(
                        selectedCategory, totalExpenses);
                  },
                  allTransactions: _registeredTransactions,
                ),
                TotalExpenses(transactions: _registeredTransactions),
              ],
            ),
    );
  }

  double _expensesForCategory(Category category) {
    return _registeredTransactions
        .where((transaction) => transaction.category == category)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  void _showTotalExpensesSnackBar(
      Category selectedCategory, double totalExpenses) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Total Expenses for ${selectedCategory.toString().split('.').last}: $totalExpenses'),
      ),
    );
  }
}
