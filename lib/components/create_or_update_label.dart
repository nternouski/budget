import 'package:flutter/material.dart';
import '../server/model_rx.dart';
import '../common/styles.dart';
import '../model/label.dart';

class CreateOrUpdateLabel extends StatelessWidget {
  final TextEditingController nameController = TextEditingController(text: '');
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
    return StreamBuilder<List<Label>>(
      stream: labelRx.fetchRx,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return _buildLabel(labels, List<Label>.from(snapshot.data!));
        } else {
          return Text('Error on label input: ${snapshot.error.toString()}');
        }
      },
    );
  }

  Widget _buildLabel(List<Label> labels, List<Label> labelsDB) {
    return Column(children: [
      Autocomplete<Label>(
        displayStringForOption: (option) => option.name,
        fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode focus, VoidCallback _) {
          nameController.text = controller.text;
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
            String name = RegExp('"(.+)"').firstMatch(selection.name)?.group(0) ?? '';
            Label? label = await labelRx.create(Label(id: '', name: name.replaceAll('"', ''), color: Colors.black));
            nameController.clear();
            if (label != null) onSelect(label);
          } else {
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
                (label) => Chip(
                  label: Text(label.name),
                  onDeleted: () => onDelete(label),
                  deleteIcon: const Icon(Icons.cancel),
                  deleteIconColor: Colors.grey,
                ),
              )
              .toList(),
        ),
      )
    ]);
  }
}
