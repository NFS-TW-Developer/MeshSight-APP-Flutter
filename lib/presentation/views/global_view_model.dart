import 'package:flutter/material.dart';

import '../../core/models/app_info_data.dart';
import '../../core/models/app_status_message.dart';
import '../../core/utils/app_utils.dart';
import '../../localization/generated/l10n.dart';

class GlobalViewModel extends ChangeNotifier {
  late AppInfoData _appInfo; //
  AppInfoData get appInfo => _appInfo;

  void initGlobalViewModel() async {
    // 初始化 _appInfo 變數
    _appInfo = await AppUtils.getAppInfo();
  }

  // 顯示 snackBar
  void showStatusSnackBar(BuildContext context, AppStatusMessage response) {
    String? message = response.message;
    if (response.status) {
      message = '${S.current.Successful}${message != null ? ': $message' : ''}';
    } else {
      message = '${S.current.Failed}${message != null ? ': $message' : ''}';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
