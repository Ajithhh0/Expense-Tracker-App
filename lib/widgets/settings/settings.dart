import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:expense_tracker/theme/theme_provider.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart'; // Import the CurrencyNotifier

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Map<String, dynamic>> currencies = [];
  String? selectedCurrency;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/currencies.json');
      final dynamic jsonData = json.decode(jsonString);

      if (jsonData is List) {
        setState(() {
          currencies = List<Map<String, dynamic>>.from(jsonData);
          selectedCurrency = currencies.isNotEmpty ? currencies[0]['code'].toString() : null;
        });
      } else {
        print("Error: JSON data is not a List");
      }
    } catch (e) {
      print("Error decoding JSON: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Theme:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeProvider.getThemeMode() == ThemeMode.dark,
              onChanged: (bool value) {
                themeProvider.toggleTheme();
              },
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Select Currency:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            DropdownButton<String>(
              value: selectedCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCurrency = newValue;
                });
                currencyNotifier.selectedCurrency = newValue ?? 'QR'; // Default to 'QR' if null
              },
              items: currencies.map<DropdownMenuItem<String>>((Map<String, dynamic> currency) {
                return DropdownMenuItem<String>(
                  value: currency['code'].toString(),
                  child: Text(currency['name'].toString()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
