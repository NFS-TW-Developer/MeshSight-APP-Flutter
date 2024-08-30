import 'package:flutter/material.dart';

import '../../core/models/app_info_data.dart';
import '../../core/utils/app_utils.dart';

class GlobalViewModel extends ChangeNotifier {
  late AppInfoData _appInfo; //
  AppInfoData get appInfo => _appInfo;

  void initGlobalViewModel() async {
    // 初始化 _appInfo 變數
    _appInfo = await AppUtils.getAppInfo();
  }
}
