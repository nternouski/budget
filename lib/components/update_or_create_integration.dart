import 'package:budget/common/styles.dart';
import 'package:budget/model/integration.dart';
import 'package:budget/server/model_rx.dart';
import 'package:flutter/material.dart';

class UpdateOrCreateIntegration extends StatefulWidget {
  final Integration integration;
  final Function(Integration) onAction;

  const UpdateOrCreateIntegration({required this.integration, required this.onAction, Key? key}) : super(key: key);

  @override
  UpdateUserState createState() => UpdateUserState();
}

final now = DateTime.now();

class UpdateUserState extends State<UpdateOrCreateIntegration> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(widget.integration.id == '' ? Icons.add : Icons.edit),
      onPressed: () => showModalBottomSheet(
        enableDrag: false,
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) => BottomSheet(
          enableDrag: false,
          onClosing: () {},
          builder: (BuildContext context) => _bottomSheet(),
        ),
      ),
    );
  }

  _bottomSheet() {
    const sizedBoxHeight = SizedBox(height: 20);

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
                sizedBoxHeight,
                TextFormField(
                  initialValue: widget.integration.apiKey,
                  decoration: InputStyle.inputDecoration(labelTextStr: 'API Key'),
                  validator: (String? value) => value!.isEmpty ? 'Integration is Required.' : null,
                  onChanged: (String apiKey) => widget.integration.apiKey = apiKey,
                ),
                sizedBoxHeight,
                // SelectCurrency(
                //   defaultCurrencyId: widget.user.defaultCurrencyId,
                //   onSelect: (c) => setState(() => widget.user.defaultCurrencyId = c.id),
                // ),
                sizedBoxHeight,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buttonCancelContext(context),
                    ElevatedButton(
                      child: const Text('Update'),
                      onPressed: () {
                        debugPrint('-----------------> ${widget.integration.id == ''}');
                        if (widget.integration.id == '') {
                          integrationRx.create(widget.integration);
                        } else {
                          integrationRx.update(widget.integration);
                        }
                        widget.onAction(widget.integration);
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
