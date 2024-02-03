
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    Key? key,
    required this.transactions,
    required this.onRemoveTransaction,
    required this.onEditTransaction,
  }) : super(key: key);

  final List<Transaction> transactions;
  final void Function(Transaction transaction) onRemoveTransaction;
  final void Function(Transaction oldTransaction, Transaction newTransaction)
      onEditTransaction;

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    final margin = cardTheme.margin?.horizontal ?? 0;

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(transactions[index]),
        background: Container(
          color: Colors.red,
          margin: EdgeInsets.symmetric(horizontal: margin),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ),
        onDismissed: (direction) {
          onRemoveTransaction(transactions[index]);
        },
        child: GestureDetector(
          onLongPress: () {
            _showContextMenu(context, transactions[index]);
          },
          child: TransactionItem(
            transaction: transactions[index],
            onRemoveTransaction: onRemoveTransaction,
            isCredit: true,
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Transaction transaction) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);

                // Navigate to the edit screen and wait for the result
                Transaction? updatedTransaction =
                    await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewExpense(
                      onAddTransaction: (newTransaction) {
                      // Implement your logic to add the edited transaction
                    },
                    onEditTransaction: (oldTransaction, newTransaction) {
                      // Update the transaction in the list
                      onEditTransaction(oldTransaction, newTransaction);
                    },
                      transactionToEdit: transaction,
                    ),
                  ),
                );

                // If the user made changes, update the transaction
                if (updatedTransaction != null) {
                  onEditTransaction(transaction, updatedTransaction);
                }
              },
              child: Text('Edit'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        );
      },
    );
  }
}
