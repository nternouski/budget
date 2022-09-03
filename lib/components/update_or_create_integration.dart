import 'package:budget/common/styles.dart';
import 'package:budget/model/integration.dart';
import 'package:budget/model/user.dart';
import 'package:budget/server/model_rx.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateOrCreateIntegration extends StatefulWidget {
  const UpdateOrCreateIntegration({Key? key}) : super(key: key);

  @override
  UpdateUserState createState() => UpdateUserState();
}

final now = DateTime.now();

class UpdateUserState extends State<UpdateOrCreateIntegration> {
  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User>(context);
    Integration wise = user.integrations.firstWhere(
      (i) => i.integrationType == IntegrationType.wise,
      orElse: () => Integration.wise(user.id),
    );

    return IconButton(
      icon: Icon(wise.id == '' ? Icons.add : Icons.edit),
      onPressed: () => showModalBottomSheet(
        enableDrag: false,
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) => BottomSheet(
          enableDrag: false,
          onClosing: () {},
          builder: (BuildContext context) => _bottomSheet(wise),
        ),
      ),
    );
  }

  _bottomSheet(Integration integration) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Update Integration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextFormField(
                  initialValue: integration.apiKey,
                  decoration: InputStyle.inputDecoration(labelTextStr: 'API Key'),
                  validator: (String? value) => value!.isEmpty ? 'Integration is Required.' : null,
                  onChanged: (String apiKey) => integration.apiKey = apiKey,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buttonCancelContext(context),
                    ElevatedButton(
                      child: const Text('Update'),
                      onPressed: () {
                        integration.id == '' ? integrationRx.create(integration) : integrationRx.update(integration);
                        setState(() => {});
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
      },
    );
  }
}
