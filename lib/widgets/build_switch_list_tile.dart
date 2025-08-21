import 'package:flutter/material.dart';

Widget buildSwitchListTile({
  required bool isActivate,
  required bool isEditable,
  required Function(bool) onChanged,
}) {
  return SwitchListTile(
    title: Text('تفعيل المستخدم'),
    value: isActivate,
    onChanged: isEditable ? onChanged : null,
  );
}
