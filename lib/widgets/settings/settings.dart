import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:expense_tracker/theme/theme_provider.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Map<String, dynamic>> currencies = [];
  String? selectedCurrency;
  String searchFilter = '';

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/currencies.json');
      final dynamic jsonData = json.decode(jsonString);

      if (jsonData is List) {
        setState(() {
          currencies = List<Map<String, dynamic>>.from(jsonData);
          selectedCurrency =
              currencies.isNotEmpty ? currencies[0]['code'].toString() : null;
        });
      } else {
        print("Error: JSON data is not a List");
      }
    } catch (e) {
      print("Error decoding JSON: $e");
    }
  }

  List<Map<String, dynamic>> getFilteredCurrencies() {
    return currencies
        .where((currency) =>
            currency['code']
                .toString()
                .toLowerCase()
                .contains(searchFilter.toLowerCase()) ||
            currency['name']
                .toString()
                .toLowerCase()
                .contains(searchFilter.toLowerCase()))
        .toList();
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
      body: Container(
        color: themeProvider.getThemeMode() == ThemeMode.dark
            ? Colors.black
            : Colors.white,
        child: Padding(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchFilter = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search for a currency',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
  itemCount: getFilteredCurrencies().length,
  itemBuilder: (context, index) {
    final currency = getFilteredCurrencies()[index];
    return ListTile(
      title: Text(currency['name'].toString()),
      onTap: () {
        setState(() {
          selectedCurrency = currency['code'].toString();
          searchFilter = '';
        });
        currencyNotifier.selectedCurrency = selectedCurrency ?? 'QR';
        Navigator.pop(context); // Close the dropdown after selecting a currency
      },
    );
  },
),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
