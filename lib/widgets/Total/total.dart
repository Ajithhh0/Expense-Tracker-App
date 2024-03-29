import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart' as ExpenseModel;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';
import 'package:expense_tracker/database/db_helper.dart';

class TotalExpenses extends StatefulWidget {
  final List<dynamic> transactions;

  const TotalExpenses({Key? key, required this.transactions}) : super(key: key);

  @override
  _TotalExpensesState createState() => _TotalExpensesState();
}

class _TotalExpensesState extends State<TotalExpenses> {
  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalAmount;
  List<String> _transactionDetails = [];

  void _calculateTotal() async {
    if (_startDate == null || _endDate == null) {
      return;
    }

    print('Start Date: $_startDate');
    print('End Date: $_endDate');

    double totalAmount = 0.0;
    List<String> transactionDetails = [];

    // Fetch transactions from the database
    List<ExpenseModel.Transaction> transactions = await DbHelper.instance.getAllTransactions();

    // Debug: Print out the dates of transactions
    for (ExpenseModel.Transaction transaction in transactions) {
      print('Transaction Date: ${transaction.date}');
    }

    // Filter transactions based on the date range
    for (ExpenseModel.Transaction transaction in transactions) {
      // Adjusted date comparison logic
      if (transaction.date.isAtSameMomentAs(_startDate!) ||
          transaction.date.isAtSameMomentAs(_endDate!) ||
          (transaction.date.isAfter(_startDate!) &&
              transaction.date.isBefore(_endDate!)) ||
          (transaction.date.isAtSameMomentAs(_startDate!) &&
              transaction.date.isAtSameMomentAs(_endDate!))) {
        totalAmount += transaction.amount;
        transactionDetails.add(
          '${transaction.title} : ${transaction.date.toString().split(" ")[0]} : ${transaction.category} : ${_getSelectedCurrency()} ${_getAmountWithSign(transaction.amount)}',
        );
      }
    }

    setState(() {
      _totalAmount = totalAmount;
      _transactionDetails = transactionDetails;
    });
  }

  void _clearResult() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _totalAmount = null;
      _transactionDetails = [];
    });
  }

  String _getAmountWithSign(double amount) {
    return '${amount >= 0 ? '+' : '-'} ${amount.abs()}';
  }

  String _getSelectedCurrency() {
    final currencyNotifier =
        Provider.of<CurrencyNotifier>(context, listen: false);
    return currencyNotifier.selectedCurrency;
  }

  Future<void> _downloadTotalDetails() async {
    if (_totalAmount != null && _transactionDetails.isNotEmpty) {
      // No data to download
      return;
    }

    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    page.graphics.drawString(
        'Total Expenses', PdfStandardFont(PdfFontFamily.helvetica, 24));

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
      List<String> detailParts = _transactionDetails[i].split(":");
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = serialNumber.toString();
      row.cells[1].value = detailParts[0].trim(); // Transaction
      row.cells[2].value = detailParts[1].trim(); // Date
      if (detailParts.length > 3) {
        String category =
            detailParts[2].trim().replaceAll('Category.', '');
        row.cells[3].value = category.toUpperCase();
        row.cells[4].value = detailParts[3].trim(); // Amount
      }
      serialNumber++;

      // Alternating sky-blue background color
      if (i % 2 == 0) {
        for (int j = 0; j < row.cells.count; j++) {
          row.cells[j].style.backgroundBrush =
              PdfSolidBrush(PdfColor(135, 206, 250));
        }
      }
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
    final fileName = 'Total_${_startDate.toString().split(" ")[0]}_to_${_endDate.toString().split(" ")[0]}.pdf';
    final file = File("$path/$fileName");
    await file.writeAsBytes(bytes, flush: true);

    OpenFile.open("$path/$fileName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Expenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date Range:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('From Date:'),
                                const SizedBox(height: 8.0),
                                TextButton(
                                  onPressed: () async {
                                    final DateTime? pickedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _startDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );

                                    if (pickedDate != null &&
                                        pickedDate != _startDate) {
                                      setState(() {
                                        _startDate = pickedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                    _startDate == null
                                        ? 'Pick Date'
                                        : _startDate!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('To Date:'),
                                const SizedBox(height: 8.0),
                                TextButton(
                                  onPressed: () async {
                                    final DateTime? pickedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _endDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );

                                    if (pickedDate != null &&
                                        pickedDate != _endDate) {
                                      setState(() {
                                        _endDate = pickedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                    _endDate == null
                                        ? 'Pick Date'
                                        : _endDate!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _calculateTotal,
                        child: const Text('Calculate'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              if (_totalAmount != null && _transactionDetails.isNotEmpty)
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
                                '${_getSelectedCurrency()} $_totalAmount ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: _downloadTotalDetails,
                                alignment: Alignment.bottomLeft,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Transaction Details:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8.0),
                                DataTable(
                                  columnSpacing: 20.0,
                                  columns: [
                                    DataColumn(
                                      label: Text(
                                        'Transaction',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Date',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Amount',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  rows: List.generate(
                                    _transactionDetails.length,
                                    (index) {
                                      List<String> details = _transactionDetails[index].split(':');
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(details[0].trim()),
                                          ),
                                          DataCell(
                                            Text(details[1].trim()),
                                          ),
                                          DataCell(
                                            Text(details.length > 3
                                                ? details[3].trim()
                                                : _getAmountWithSign(double.parse(details[2].trim()))),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
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
                                child: const Text('Cancel'),
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
