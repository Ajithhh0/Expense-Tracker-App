// currency_notifier.dart

import 'package:flutter/material.dart';

class CurrencyNotifier extends ChangeNotifier {
  String _selectedCurrency = 'USD';

  String get selectedCurrency => _selectedCurrency;

  set selectedCurrency(String value) {
    _selectedCurrency = value;
    notifyListeners();
  }
}
