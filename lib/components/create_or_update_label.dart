import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../server/database/label_rx.dart';
import '../common/styles.dart';
import '../model/label.dart';

class CreateOrUpdateLabel extends StatelessWidget {
  TextEditingController nameController = TextEditingController(text: '');
  final Function(Label) onSelect;
  final Function(Label) onDelete;
  final List<Label> labels;

  CreateOrUpdateLabel({
    required this.labels,
    required this.onSelect,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    auth.User user = Provider.of<auth.User>(context);

    return StreamBuilder<List<Label>>(
      stream: labelRx.getLabels(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return _buildLabel(labels, List<Label>.from(snapshot.data!), user);
        } else {
          return Text('Error on label input: ${snapshot.error.toString()}');
        }
      },
    );
  }

  Widget _buildLabel(List<Label> labels, List<Label> labelsDB, auth.User user) {
    return Column(children: [
      Autocomplete<Label>(
        displayStringForOption: (option) => option.name,
        fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode focus, VoidCallback _) {
          nameController = controller;
          return TextFormField(
            controller: nameController,
            decoration: InputStyle.inputDecoration(labelTextStr: 'Label search'),
            focusNode: focus,
          );
        },
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') return [];
          var options = labelsDB.where((option) => option.name.contains(textEditingValue.text.toLowerCase()));
          return options.isEmpty
              ? [Label(id: '', name: 'Crear Label "${textEditingValue.text}"?', color: Colors.black)]
              : options;
        },
        onSelected: (selection) async {
          if (selection.id == '') {
            nameController.clear();
            String name = RegExp('"(.+)"').firstMatch(selection.name)?.group(0) ?? '';
            Label label = Label(id: '', name: name.replaceAll('"', ''), color: Colors.black);
            label.id = await labelRx.create(label, user.uid);
            onSelect(label);
          } else {
            nameController.clear();
            onSelect(selection);
          }
        },
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
        child: Row(
          children: labels
              .map(
                (label) => Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Chip(
                    label: Text(label.name),
                    onDeleted: () => onDelete(label),
                    deleteIcon: const Icon(Icons.cancel),
                    deleteIconColor: Colors.grey,
                  ),
                ),
              )
              .toList(),
        ),
      )
    ]);
  }
}
