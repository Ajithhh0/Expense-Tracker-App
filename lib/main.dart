import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/widgets/expenses.dart';
import 'package:expense_tracker/theme/theme_provider.dart';
import 'package:expense_tracker/widgets/settings/currency_notifier.dart';
import 'package:expense_tracker/database/db_helper.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.instance.initDatabase();
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
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        scaffoldBackgroundColor: Colors.transparent, 
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 255, 255), 
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.getThemeMode(),
      home: Consumer<CurrencyNotifier>(
        builder: (context, currencyNotifier, child) {
          return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255), 
            ),
            child: Expenses(
              onTransactionAdded: (amount) {},
              transactions: const [], 
              initialIncome: 0.0,
              onUpdateCurrentIncome: (double updatedCurrentIncome) {
                
              },
            ),
          );
        },
      ),
    );
  }
}
