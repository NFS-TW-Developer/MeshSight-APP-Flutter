import 'package:flutter/material.dart';

class BaseListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final Function? onTapFunction;
  final Widget? trailing;

  const BaseListTile({
    super.key,
    this.leading,
    required this.title,
    this.onTapFunction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        onTap: () {
          onTapFunction!();
        },
        trailing: trailing,
        tileColor: Colors.white,
      ),
    );
  }
}
