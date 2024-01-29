import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    Key? key,
    required this.transaction,
    required this.onRemoveTransaction,
    required this.isCredit,
  }) : super(key: key);

  final Transaction transaction;
  final void Function(Transaction transaction) onRemoveTransaction;
  final bool isCredit;

  Widget _buildTransactionCard(
    BuildContext context,
    String title,
    double amount,
    IconData? icon,
    Color cardColor,
    Color textColor,
    bool isCredit,
  ) {
    final selectedCurrency =
        Provider.of<CurrencyNotifier>(context).selectedCurrency;

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon
            if (icon != null)
              Column(
                children: [
                  Icon(
                    icon,
                    color: textColor,
                    size: 48.0,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            const SizedBox(width: 16),
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Title
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Amount and Date Row
                  Row(
                    children: [
                      Text(
                        '${isCredit ? '+' : '-'} $selectedCurrency ${amount.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                        ),
                      ),
                      const Spacer(),
                      if (icon != null)
                        Text(
                          transaction.formattedDate,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.0,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (transaction.type == TransactionType.Income)
          _buildTransactionCard(
            context,
            '${transaction.title}',
            transaction.amount,
            categoryIcons[transaction.category]!,
            Colors.green,
            Colors.white,
            true,
          ),
        if (transaction.type == TransactionType.Expense)
          _buildTransactionCard(
            context,
            '${transaction.title}',
            transaction.amount,
            categoryIcons[transaction.category],
            Color.fromARGB(255, 243, 101, 101),
            Colors.white,
            false,
          ),
      ],
    );
  }
}
