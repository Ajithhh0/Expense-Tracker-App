// new_expense.dart

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({Key? key, required this.onAddTransaction})
      : super(key: key);

  final void Function(Transaction transaction) onAddTransaction;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  List<Category> filteredCategories = List.from(Category.values);
  bool _isCredit = false;

  void _selectCategory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Categories',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    filteredCategories = Category.values
                        .where((category) => category
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return ListTile(
                    title:
                        Text(category.toString().split('.').last.toUpperCase()),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
            'Please make sure a valid title, amount, date, and category were entered.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
            'Please make sure a valid title, amount, date, and category were entered.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    }
  }

  void _submitTransactionData(String selectedCurrency) {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null ||
        _selectedCategory == null) {
      _showDialog();
      return;
    }

    final amount = _isCredit ? enteredAmount : -enteredAmount;

    final newTransaction = Transaction(
      title: _titleController.text,
      amount: amount,
      date: _selectedDate!,
      category: _selectedCategory!,
      type: _isCredit ? TransactionType.Income : TransactionType.Expense,
      id: '',
    );

    widget.onAddTransaction(newTransaction);

    setState(() {
      _titleController.clear();
      _amountController.clear();
      _selectedDate = null;
      _selectedCategory = null;
      _isCredit = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyNotifier>(
      builder: (context, currencyNotifier, child) {
        final selectedCurrency = currencyNotifier.selectedCurrency;
        final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
        final screenHeight = MediaQuery.of(context).size.height;

        return LayoutBuilder(builder: (ctx, constraints) {
          final width = constraints.maxWidth;
          final double adaptivePadding =
              screenHeight > 600 ? screenHeight * 0.02 : 16;

          return SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  adaptivePadding,
                  adaptivePadding,
                  adaptivePadding,
                  keyboardSpace + adaptivePadding,
                ),
                child: Column(
                  children: [
                    if (width >= 600)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              maxLength: 50,
                              decoration: const InputDecoration(
                                label: Text('Title'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      prefixText: '$selectedCurrency ',
                                      label: const Text('Amount'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedDate == null
                                            ? 'No date selected'
                                            : formatter.format(_selectedDate!),
                                      ),
                                      IconButton(
                                        onPressed: _presentDatePicker,
                                        icon: const Icon(
                                          Icons.calendar_month,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectCategory(context),
                            child: const Text('Category'),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              label: Text('Title'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixText: '$selectedCurrency ',
                                    label: const Text('Amount'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _selectedDate == null
                                          ? 'No date selected'
                                          : formatter.format(_selectedDate!),
                                    ),
                                    IconButton(
                                      onPressed: _presentDatePicker,
                                      icon: const Icon(
                                        Icons.calendar_month,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _selectedCategory == null
                                    ? 'No category selected'
                                    : _selectedCategory!.name
                                        .replaceAll('_', ' ')
                                        .toUpperCase(),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () => _selectCategory(context),
                                child: const Text('Category'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Transaction Type:'),
                        const SizedBox(width: 8),
                        DropdownButton<bool>(
                          value: _isCredit,
                          onChanged: (value) {
                            setState(() {
                              _isCredit = value!;
                            });
                          },
                          items: const [
                            DropdownMenuItem<bool>(
                              value: false,
                              child: Text('Expense'),
                            ),
                            DropdownMenuItem<bool>(
                              value: true,
                              child: Text('Income'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (width >= 600)
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                _submitTransactionData(selectedCurrency),
                            child: const Text('Save Transaction'),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _submitTransactionData(selectedCurrency),
                            child: const Text('Save Transaction'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}