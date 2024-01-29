import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';

class CategorySelection extends StatefulWidget {
  final Function(dynamic) onCategorySelected;
  final List<dynamic> allTransactions;

  const CategorySelection({
    Key? key,
    required this.onCategorySelected,
    required this.allTransactions,
  }) : super(key: key);

  @override
  _CategorySelectionState createState() => _CategorySelectionState();
}

class _CategorySelectionState extends State<CategorySelection> {
  late dynamic _selectedCategory;
  double _totalExpenses = 0.0;
  List<String> _transactionDetails = [];
  bool _isCardVisible = false;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredCategories = [];

  @override
  void initState() {
    _selectedCategory = Category.values[0];
    _calculateTotalExpenses();
    super.initState();
  }

  void _calculateTotalExpenses() {
    _totalExpenses =
        _expensesForCategory(_selectedCategory, TransactionType.Expense);
    _totalExpenses +=
        _expensesForCategory(_selectedCategory, TransactionType.Income);

    _transactionDetails = _getTransactionDetails(
        _selectedCategory, TransactionType.Expense);
    _transactionDetails.addAll(
        _getTransactionDetails(_selectedCategory, TransactionType.Income));
  }

  double _expensesForCategory(Category category, TransactionType type) {
    return widget.allTransactions
        .where((t) => t.category == category && t.type == type)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  List<String> _getTransactionDetails(Category category, TransactionType type) {
    return widget.allTransactions
        .where((t) => t.category == category && t.type == type)
        .map((transaction) =>
            '${transaction.title} : ${transaction.date.toString().split(" ")[0]} : ${_getSelectedCurrency()} ${_getAmountWithSign(transaction.amount, transaction.type)}')
        .toList();
  }

  String _getSelectedCurrency() {
    final currencyNotifier =
        Provider.of<CurrencyNotifier>(context, listen: false);
    return currencyNotifier.selectedCurrency;
  }

  String _getAmountWithSign(double amount, TransactionType type) {
    return (type == TransactionType.Income ? '+' : '-') +
        ' ${amount.abs()}';
  }

  void _showCategories() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
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
              child: ListView.separated(
                itemCount: Category.values.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final category = Category.values[index];
                  final icon = categoryIcons[category] ?? Icons.category;

                  return ListTile(
                    leading: Icon(icon),
                    title: Text(category.toString().split(".")[1]),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _calculateTotalExpenses();
                        _isCardVisible = true;
                      });
                      Navigator.pop(context); // Close modal sheet
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    ).then((value) {
      widget.onCategorySelected(_selectedCategory);
    });
  }

  void _hideCard() {
    setState(() {
      _isCardVisible = false;
    });
  }

  Future<void> _downloadCategoryDetails() async {
    if (_transactionDetails.isEmpty) {
      return;
    }

    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    page.graphics.drawString(
        'Category Expenses', PdfStandardFont(PdfFontFamily.helvetica, 24));

    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 20),
      cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2),
    );

    grid.columns.add(count: 3);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Transaction';
    header.cells[1].value = 'Date';
    header.cells[2].value = 'Amount';

    int serialNumber = 1;
    for (int i = 0; i < _transactionDetails.length; i++) {
      List<String> detailParts = _transactionDetails[i].split(":");
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = detailParts[0].trim(); // Transaction
      row.cells[1].value = detailParts[1].trim(); // Date
      row.cells[2].value = detailParts[2].trim(); // Amount
      serialNumber++;
    }

    PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[1].value = 'Total:';
    totalRow.cells[2].style = PdfGridCellStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 20,
          style: PdfFontStyle.bold),
    );
    totalRow.cells[1].style = PdfGridCellStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 20,
          style: PdfFontStyle.bold),
    );
    totalRow.cells[2].value = _totalExpenses.toString();

    grid.draw(bounds: const Rect.fromLTWH(0, 60, 0, 0), page: page);

    List<int> bytes = await document.save();
    document.dispose();

    final path = (await getExternalStorageDirectory())?.path;
    final fileName =
        'Category_${_selectedCategory.toString().split(".")[1]}.pdf';
    final file = File("$path/$fileName");
    await file.writeAsBytes(bytes, flush: true);

    OpenFile.open("$path/$fileName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showCategories,
            child: const Text('Select Category'),
          ),
          if (_isCardVisible)
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Selected Category: ${_selectedCategory.toString().split(".")[1]}'),
                    const SizedBox(height: 16.0),
                    Text('Total Expenses: $_totalExpenses'),
                    const SizedBox(height: 8.0),
                    Text(
                      'Transaction Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    for (String detail in _transactionDetails)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              detail.split(":")[0],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            detail.split(":")[1],
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Text(
                            detail.split(":")[2],
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _hideCard,
                          child: const Text('Close'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: _downloadCategoryDetails,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
