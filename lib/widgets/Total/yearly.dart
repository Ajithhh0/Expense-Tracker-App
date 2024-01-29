// yearly.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart'; // Import the Transaction model
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';

class YearlyExpenses extends StatefulWidget {
  final List<dynamic> transactions;

  const YearlyExpenses({Key? key, required this.transactions}) : super(key: key);

  @override
  _YearlyExpensesState createState() => _YearlyExpensesState();
}

class _YearlyExpensesState extends State<YearlyExpenses> {
  int? _selectedYear;
  double? _totalAmount;
  List<String> _transactionDetails = [];
  bool _showResults = false;

  void _calculateYearlyTransactions() {
    if (_selectedYear == null) {
      return;
    }

    double totalAmount = 0.0;
    List<String> transactionDetails = [];

    for (dynamic transaction in widget.transactions) {
      if (transaction is Transaction && transaction.date.year == _selectedYear) {
        totalAmount += transaction.amount;
        transactionDetails.add(
          '${transaction.title} : ${transaction.date.toString().split(" ")[0]} : ${transaction.category} : ${_getSelectedCurrency()} ${transaction.amount}',
        );
      }
    }

    setState(() {
      _totalAmount = totalAmount;
      _transactionDetails = transactionDetails;
      _showResults = true;
    });
  }

  String _getSelectedCurrency() {
    final currencyNotifier =
        Provider.of<CurrencyNotifier>(context, listen: false);
    return currencyNotifier.selectedCurrency;
  }

 String _getAmountWithSign(double amount) {
    return (amount >= 0 ? '+' : '-') + ' ${amount.abs()}';
  }



  void _clearResult() {
    setState(() {
      _selectedYear = null;
      _totalAmount = null;
      _transactionDetails = [];
      _showResults = false;
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

  Future<void> _downloadYearlyDetails() async {
    if (_totalAmount == null || _transactionDetails.isEmpty) {
      // No data to download
      return;
    }

    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    page.graphics.drawString(
        'Yearly Transactions', PdfStandardFont(PdfFontFamily.helvetica, 24));

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
         row.cells[4].value = detailParts[3].trim();
      } else {
        row.cells[3].value = ''; // Empty for Income
        row.cells[4].value = _getAmountWithSign(double.parse(detailParts[2].trim())); // Amount
      }
      serialNumber++;

      // Alternating sky-blue background color
      if (i % 2 == 0) {
        for (int j = 0; j < row.cells.count; j++) {
          row.cells[j].style?.backgroundBrush =
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
    final fileName = 'Yearly_${_selectedYear}.pdf';
    final file = File("$path/$fileName");
    await file.writeAsBytes(bytes, flush: true);

    OpenFile.open("$path/$fileName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yearly Transactions'),
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
                Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Year',
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Year: $_selectedYear',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _calculateYearlyTransactions,
                          child: const Text('Calculate'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              if (_showResults && _totalAmount != null)
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
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: _downloadYearlyDetails,
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
                                            _transactionDetails[i].split(":")[0],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ), // Transaction
                                          ),
                                        ),
                                        Text(
                                          _transactionDetails[i].split(":")[1],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ), // Date
                                        
                                        if (_transactionDetails[i].split(":").length > 3)
                                          Text(
                                            _transactionDetails[i].split(":")[3],
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
