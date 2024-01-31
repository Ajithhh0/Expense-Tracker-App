// ignore_for_file: constant_identifier_names

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


final formatter = DateFormat.yMd();

const uuid = Uuid();

// ignore: constant_identifier_names


enum Category {
  food,
  travel,
  leisure,
  work,
  groceries,
  internet,
  gas,
  investment,
  clothing,
  mobile,
  entertainment,
  education,
  personal_care,
  health,
  fitness,
  kids,
  gifts_and_donations,
  bills_and_utilities,
  auto,
  taxes,
  pet_care,
  savings,
  misc,
  household,
  air_tickets,
  beauty,
  bike,
  books,
  bus_fare,
  cable,
  cake,
  car,
  cc_bill_payment,
  cigarette,
  coffee,
  drinks,
  electricity,
  electronics,
  finance,
  flowers,
  fruits,
  vegetables,
  games,
  hotel,
  ice_cream,
  maid,
  driver,
  maintenance,
  medicines,
  milk,
  movie,
  fuel,
  pizza,
  printing_and_scanning,
  rent,
  salon,
  shopping,
  stationery,
  taxi,
  toys,
  train,
  vacation,
  water,
  home_loan,
  personal_loan,
  education_loan,
  festivals,
  car_loan,
  laundry,
  emi,
  atm,
  toll,
  bonus,
  interest_income,
  reimbursement,
  rental_income,
  returned_purchase,
  salary,
}

const categoryIcons = {
  Category.food: FontAwesomeIcons.utensils,
  Category.travel: FontAwesomeIcons.plane,
  Category.leisure: FontAwesomeIcons.film,
  Category.work: FontAwesomeIcons.briefcase,
  Category.groceries: FontAwesomeIcons.basketShopping,
  Category.internet: FontAwesomeIcons.globe,
  Category.gas: FontAwesomeIcons.gasPump,
  Category.investment: FontAwesomeIcons.chartBar,
  Category.clothing: FontAwesomeIcons.shirt,
  Category.mobile: FontAwesomeIcons.mobileScreenButton,
  Category.entertainment: FontAwesomeIcons.gamepad,
  Category.education: FontAwesomeIcons.graduationCap,
  Category.personal_care: FontAwesomeIcons.pills,
  Category.health: FontAwesomeIcons.heartPulse,
  Category.fitness: FontAwesomeIcons.dumbbell,
  Category.kids: FontAwesomeIcons.child,
  Category.gifts_and_donations: FontAwesomeIcons.gift,
  Category.bills_and_utilities: FontAwesomeIcons.fileInvoiceDollar,
  Category.auto: FontAwesomeIcons.car,
  Category.taxes: FontAwesomeIcons.fileSignature,
  Category.pet_care: FontAwesomeIcons.paw,
  Category.savings: FontAwesomeIcons.piggyBank,
  Category.misc: FontAwesomeIcons.question,
  Category.household: FontAwesomeIcons.house,
  Category.air_tickets: FontAwesomeIcons.ticketSimple,
  
  Category.beauty: FontAwesomeIcons.palette,
  Category.bike: FontAwesomeIcons.bicycle,
  Category.books: FontAwesomeIcons.book,
  Category.bus_fare: FontAwesomeIcons.bus,
  Category.cable: FontAwesomeIcons.tv,
  Category.cake: FontAwesomeIcons.cakeCandles,
  Category.car: FontAwesomeIcons.carRear,
  Category.cc_bill_payment: FontAwesomeIcons.creditCard,
  Category.cigarette: FontAwesomeIcons.smoking,
  Category.coffee: FontAwesomeIcons.mugSaucer,
  Category.drinks: FontAwesomeIcons.wineGlass,
  Category.electricity: FontAwesomeIcons.bolt,
  Category.electronics: FontAwesomeIcons.laptop,
  Category.finance: FontAwesomeIcons.handHoldingDollar,
  Category.flowers: FontAwesomeIcons.leaf,
  Category.fruits: FontAwesomeIcons.appleWhole,
  Category.vegetables: FontAwesomeIcons.carrot,
  Category.games: FontAwesomeIcons.gamepad,
  Category.hotel: FontAwesomeIcons.hotel,
  Category.ice_cream: FontAwesomeIcons.iceCream,
  Category.maid: FontAwesomeIcons.broom,
  Category.driver: FontAwesomeIcons.carSide,
  Category.maintenance: FontAwesomeIcons.screwdriverWrench,
  Category.medicines: FontAwesomeIcons.pills,
  Category.milk: FontAwesomeIcons.whiskeyGlass,
  Category.movie: FontAwesomeIcons.film,
  Category.fuel: FontAwesomeIcons.gasPump,
  Category.pizza: FontAwesomeIcons.pizzaSlice,
  Category.printing_and_scanning: FontAwesomeIcons.print,
  Category.rent: FontAwesomeIcons.houseLock,
  Category.salon: FontAwesomeIcons.scissors,
  Category.shopping: FontAwesomeIcons.bagShopping,
  Category.stationery: FontAwesomeIcons.pen,
  Category.taxi: FontAwesomeIcons.taxi,
  Category.toys: FontAwesomeIcons.robot,
  Category.train: FontAwesomeIcons.train,
  Category.vacation: FontAwesomeIcons.planeDeparture,
  Category.water: FontAwesomeIcons.bottleWater,
  Category.home_loan: FontAwesomeIcons.houseCircleCheck,
  Category.personal_loan: FontAwesomeIcons.handshake,
  Category.education_loan: FontAwesomeIcons.graduationCap,
  Category.festivals: FontAwesomeIcons.bell,
  Category.car_loan: FontAwesomeIcons.car,
  Category.laundry: FontAwesomeIcons.soap,
  Category.emi: FontAwesomeIcons.chartLine,
  Category.atm: FontAwesomeIcons.moneyBill,
  Category.toll: FontAwesomeIcons.coins,
  Category.bonus: FontAwesomeIcons.gift,
  Category.interest_income: FontAwesomeIcons.handHoldingDollar,
  Category.reimbursement: FontAwesomeIcons.moneyCheckDollar,
  Category.rental_income: FontAwesomeIcons.handshake,
  Category.returned_purchase: FontAwesomeIcons.rotateLeft,
  Category.salary: FontAwesomeIcons.moneyBill1,
};



// class Expense {
//   Expense({
//     required this.title,
//     required this.amount,
//     required this.date,
//     required this.category, required String id,
//   }) : id = uuid.v4();

//   final String id;
//   final String title;
//   final double amount;
//   final DateTime date;
//   final Category category;

//   String get formattedDate {
//     return formatter.format(date);
//   }
// }


// class ExpenseBucket {
//   const ExpenseBucket({
//     required this.category,
//     required this.expenses,
//   });

//   ExpenseBucket.forCategory(List<Expense> allExpenses, this.category) : expenses = allExpenses.where((expense) => expense.category == category).toList();

//   final Category category;
//   final List<Expense> expenses;

//   double get totalExpenses {
//     double sum = 0;
//     for (final expense in expenses) {
//       sum += expense.amount;
//     }
//     return sum;
//   }
// }
// class Income {
//   Income({
//     required this.title,
//     required this.amount,
//     required this.date,
//     required this.category,
//     required String id,
//   }) : id = uuid.v4();

//   final String id;
//   final String title;
//   final double amount;
//   final DateTime date;
//   final Category category;

//   String get formattedDate {
//     return formatter.format(date);
//   }
// }

// class IncomeBucket {
//   const IncomeBucket({
//     required this.category,
//     required this.incomes,
//   });

//   IncomeBucket.forCategory(List<Income> allIncomes, this.category)
//       : incomes = allIncomes.where((income) => income.category == category).toList();

//   final Category category;
//   final List<Income> incomes;

//   double get totalIncomes {
//     double sum = 0;
//     for (final income in incomes) {
//       sum += income.amount;
//     }
//     return sum;
//   }
// }
 class Transaction {
  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type, // Add a type to differentiate between Expense and Income
    required String id,
  }) : id = uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final TransactionType type; // Enum to differentiate between Expense and Income

  String get formattedDate {
    return formatter.format(date);
  }

   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toString().split('.').last,
      'type': type.toString().split('.').last,
    };
  }
  factory Transaction.fromMap(Map<String, dynamic> map) {
    try {
      return Transaction(
        id: map['id'],
        title: map['title'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
        category: Category.values.firstWhere(
          (e) => e.toString().split('.').last == map['category'],
        ),
        type: TransactionType.values.firstWhere(
          (e) => e.toString().split('.').last == map['type'],
        ),
      );
    } catch (e) {
      // Handle parsing errors or missing values here
      return Transaction(
        id: map['id'],
        title: map['title'],
        amount: map['amount'],
        date: DateTime.now(),
        category: Category.food, // Provide a default category or adjust accordingly
        type: TransactionType.Expense, // Provide a default type or adjust accordingly
      );
    }
  }
  
  
  // Helper method to convert a string to a TransactionType enum
  static TransactionType _typeFromString(String typeString) {
    return TransactionType.values.firstWhere((e) => e.toString().split('.').last == typeString);
  }
}




enum TransactionType {
  Expense,
  Income,
}

class TransactionBucket {
  const TransactionBucket({
    required this.category,
    required this.transactions,
    required this.type,
  });

  TransactionBucket.forCategory(List<Transaction> allTransactions, this.category, this.type)
      : transactions = allTransactions
            .where((transaction) => transaction.category == category && transaction.type == type)
            .toList();

  final Category category;
  final List<Transaction> transactions;
  final TransactionType type;

  double get totalAmount {
    double sum = 0;
    for (final transaction in transactions) {
      sum += transaction.amount;
    }
    return sum;
  }
}