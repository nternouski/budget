import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../i18n/index.dart';
import '../common/styles.dart';
import '../model/mobile_calculator.dart';

class Panel {
  Widget body;
  String title;

  Panel({required this.title, required this.body});
}

class MobileCalculatorScreen extends StatefulWidget {
  const MobileCalculatorScreen({Key? key}) : super(key: key);

  @override
  MobileCalculatorScreenState createState() => MobileCalculatorScreenState();
}

// ignore: constant_identifier_names
const int SPENT_DATE_MB_MIN = 0;
final DateTime now = DateTime.now();

class MobileCalculatorScreenState extends State<MobileCalculatorScreen> {
  final sizedBoxHeight = const SizedBox(height: 15);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(now));
  final mobileDataFormFields = MobileDataFormFields(now, plans[0], 0);
  MobileCalculatorScreenState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final form = Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _buildSelectPlan(),
        _buildDateAndDataField(theme),
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
            child: Text('Calculate'.i18n),
          ),
        ),
      ]),
    );
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          titleTextStyle: theme.textTheme.titleLarge,
          pinned: true,
          leading: getBackButton(context),
          title: Text('Mobile Data Calculator'.i18n),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Builder(builder: (context) => form),
              )
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildSelectPlan() {
    return InputDecorator(
      decoration: InputDecoration(labelText: 'Select Plan'.i18n),
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
    final theme = Theme.of(context);
    final data = mobileDataFormFields;
    int daysRemaining = data.plan.totalDays - DateTime.now().difference(data.startDate).inDays;
    double dataRemaining = double.parse(((data.plan.gb - data.spentDataMb / 1024) / daysRemaining).toStringAsFixed(1));
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Result'.i18n),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${'Avg reminding'.i18n}:', style: theme.textTheme.bodyMedium),
                  Text('$dataRemaining ${'Gb/day'.i18n}', style: theme.textTheme.bodySmall)
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${'Days reminder'.i18n}:', style: theme.textTheme.bodyMedium),
                  Text('$daysRemaining', style: theme.textTheme.bodySmall)
                ],
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateAndDataField(ThemeData theme) {
    const formatDate = 'dd/MM/yyyy';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: InkWell(
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
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
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.edit_calendar_rounded),
                  const SizedBox(width: 10),
                  Text(_dateController.text, style: theme.textTheme.titleMedium)
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          fit: FlexFit.tight,
          child: TextFormField(
            initialValue: mobileDataFormFields.spentDataMb.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Data Spent'.i18n, hintText: '0', suffix: const Text('Mb')),
            validator: (value) {
              final int? spentDataMb = int.tryParse(value!);
              if (spentDataMb != null && spentDataMb > SPENT_DATE_MB_MIN) {
                return null;
              } else {
                return '${'Please enter your a value grater than'.i18n} $SPENT_DATE_MB_MIN.';
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
        ),
      ],
    );
  }
}
