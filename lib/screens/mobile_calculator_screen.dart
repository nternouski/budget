import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../common/color_constants.dart';
import '../common/styles.dart';
import '../model/mobile_calculator.dart';

class MobileCalculatorScreen extends StatefulWidget {
  @override
  _MobileCalculatorScreenState createState() => _MobileCalculatorScreenState();
}

// ignore: constant_identifier_names
const int SPENT_DATE_MB_MIN = 0;
final DateTime now = DateTime.now();

class _MobileCalculatorScreenState extends State<MobileCalculatorScreen> {
  final sizedBoxHeight = const SizedBox(height: 15);

  final _formKey = GlobalKey<FormState>();
  final mobileDataFormFields = MobileDataFormFields(now, plans[0], 0);

  _MobileCalculatorScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: getBody(),
      ),
    );
  }

  Widget buildSelectPlan() {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Select Plan'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PlanData>(
          value: mobileDataFormFields.plan,
          isDense: true,
          onChanged: (PlanData? newPlan) =>
              newPlan != null ? setState(() => mobileDataFormFields.plan = newPlan) : null,
          items: plans.map((plan) => DropdownMenuItem(value: plan, child: Text(plan.label))).toList(),
        ),
      ),
    );
  }

  _showDialog(BuildContext context) {
    final data = mobileDataFormFields;
    int daysRemaining = data.plan.totalDays - DateTime.now().difference(data.startDate).inDays;
    double dataRemaining = double.parse(((data.plan.gb - data.spentDataMb / 1024) / daysRemaining).toStringAsFixed(2));
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Resultado"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [const Text("Restante promedio:", style: titleStyle), Text("$dataRemaining Gb/dia")]),
              Row(children: [const Text("Dias restantes:", style: titleStyle), Text("$daysRemaining")]),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Ok", style: TextStyle(color: primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  final TextEditingController _dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(now));
  Widget buildDateField() {
    const formatDate = 'dd/MM/yyyy';
    return Row(
      children: <Widget>[
        Flexible(
          child: TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Fecha Inicio Plan',
              suffixIcon: Icon(Icons.calendar_today),
              hintText: 'Search',
            ),
            onTap: () async {
              // Below line stops keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());
              // Show Date Picker Here
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: mobileDataFormFields.startDate,
                firstDate: DateTime(2010),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != mobileDataFormFields.startDate) {
                setState(() {
                  mobileDataFormFields.startDate = picked;
                });
              }
              _dateController.text = DateFormat(formatDate).format(mobileDataFormFields.startDate);
            },
            validator: (String? value) {
              return value!.isEmpty ? 'Date is Required.' : null;
            },
          ),
        ),
      ],
    );
  }

  List<Widget> getBody() {
    return [
      SliverAppBar(
        pinned: true,
        backgroundColor: white,
        leading: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [Text("Mobile Data Calculator", style: titleStyle)],
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(0),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Builder(
                builder: (context) => Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    buildSelectPlan(),
                    buildDateField(),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Datos Gastados', hintText: "0", suffix: Text("Mb")),
                      validator: (value) {
                        final int? spentDataMb = int.tryParse(value!);
                        if (spentDataMb != null && spentDataMb > SPENT_DATE_MB_MIN) {
                          return null;
                        } else {
                          return 'Please enter your a value grater than $SPENT_DATE_MB_MIN.';
                        }
                      },
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) {
                        final int? spentDataMb = int.tryParse(value!);
                        if (spentDataMb != null && spentDataMb != mobileDataFormFields.spentDataMb) {
                          setState(() => mobileDataFormFields.spentDataMb = spentDataMb);
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final form = _formKey.currentState;
                          if (form != null && form.validate()) {
                            form.save();
                            _showDialog(context);
                          }
                        },
                        child: const Text('Calculate'),
                      ),
                    ),
                  ]),
                ),
              ),
            )
          ]),
        ),
      ),
    ];
  }
}
