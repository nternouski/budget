import 'package:budget/model/budget.dart';

var now = DateTime.now();

Budget _budgetExpense = Budget(
    name: "Cookie",
    amount: 333,
    categoryId: "",
    date: now.subtract(const Duration(days: 367)),
    walletId: "",
    type: BudgetType.expense,
    description: "asdasd",
    id: "Cookie @");

Budget _budgetIncome = Budget(
    name: "Salary",
    amount: 1000,
    categoryId: "",
    date: now.subtract(const Duration(days: 41)),
    walletId: "",
    type: BudgetType.income,
    description: "asdasdas",
    id: "Saldad @");

Budget _budgetTransfer = Budget(
    name: "Wallet X to Wallet Y",
    amount: 345,
    categoryId: "",
    date: now.subtract(const Duration(days: 0)),
    walletId: "",
    type: BudgetType.transfer,
    description: "",
    id: "Transaction X");

final daily = [
  _budgetExpense,
  _budgetIncome,
  _budgetExpense,
  _budgetTransfer,
  _budgetIncome,
  _budgetExpense,
  _budgetIncome,
  _budgetExpense,
  _budgetIncome,
  _budgetTransfer,
  _budgetTransfer,
  _budgetIncome,
];
