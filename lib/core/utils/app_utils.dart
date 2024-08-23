import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:logging_flutter/logging_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../localization/generated/l10n.dart';
import '../../router/app_router.dart';
import '../app_core.dart';
import '../models/app_info_data.dart';

class AppUtils {
  /*
   重新啟動 APP
   */
  static void restartApp(BuildContext? context) {
    Flogger.d('APP 重新啟動');
    // 取得路由，如果未傳入則使用全域變數(非必要情況下不建議使用)
    StackRouter router = appLocator<AppRouter>();
    if (context != null) router = AutoRouter.of(context);
    //Go back till no route (Restart)
    router.popUntil(((route) => false));
    // Navigate to first widget to the app **AppRoot()**
    router.pushNamed('/');
    return;
  }

  /*
   獲取 APP 資訊
   */
  static Future<AppInfoData> getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return AppInfoData(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildSignature: packageInfo.buildSignature,
      installerStore: packageInfo.installerStore ?? 'not available',
    );
  }

  /*
   將時間轉換為 XX ago 格式
   */
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 8) {
      return S.current.TimeAgoWeek((difference.inDays / 7).floor());
    } else if (difference.inDays >= 1) {
      return S.current.TimeAgoDay(difference.inDays);
    } else if (difference.inHours >= 1) {
      return S.current.TimeAgoHour(difference.inHours);
    } else {
      return S.current.TimeAgoMinute(difference.inMinutes);
    }
  }
}
