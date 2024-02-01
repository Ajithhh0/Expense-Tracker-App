
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/main_tab/pie.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart'; 

class MainTab extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onTransactionAdded;

  const MainTab({
    Key? key,
    required this.transactions,
    required this.onTransactionAdded,
  }) : super(key: key);

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);

    return SingleChildScrollView(
      child: PageStorage(
        bucket: PageStorageBucket(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Card(
              elevation: 5.0,
              margin: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromARGB(255, 252, 252, 252),Color.fromARGB(255, 248, 248, 248),],
                  ),
                  borderRadius : BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(50.0), 
                  child: Column(
                    children: [
                      const Text(
                        'Total Income',
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 97, 137, 51)),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        '${_calculateTotalIncome(currencyNotifier)}', 
                        style: TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 97, 137, 51)),
                      ),
                    ],
                  ),
                ),
              
              ),
            ),
            
            Card(
              elevation: 5.0,
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Expense Distribution',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: 300.0,
                      height: 200.0,
                      child: PieChart(
                        legendOptions: LegendOptions(
                          showLegends: false,
                        ),
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

            // Total Income Card with Gradient Theme
            
          ],
        ),
      ),
    );
  }

  Map<String, double> _getDataMap() {
    Map<String, double> dataMap = {};

    for (Category category in Category.values) {
      double totalAmountForCategory = _amountForCategory(category);
      dataMap[_buildCategoryName(category.toString().split('.').last)] = totalAmountForCategory;
    }

    return dataMap;
  }

  String _buildCategoryName(String categoryName) {
    return categoryName.toUpperCase();
  }

  double _amountForCategory(Category category) {
    return widget.transactions
        .where((transaction) => transaction.category == category && transaction.type == TransactionType.Expense)
        .fold(0.0, (double sum, Transaction transaction) {
          return sum - transaction.amount;
        });
  }

  String _calculateTotalIncome(CurrencyNotifier currencyNotifier) {
    // Calculate the total income from transactions
    double totalIncome = widget.transactions
        .where((transaction) => transaction.type == TransactionType.Income)
        .fold(0.0, (double sum, Transaction transaction) {
          return sum + transaction.amount;
        });

    return '${currencyNotifier.selectedCurrency} ${totalIncome.toStringAsFixed(2)}';
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
                      Text(_buildCategoryName(category.toString().split('.').last)),
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
