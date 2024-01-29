// monthly.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';

class MonthlyExpenses extends StatefulWidget {
  final List<dynamic> transactions;

  const MonthlyExpenses({Key? key, required this.transactions}) : super(key: key);

  @override
  _MonthlyExpensesState createState() => _MonthlyExpensesState();
}

class _MonthlyExpensesState extends State<MonthlyExpenses> {
  int? _selectedYear;
  int? _selectedMonth;
  List<dynamic> _transactionDetails = [];
  double? _totalAmount;

  void _calculateMonthlyExpenses() {
    if (_selectedYear == null || _selectedMonth == null) {
      return;
    }

    List<dynamic> transactionDetails = widget.transactions
        .where((transaction) {
          if (transaction is Transaction) {
            return transaction.date.year == _selectedYear &&
                transaction.date.month == _selectedMonth;
          }
          return false;
        })
        .toList();

    double totalAmount =
        transactionDetails.fold(0, (sum, transaction) {
          if (transaction is Transaction) {
            return sum + transaction.amount;
          }
          return sum;
        });

    setState(() {
      _totalAmount = totalAmount;
      _transactionDetails = transactionDetails;
    });
  }

  String _getAmountWithSign(double amount) {
    return (amount >= 0 ? '+' : '') + ' ${amount.abs()}';
  }

  void _clearResult() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _transactionDetails = [];
      _totalAmount = null;
    });
  }

  Future<void> _selectYear(BuildContext context) async {
    int? pickedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Year'),
          children: List.generate(10, (index) {
            int year = DateTime.now().year - 5 + index;
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, year);
              },
              child: Text(year.toString()),
            );
          }),
        );
      },
    );

    if (pickedYear != null) {
      setState(() {
        _selectedYear = pickedYear;
      });
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    if (_selectedYear == null) {
      return;
    }

    int? pickedMonth = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Month'),
          children: List.generate(12, (index) {
            int month = index + 1;
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, month);
              },
              child: Text(DateFormat('MMMM').format(DateTime(_selectedYear!, month))),
            );
          }),
        );
      },
    );

    if (pickedMonth != null) {
      setState(() {
        _selectedMonth = pickedMonth;
      });
    }
  }

  Future<void> _downloadMonthlyDetails() async {
    if (_totalAmount == null || _transactionDetails.isEmpty) {
      // No data to download
      return;
    }
    final monthName = DateFormat('MMMM').format(DateTime(_selectedYear!, _selectedMonth!));

    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    page.graphics.drawString(
        'Monthly Expenses', PdfStandardFont(PdfFontFamily.helvetica, 24));

    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 20),
      cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2),
    );

    grid.columns.add(count: 5);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Serial Number';
    header.cells[1].value = 'Transaction';
    header.cells[2].value = 'Date';
    header.cells[3].value = 'Category';
    header.cells[4].value = 'Amount';

    int serialNumber = 1;
    for (int i = 0; i < _transactionDetails.length; i++) {
      PdfGridRow row = grid.rows.add();

      if (i % 2 == 0) {
        for (int j = 0; j < row.cells.count; j++) {
          row.cells[j].style?.backgroundBrush =
              PdfSolidBrush(PdfColor(135, 206, 250));
        }
      }

      if (_transactionDetails[i] is Transaction) {
        Transaction transaction = _transactionDetails[i] as Transaction;
        row.cells[0].value = serialNumber.toString();
        row.cells[1].value = transaction.title; // Transaction
        row.cells[2].value = DateFormat('yyyy-MM-dd').format(transaction.date); // Date
        row.cells[3].value = transaction.category.toString().split('.')[1].toUpperCase(); // Category
        row.cells[4].value = _getAmountWithSign(transaction.amount); // Amount
      }
      serialNumber++;
    }

    PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[3].value = 'Total:';
    totalRow.cells[4].style = PdfGridCellStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
    );
    totalRow.cells[3].style = PdfGridCellStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
    );
    totalRow.cells[4].value = _getAmountWithSign(_totalAmount!);

    grid.draw(bounds: const Rect.fromLTWH(0, 60, 0, 0), page: page);

    List<int> bytes = await document.save();
    document.dispose();

    final path = (await getExternalStorageDirectory())?.path;
    final fileName = 'Monthly-${monthName}.pdf';
    final file = File("$path/$fileName");
    await file.writeAsBytes(bytes, flush: true);

    OpenFile.open("$path/$fileName");
  }

  @override
  Widget build(BuildContext context) {
    final currencyNotifier =
        Provider.of<CurrencyNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Expenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => _selectYear(context),
                child: const Text('Select Year'),
              ),
              const SizedBox(height: 16.0),
              if (_selectedYear != null)
                ElevatedButton(
                  onPressed: () => _selectMonth(context),
                  child: const Text('Select Month'),
                ),
              const SizedBox(height: 16.0),
              if (_selectedYear != null && _selectedMonth != null)
                Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Year and Month',
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Year: $_selectedYear',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Month: ${DateFormat('MMMM').format(DateTime(_selectedYear!, _selectedMonth!))}',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _calculateMonthlyExpenses,
                          child: const Text('Calculate'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              if (_totalAmount != null)
                SingleChildScrollView(
                  child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Transactions',
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${currencyNotifier.selectedCurrency} $_totalAmount ',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: _downloadMonthlyDetails,
                                alignment: Alignment.bottomLeft,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          if (_transactionDetails.isNotEmpty)
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Transaction Details:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8.0),
                                  for (int i = 0; i < _transactionDetails.length; i++)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _transactionDetails[i].title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ), // Transaction
                                          ),
                                        ),
                                        Text(
                                          DateFormat('yyyy-MM-dd')
                                              .format(_transactionDetails[i].date),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ), // Date

                                        Text(
                                          '${currencyNotifier.selectedCurrency} ${_getAmountWithSign(_transactionDetails[i].amount)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ), // Amount
                                      ],
                                    ),
                                  const SizedBox(height: 8.0),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: _clearResult,
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
