// main_tab.dart

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/main_tab/pie.dart';

class MainTab extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onTransactionAdded;

  const MainTab({super.key, 
    required this.transactions,
    required this.onTransactionAdded,
  });

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab>
    with AutomaticKeepAliveClientMixin {
  double incomeAmount = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: PageStorage(
        bucket: PageStorageBucket(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 5.0,
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Expense Distribution',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: 300.0,
                      height: 200.0,
                      child: PieChart(
                        dataMap: _getDataMap(),
                        chartType: ChartType.disc,
                        animationDuration: const Duration(seconds: 5),
                        chartRadius: MediaQuery.of(context).size.width / 2,
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValueBackground: false,
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: true,
                          showChartValues: true,
                        ),
                        legendOptions: const LegendOptions(
                          showLegends: false,
                          legendTextStyle: TextStyle(fontSize: 12),
                          legendPosition: LegendPosition.bottom,
                          showLegendsInRow: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () => _showLegendDialog(context),
                      child: const Text('Legend'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _getDataMap() {
    Map<String, double> dataMap = {};

    for (Category category in Category.values) {
      double totalAmountForCategory = _amountForCategory(category);
      dataMap[_buildCategoryName(category.toString().split('.').last)] =
          totalAmountForCategory;
    }

    return dataMap;
  }

  String _buildCategoryName(String categoryName) {
    return categoryName.toUpperCase();
  }

  double _amountForCategory(Category category) {
  return widget.transactions
      .where((transaction) => transaction.category == category)
      .fold(0.0, (double sum, Transaction transaction) {
        if (transaction.type == TransactionType.Expense) {
          return sum - transaction.amount;
        } else if (transaction.type == TransactionType.Income) {
          return sum + transaction.amount;
        } else {
          return sum;
        }
      });
}


  void _showLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Legend'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (Category category in Category.values)
                  Row(
                    children: [
                      Container(
                        width: 12.0,
                        height: 12.0,
                        color: PieChartUtils.getCategoryColor(category),
                      ),
                      const SizedBox(width: 4.0),
                      Text(_buildCategoryName(
                          category.toString().split('.').last)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
