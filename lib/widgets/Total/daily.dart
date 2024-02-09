// daily.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';


class DailyExpenses extends StatefulWidget {
  final List<dynamic> transactions;

  const DailyExpenses({Key? key, required this.transactions}) : super(key: key);

  @override
  _DailyExpensesState createState() => _DailyExpensesState();
}

class _DailyExpensesState extends State<DailyExpenses> {
  DateTime? _selectedDate;
  double? _totalAmount;
  List<String> _transactionDetails = [];

  void _calculateDailyExpenses() {
  if (_selectedDate == null) {
    return;
  }

  double totalAmount = 0.0;
  List<String> transactionDetails = [];

  for (dynamic transaction in widget.transactions) {
    print('Transaction: $transaction');
    if (transaction is Transaction &&
        transaction.date.year == _selectedDate!.year &&
        transaction.date.month == _selectedDate!.month &&
        transaction.date.day == _selectedDate!.day) {
      totalAmount += transaction.amount;
      transactionDetails.add(
        '${transaction.title} : ${transaction.date.toString().split(" ")[0]} : ${transaction.category} : ${_getSelectedCurrency()} ${_getAmountWithSign(transaction.amount)}',
      );
    }
  }

  print('Total Amount: $totalAmount');
  print('Transaction Details: $transactionDetails');

  setState(() {
    _totalAmount = totalAmount;
    _transactionDetails = transactionDetails;
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

  void _clearResult() {
    setState(() {
      _selectedDate = null;
      _totalAmount = null;
      _transactionDetails = [];
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _downloadDailyDetails() async {
    if (_totalAmount == null || _transactionDetails.isEmpty) {
      return;
    }

    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    page.graphics.drawString(
        'Daily Expenses', PdfStandardFont(PdfFontFamily.helvetica, 24));

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
      if (detailParts.length >= 3) {
        String category = detailParts[2].trim().replaceAll('Category.', '');
        if (detailParts.length > 3) {
          row.cells[3].value = category.toUpperCase();
          row.cells[4].value = detailParts[3].trim(); // Amount
        } else {
          row.cells[3].value = category.toUpperCase(); // Category
          row.cells[4].value = detailParts[2].trim(); // Amount
        }
      }

      serialNumber++;

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
      font: PdfStandardFont(PdfFontFamily.helvetica, 20,
          style: PdfFontStyle.bold),
    );
    totalRow.cells[3].style = PdfGridCellStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 20,
          style: PdfFontStyle.bold),
    );
    totalRow.cells[4].value = _totalAmount.toString();

    grid.draw(bounds: const Rect.fromLTWH(0, 60, 0, 0), page: page);

    List<int> bytes = await document.save();
    document.dispose();

    final path = (await getExternalStorageDirectory())?.path;
    final fileName = 'Daily_${_selectedDate.toString().split(" ")[0]}.pdf';
    final file = File("$path/$fileName");
    await file.writeAsBytes(bytes, flush: true);

    OpenFile.open("$path/$fileName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expenses'),
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
                        'Select Date:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Transaction Date:'),
                                const SizedBox(height: 8.0),
                                TextButton(
                                  onPressed: () => _selectDate(context),
                                  child: Text(
                                    _selectedDate == null
                                        ? 'Pick Date'
                                        : _selectedDate!
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
                        onPressed: _calculateDailyExpenses,
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
                                '${_getSelectedCurrency()} $_totalAmount ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: _downloadDailyDetails,
                                alignment: Alignment.bottomLeft,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          if (_transactionDetails.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Transaction')),
                                  DataColumn(label: Text('Date')),
                                  //DataColumn(label: Text('Category')),
                                  DataColumn(label: Text('Amount')),
                                ],
                                rows: List<DataRow>.generate(
                                  _transactionDetails.length,
                                  (index) {
                                    List<String> detailParts =
                                        _transactionDetails[index].split(":");
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(detailParts[0]
                                              .trim()), // Transaction
                                        ),
                                        DataCell(
                                          Text(detailParts[1].trim()), // Date
                                        ),
                                        // DataCell(
                                        //   Text(detailParts[2].trim()), // Category
                                        // ),
                                        //Text(transaction.category.toString().split('.')[1].toUpperCase()),
                                        DataCell(
                                          Text(detailParts[3].trim()), // Amount
                                        ),
                                      ],
                                    );
                                  },
                                ),
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
