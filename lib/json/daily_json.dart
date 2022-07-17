import '../model/transaction.dart';

var now = DateTime.now();

Transaction _transactionExpense = Transaction(
    name: "Cookie",
    amount: 333,
    categoryId: "",
    date: now.subtract(const Duration(days: 367)),
    walletId: "",
    type: TransactionType.expense,
    description: "asdasd",
    id: "Cookie @");

Transaction _transactionIncome = Transaction(
    name: "Salary",
    amount: 1000,
    categoryId: "",
    date: now.subtract(const Duration(days: 41)),
    walletId: "",
    type: TransactionType.income,
    description: "asdasdas",
    id: "Saldad @");

Transaction _transactionTransfer = Transaction(
    name: "Wallet X to Wallet Y",
    amount: 345,
    categoryId: "",
    date: now.subtract(const Duration(days: 0)),
    walletId: "",
    type: TransactionType.transfer,
    description: "",
    id: "Transaction X");

final daily = [
  _transactionExpense,
  _transactionIncome,
  _transactionExpense,
  _transactionTransfer,
  _transactionIncome,
  _transactionExpense,
  _transactionIncome,
  _transactionExpense,
  _transactionIncome,
  _transactionTransfer,
  _transactionTransfer,
  _transactionIncome,
];
