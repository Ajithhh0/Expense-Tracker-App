import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    Key? key,
    required this.transactions,
    required this.onRemoveTransaction,
  }) : super(key: key);

  final List<Transaction> transactions;
  final void Function(Transaction transaction) onRemoveTransaction;

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    final margin = cardTheme?.margin?.horizontal ?? 0;

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(transactions[index]),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: margin),
        ),
        onDismissed: (direction) {
          onRemoveTransaction(transactions[index]);
        },
        child: TransactionItem(
          transaction: transactions[index],
          onRemoveTransaction: onRemoveTransaction,
          isCredit: true,
        ),
      ),
    );
  }
}
