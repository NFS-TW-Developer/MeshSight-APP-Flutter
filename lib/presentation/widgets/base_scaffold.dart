import 'package:flutter/material.dart';

import '../theme/ui_theme.dart';
import 'base_app_bar.dart';

class BaseScaffold extends StatelessWidget {
  final bool appBarShow;
  final Widget? appBarLeading;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const BaseScaffold({
    super.key,
    this.appBarShow = true,
    this.appBarLeading,
    this.appBarTitle,
    this.appBarActions,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiTheme.backgroundColor,
      appBar: (appBarShow)
          ? BaseAppBar(
              appBar: AppBar(),
              leading: appBarLeading,
              title: appBarTitle,
              actions: appBarActions,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
