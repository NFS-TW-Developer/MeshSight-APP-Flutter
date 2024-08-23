import 'package:flutter/material.dart';

class BaseExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const BaseExpansionTile({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
      color: Colors.white,
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        children: children,
      ),
    );
  }
}
