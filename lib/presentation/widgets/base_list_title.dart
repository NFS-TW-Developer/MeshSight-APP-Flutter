import 'package:flutter/material.dart';

import '../theme/ui_theme.dart';

class BaseListTitle extends StatelessWidget {
  final String title;

  const BaseListTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: UiTheme.backgroundColor,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
      ),
    );
  }
}
