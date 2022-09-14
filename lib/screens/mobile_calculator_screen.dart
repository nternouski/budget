import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_data/sim_data.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../common/error_handler.dart';
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
  final mobileDataFormFields = MobileDataFormFields(now, plans[0], 0, requests[0]);
  final panelExpanded = ValueNotifier<int>(-1);
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
              labelText: 'Start Date Plan',
              suffixIcon: Icon(Icons.calendar_today),
              hintText: 'Search',
            ),
            onTap: () async {
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

  sendAdvancedUssd(BuildContext context, RequestUSSD request) async {
    debugPrint('----------------');
    var phone = await Permission.phone.request();
    if (!phone.isGranted) return Display.message(context, 'No permission for phone!');
    try {
      var sims = await SimDataPlugin.getSimData();
      int subscriptionId = sims.cards.firstWhere((c) => c.carrierName.toLowerCase() == 'tuenti').subscriptionId;
      debugPrint('--------> subscriptionId = $subscriptionId | code = ${request.code}');
      var responseAdvance = await UssdAdvanced.sendAdvancedUssd(code: request.code, subscriptionId: subscriptionId);
      debugPrint('--------> success! message ADVANCE: $responseAdvance');
    } catch (e) {
      debugPrint('--------> error! code: $e');
    }
  }

  List<Widget> getBody() {
    final theme = Theme.of(context);

    var panels = [
      Panel(
        title: 'Update Data Used by USSD',
        body: Column(
          children: [
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Select Plan'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<RequestUSSD>(
                  value: mobileDataFormFields.request,
                  isDense: true,
                  onChanged: (RequestUSSD? newRequest) =>
                      newRequest != null ? setState(() => mobileDataFormFields.request = newRequest) : null,
                  items: requests.map((r) => DropdownMenuItem(value: r, child: Text(r.simName))).toList(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => sendAdvancedUssd(context, mobileDataFormFields.request),
              child: const Text('Fetch Data Used'),
            ),
          ],
        ),
      )
    ];
    return [
      SliverAppBar(
        titleTextStyle: theme.textTheme.titleLarge,
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
                      decoration: const InputDecoration(labelText: 'Data Spent', hintText: '0', suffix: Text('Mb')),
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
                    ValueListenableBuilder(
                      valueListenable: panelExpanded,
                      builder: (context, idxExpanded, _) => ExpansionPanelList(
                        expansionCallback: (int idx, bool exp) => setState(() => panelExpanded.value = !exp ? idx : -1),
                        children: panels.asMap().entries.map<ExpansionPanel>((entry) {
                          var idx = entry.key;
                          return ExpansionPanel(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            headerBuilder: (BuildContext context, _) => InkWell(
                              onTap: () => setState(() => panelExpanded.value = idxExpanded != idx ? idx : -1),
                              child: ListTile(title: Text(entry.value.title)),
                            ),
                            body: Padding(padding: const EdgeInsets.only(right: 15, left: 15), child: entry.value.body),
                            isExpanded: idx == idxExpanded,
                          );
                        }).toList(),
                      ),
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
