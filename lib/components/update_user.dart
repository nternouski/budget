import 'package:budget/common/styles.dart';
import 'package:budget/components/select_currency.dart';
import 'package:budget/model/user.dart';
import 'package:budget/server/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Action { create, update }

class UpdateUser extends StatefulWidget {
  final User user;
  final Function(User) onUpdate;

  const UpdateUser({required this.user, required this.onUpdate, Key? key}) : super(key: key);

  @override
  UpdateUserState createState() => UpdateUserState();
}

final now = DateTime.now();

class UpdateUserState extends State<UpdateUser> {
  UpdateUserState();

  @override
  Widget build(BuildContext context) {
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
                const Text('Update Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                sizedBoxHeight,
                TextFormField(
                  initialValue: widget.user.name,
                  decoration: InputStyle.inputDecoration(labelTextStr: 'Name', hintTextStr: 'John Doe'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z  ]')),
                    LengthLimitingTextInputFormatter(30)
                  ],
                  validator: (String? value) => value!.isEmpty ? 'Name is Required.' : null,
                  onChanged: (String name) => widget.user.name = name,
                ),
                sizedBoxHeight,
                TextFormField(
                  initialValue: widget.user.email,
                  decoration: InputStyle.inputDecoration(labelTextStr: 'Email', hintTextStr: 'email@email.com'),
                  validator: (String? value) => value!.isEmpty ? 'Email is Required.' : null,
                  onChanged: (String email) => widget.user.email = email,
                ),
                sizedBoxHeight,
                SelectCurrency(
                  defaultCurrencyId: widget.user.defaultCurrencyId,
                  onSelect: (c) => setState(() => widget.user.defaultCurrencyId = c.id),
                ),
                sizedBoxHeight,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buttonCancelContext(context),
                    ElevatedButton(
                      child: const Text('Update'),
                      onPressed: () {
                        UserService().update(widget.user);
                        widget.onUpdate(widget.user);
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
