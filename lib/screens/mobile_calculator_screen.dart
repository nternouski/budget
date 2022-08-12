import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sim_data/sim_data.dart';
// import 'package:ussd_service/ussd_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../common/styles.dart';
import '../model/mobile_calculator.dart';

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
  final mobileDataFormFields = MobileDataFormFields(now, plans[0], 0);

  MobileCalculatorScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    double dataRemaining = double.parse(((data.plan.gb - data.spentDataMb / 1024) / daysRemaining).toStringAsFixed(1));
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resultado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Restante promedio:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  Text('$dataRemaining Gb/dia')
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dias restantes:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  Text('$daysRemaining')
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

  // makeMyRequest({String code = '*999*#' /*'*#21#' */}) async {
  //   debugPrint('----------------');
  //   var phone = await Permission.phone.request();
  //   if (!phone.isGranted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text('No permission for phone!'),
  //           duration: Duration(seconds: 5),
  //           behavior: SnackBarBehavior.floating,
  //           backgroundColor: red),
  //     );
  //     return;
  //   }
  //   try {
  //     var sims = await SimDataPlugin.getSimData();
  //     int subscriptionId = sims.cards.firstWhere((c) => c.carrierName == 'Tuenti').subscriptionId;
  //     debugPrint('--------> subscriptionId = $subscriptionId | code = $code');
  //     String response = await UssdService.makeRequest(subscriptionId, code, const Duration(seconds: 15));
  //     debugPrint('--------> success! message: $response');
  //   } catch (e) {
  //     debugPrint('--------> error! code: $e');
  //   }
  //   debugPrint('----------------');
  // }

  List<Widget> getBody() {
    final textTheme = Theme.of(context).textTheme;
    return [
      SliverAppBar(
        titleTextStyle: textTheme.titleLarge,
        pinned: true,
        leading: getBackButton(context),
        title: const Text('Mobile Data Calculator'),
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
                      decoration: const InputDecoration(labelText: 'Datos Gastados', hintText: '0', suffix: Text('Mb')),
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
                    // ElevatedButton(
                    //   onPressed: () {
                    //     makeMyRequest();
                    //   },
                    //   child: const Text('make'),
                    // ),
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
