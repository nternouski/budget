import 'package:budget/common/styles.dart';
import 'package:budget/model/user.dart';
import 'package:budget/server/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateOrCreateIntegration extends StatefulWidget {
  const UpdateOrCreateIntegration({Key? key}) : super(key: key);

  @override
  UpdateUserState createState() => UpdateUserState();
}

class UpdateUserState extends State<UpdateOrCreateIntegration> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    String apiKey = user.integrations[IntegrationType.wise] ?? '';

    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => showModalBottomSheet(
        enableDrag: false,
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) => BottomSheet(
          enableDrag: false,
          onClosing: () {},
          builder: (BuildContext context) => _bottomSheet(apiKey, user, context),
        ),
      ),
    );
  }

  _bottomSheet(String apiKey, User user, BuildContext context) {
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
              initialValue: apiKey,
              decoration: InputStyle.inputDecoration(labelTextStr: 'API Key'),
              validator: (String? value) => value!.isEmpty ? 'Integration is Required.' : null,
              onChanged: (String newApiKey) => apiKey = newApiKey,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buttonCancelContext(context),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () {
                    user.integrations.update(IntegrationType.wise, (value) => apiKey, ifAbsent: () => apiKey);
                    UserService().update(user);
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
  }
}
