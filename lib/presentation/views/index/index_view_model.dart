import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../localization/generated/l10n.dart';
import '../base_view_model.dart';

class IndexViewModel extends BaseViewModel {
  @override
  void initViewModel(BuildContext context) {
    super.initViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.current.DevelopAlertTitle),
            content: Column(
              children: [
                Text(S.current.DevelopAlertContent),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse(
                        'https://github.com/edwinyoo44/MeshSight/issues'));
                  },
                  child: const Text(
                      'https://github.com/edwinyoo44/MeshSight/issues'),
                ),
                TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse(
                        'https://github.com/edwinyoo44/MeshSight-APP-Flutter/issues'));
                  },
                  child: const Text(
                      'https://github.com/edwinyoo44/MeshSight-APP-Flutter/issues'),
                ),
                // 警告訊息
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red,
                  child: Text(
                    "${S.current.WelcomeAlert1} \n\n ${S.current.WelcomeAlert2}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(S.current.IUnderstand),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }
}
