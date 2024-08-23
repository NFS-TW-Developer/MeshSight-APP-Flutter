/*
此類用來管理全局變數，
所有全局變數都要在此設置、編寫 getter, setter
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_info_data.dart';
import '../../core/models/app_status_message.dart';
import '../../core/utils/app_utils.dart';
import '../../localization/generated/l10n.dart';

class GlobalViewModel extends ChangeNotifier {
  // example :
  // late User _currentUser = User(id: 'id', name: 'name', email: 'email', loginType: LoginType.Google);
  // User? get currentUser => _currentUser;
  //
  // void setCurrentUser(User user) {
  //   _currentUser = user;
  // }

  late AppInfoData _appInfo; //
  AppInfoData get appInfo => _appInfo;

  void initGlobalViewModel() async {
    // 初始化 _appInfo 變數
    _appInfo = await AppUtils.getAppInfo();
  }

  /*
   顯示 snackBar
   */
  void showStatusSnackBar(
      BuildContext context, AppStatusMessage response) {
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
