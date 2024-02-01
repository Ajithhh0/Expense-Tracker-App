import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:expense_tracker/models/expense.dart' as ExpenseModel;

class DbHelper {
  static const String dbName = 'expense_tracker.db';
  static const String transactionsTable = 'transactions';

  // Singleton pattern for database helper
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, dbName);

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $transactionsTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            date TEXT,
            category TEXT,
            type TEXT
          )
        ''');
      },
    );
  }

  insertTransaction(ExpenseModel.Transaction transaction) async {
    final db = await instance.database;
    var res = await db.insert(
      transactionsTable,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<void> updateTransaction(
      ExpenseModel.Transaction updatedTransaction) async {
    final db = await instance.database;
    await db.update(
      transactionsTable,
      updatedTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [updatedTransaction.id],
    );
  }

  Future<List<ExpenseModel.Transaction>> getAllTransactions() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(transactionsTable);

    return List.generate(maps.length, (index) {
      return ExpenseModel.Transaction.fromMap(maps[index]);
    });
  }

  Future<void> deleteTransaction(String id) async {
    final db = await instance.database;
    await db.delete(
      transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
