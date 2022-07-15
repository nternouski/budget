import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../model/budget.dart';
import '../json/create_budget_json.dart';
import '../common/color_constants.dart';
import '../common/styles.dart';

// ignore: constant_identifier_names
const MAX_LENGTH_AMOUNT = 5;

class CreateOrUpdateBudget extends StatefulWidget {
  late Budget budget;

  CreateOrUpdateBudget({Budget? budget, Key? key}) : super(key: key) {
    if (budget != null) {
      this.budget = budget;
    } else {
      this.budget = Budget(
        name: "",
        amount: 0,
        categoryId: "",
        date: now,
        walletId: "",
        type: BudgetType.expense,
        description: "",
        id: "",
      );
    }
  }

  @override
  _CreateOrUpdateBudgetState createState() => _CreateOrUpdateBudgetState(budget);
}

final now = DateTime.now();

class _CreateOrUpdateBudgetState extends State<CreateOrUpdateBudget> {
  Budget budget;

  _CreateOrUpdateBudgetState(this.budget);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final sizedBoxHeight = const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: white,
                boxShadow: [BoxShadow(color: grey.withOpacity(0.01), spreadRadius: 10, blurRadius: 3)],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60, right: 20, left: 20, bottom: 25),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [Text("Create budget", style: titleStyle)],
                    )
                  ],
                ),
              ),
            ),
            sizedBoxHeight,
            getForm()
          ],
        ),
      ),
    );
  }

  Widget buildCatalog() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child:
              Text("Choose category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: black.withOpacity(0.5))),
        ),
        sizedBoxHeight,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: List.generate(categories.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  budget.categoryId = categories[index].id;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                      color: white,
                      border:
                          Border.all(width: 2, color: budget.categoryId == categories[index].id ? primary : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: grey.withOpacity(0.01), spreadRadius: 10, blurRadius: 3),
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: grey.withOpacity(0.15)),
                        child: Center(child: Image.asset(categories[index].icon, width: 30, height: 30, fit: BoxFit.contain)),
                      ),
                      Text(
                        categories[index].name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      )
                    ],
                  ),
                ),
              ),
            );
          })),
        ),
        sizedBoxHeight,
      ],
    );
  }

  Widget buildAmount() {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.45,
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(MAX_LENGTH_AMOUNT)],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: black),
          decoration: const InputDecoration(border: InputBorder.none, hintText: "\$ 0"),
          validator: (String? value) {
            if (value!.isEmpty) return 'Event Amount is Required.';
            return null;
          },
          onSaved: (String? value) {
            budget.amount = int.parse(value!);
          },
        ),
      ),
    );
  }

  Widget buildName() {
    return TextFormField(
      style: InputStyle.textStyle(),
      decoration: InputStyle.inputDecoration(
        labelTextStr: "Name",
        hintTextStr: "Cookies",
      ),
      validator: (String? value) {
        if (value!.isEmpty) return 'Event Name is Required.';
        return null;
      },
      onSaved: (String? value) {
        budget.name = value!;
      },
    );
  }

  // DATE PICKER //
  final TextEditingController _dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(now));
  final TextEditingController _timeController = TextEditingController(text: DateFormat('hh:mm').format(now));
  Widget buildDateField() {
    const formatDate = 'dd/MM/yyyy';
    const formatTime = 'hh:mm';
    return Row(
      children: <Widget>[
        Flexible(
          child: TextFormField(
            controller: _dateController,
            onTap: () async {
              // Below line stops keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());
              // Show Date Picker Here
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: budget.date,
                firstDate: DateTime(2010),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != budget.date) {
                setState(() {
                  budget.date = picked;
                });
              }
              _dateController.text = DateFormat(formatDate).format(budget.date);
            },
            style: InputStyle.textStyle(),
            decoration: InputStyle.inputDecoration(labelTextStr: "Date", hintTextStr: formatDate),
            validator: (String? value) {
              return value!.isEmpty ? 'Event Date is Required.' : null;
            },
          ),
        ),
        Flexible(
          child: TextFormField(
            controller: _timeController,
            onTap: () async {
              // Below line stops keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());
              // Show Date Picker Here
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: budget.date.hour, minute: budget.date.minute),
              );
              if (picked != null && picked != budget.getTime()) {
                setState(() {
                  budget.setTime(hour: picked.hour, minute: picked.minute);
                });
              }
              _timeController.text = DateFormat(formatTime).format(budget.date);
            },
            style: InputStyle.textStyle(),
            decoration: InputStyle.inputDecoration(labelTextStr: "Time", hintTextStr: formatTime),
            validator: (String? value) {
              return value!.isEmpty ? 'Event Date is Required.' : null;
            },
          ),
        ),
      ],
    );
  }

  Widget getForm() {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          buildCatalog(),
          buildAmount(),
          buildName(),
          buildDateField(),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    _formKey.currentState!.save();
                    // createPublicEvent(date: date, startTime: startTime, endTime: endTime, title: title, venue: venue)
                    //     .then((onValue) {
                    //   print('value $onValue');
                    // });
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 17)),
                )
              ],
            ),
          )
        ]));
  }
}
