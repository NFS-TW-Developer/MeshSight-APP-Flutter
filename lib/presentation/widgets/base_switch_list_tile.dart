import 'package:flutter/material.dart';

import '../theme/ui_theme.dart';

class BaseSwitchListTile extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool)? onChangedFunction;

  const BaseSwitchListTile({
    super.key,
    required this.title,
    required this.value,
    this.onChangedFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
      child: SwitchListTile(
        tileColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        value: value,
        onChanged: onChangedFunction,
        activeTrackColor: const Color(0xff009ade), // on/bg
        inactiveTrackColor: UiTheme.backgroundColor, // off/
      ),
    );
  }
}
