import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/widgets/expenses.dart';
import 'package:expense_tracker/theme/theme_provider.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: ThemeData.light().copyWith(
        cardTheme: const CardTheme(
          color: Color.fromARGB(255, 192, 190, 185),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.getThemeMode(),
      home: Consumer<CurrencyNotifier>(
        builder: (context, currencyNotifier, child) {
          return Expenses(
            onTransactionAdded: ( amount) {},
            transactions: const [], // Provide a list of transactions here
            initialIncome: 0.0,
            onUpdateCurrentIncome: (double updatedCurrentIncome) {
              // Handle the update of currentIncome in the Income widget
              // You can pass this function to the Income widget to update its state
            },
          );
        },
      ),
    );
  }
}
