import 'package:flutter/material.dart';
import '../model/budget.dart';

const Color primary = Colors.green;
const Color secondary = Colors.pink;
const Color black = Colors.black;
const Color white = Colors.white;
const Color backgroundColor = Color.fromARGB(255, 251, 251, 251);
const Color grey = Colors.grey;
const Color red = Colors.red;
const Color green = Colors.green;
const Color blue = Colors.blue;

Map<BudgetType, Color> colorsTypeBudget = {BudgetType.income: green, BudgetType.expense: red, BudgetType.transfer: grey};
